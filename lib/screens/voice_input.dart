import 'package:flutter/material.dart';
import 'package:pashu_swasthya/models/disease.dart';
import 'package:pashu_swasthya/services/symptom_disease_service.dart';
import 'package:pashu_swasthya/services/treatment_service.dart';
import 'package:pashu_swasthya/services/storage_service.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/services/translation_service.dart';
import 'package:pashu_swasthya/models/prediction_history.dart';
import 'package:pashu_swasthya/screens/treatment_guide.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class VoiceInputScreen extends StatefulWidget {
  final String localeId;
  const VoiceInputScreen({super.key, this.localeId = 'en_IN'});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  final SymptomDiseaseService _diseaseService = SymptomDiseaseService();
  final TreatmentService _treatmentService = TreatmentService();
  final StorageService _storageService = StorageService();
  final TranslationService _translationService = TranslationService();

  bool _isListening = false;
  bool _isAnalyzing = false;
  String _transcribedText = '';
  String _statusMessage = '';
  DiseaseIdentification? _diseaseIdentification;
  String? _currentLocaleId;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _storageService.init();
    _initializeTts();
    
    // Defer status message update until after build to access context safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateStatusMessage();
    });
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _updateStatusMessage() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    setState(() {
      if (_isListening) {
        _statusMessage = localizationService.translate('listening_describe_symptoms');
      } else if (_isAnalyzing) {
        _statusMessage = localizationService.translate('analyzing_symptoms');
      } else {
        _statusMessage = localizationService.translate('tap_mic_describe');
      }
    });
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizationService.translate('microphone_permission_required')),
          ),
        );
      }
    }
  }

  String _getSpeechLocale() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final langCode = localizationService.locale.languageCode;
    
    // Map language codes to speech recognition locale IDs
    switch (langCode) {
      case 'hi':
        return 'hi_IN';
      case 'ml':
        return 'ml_IN';
      case 'kn':
        return 'kn_IN';
      case 'ta':
        return 'ta_IN';
      default:
        return 'en_IN';
    }
  }

  Future<void> _startListening() async {
    await _requestMicrophonePermission();
    setState(() {
      // Don't clear existing results immediately - let user see them
      // _diseaseIdentification = null;
      _transcribedText = '';
    });
    
    final speechLocale = _getSpeechLocale();
    _currentLocaleId = speechLocale;
    
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
          _updateStatusMessage();
        }
      },
      onError: (error) {
        final localizationService = Provider.of<LocalizationService>(context, listen: false);
        setState(() {
          _statusMessage = '${localizationService.translate('error')}: ${error.errorMsg}';
          _isListening = false;
        });
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
      });
      _updateStatusMessage();
      
      _speech.listen(
        onResult: (result) {
          setState(() {
            _transcribedText = result.recognizedWords;
          });
          
          // Real-time prediction while speaking (if text is substantial)
          // Analyze symptoms when we have enough text (debounced in _analyzeSymptoms)
          // Lower threshold to 5 characters for faster response
          if (result.recognizedWords.length >= 5) {
            _analyzeSymptoms(result.recognizedWords);
          }
        },
        localeId: speechLocale,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    } else {
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      setState(() {
        _statusMessage = localizationService.translate('speech_recognition_not_available');
        _isListening = false;
      });
    }
  }

  Future<DiseaseIdentification?> _analyzeSymptoms(String text) async {
    if (text.isEmpty) return null;
    
    final normalizedText = await _prepareTextForAnalysis(text);
    if (normalizedText.isEmpty) return null;

    // If already analyzing, wait a bit and try again
    if (_isAnalyzing) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_isAnalyzing) return null; // Still analyzing, skip this call
    }
    
    setState(() {
      _isAnalyzing = true;
    });
    _updateStatusMessage();
    
    // Small delay to avoid too frequent analysis
    await Future.delayed(const Duration(milliseconds: 300));
    
    print('🔬 Analyzing symptoms: "$normalizedText"');
    final identification = _diseaseService.identifyDisease(normalizedText);
    
    if (identification != null) {
      print('✅ Disease identified: ${identification.disease.name} (${identification.confidence.toStringAsFixed(1)}%)');
      print('✅ Matched keywords: ${identification.matchedKeywords.join(", ")}');
    } else {
      print('❌ No disease identified');
    }
    
    // Update state with the identification result
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _diseaseIdentification = identification;
      });
      print('🔄 State updated. _diseaseIdentification is now: ${_diseaseIdentification != null ? _diseaseIdentification!.disease.name : "null"}');
      _updateStatusMessage();
    }
    
    return identification;
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    
    setState(() {
      _isListening = false;
      _isAnalyzing = true;
    });
    _updateStatusMessage();
    
    // Identify disease from transcribed text
    final identification = await _analyzeSymptoms(_transcribedText);
    
    // Save to prediction history if disease identified
    if (identification != null) {
      final history = PredictionHistory(
        id: const Uuid().v4(),
        type: 'disease',
        result: identification.disease.name,
        confidence: identification.confidence,
        timestamp: DateTime.now(),
        notes: _transcribedText,
      );
      await _storageService.savePrediction(history);
    }
    
    setState(() {
      _isAnalyzing = false;
      _diseaseIdentification = identification;
    });
    _updateStatusMessage();
    
    // Provide TTS feedback
    if (identification != null) {
      final localizationService = Provider.of<LocalizationService>(context, listen: false);
      final isHindi = localizationService.locale.languageCode == 'hi';
      
      // Note: We are keeping TTS in English/Hindi mixed for now or just simple feedback
      // Ideally TTS should also be localized but flutter_tts needs language setting
      
      final ttsMessage = isHindi
          ? 'रोग पहचाना गया: ${identification.disease.name}.'
          : 'Disease identified: ${identification.disease.name}.';
      
      await _flutterTts.speak(ttsMessage);
    }
  }

  Future<void> _saveDescription() async {
    if (_transcribedText.isEmpty) return;

    // Save description to history
    final history = PredictionHistory(
      id: const Uuid().v4(),
      type: 'voice_note',
      result: 'Voice Description',
      confidence: 0.0,
      timestamp: DateTime.now(),
      notes: _transcribedText,
    );
    await _storageService.savePrediction(history);

    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizationService.translate('description_saved')),
        ),
      );
    }

    // TTS feedback
    await _flutterTts.speak(localizationService.translate('description_saved'));

    setState(() {
      _transcribedText = '';
      _diseaseIdentification = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final isHindi = localizationService.locale.languageCode == 'hi';
        
        return Scaffold(
          appBar: AppBar(
            title: Text(localizationService.translate('voice_disease_prediction')),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizationService.translate('describe_symptoms_info'),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Status message
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _isListening 
                        ? Colors.blue.withOpacity(0.1)
                        : _isAnalyzing
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isListening || _isAnalyzing)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isListening ? Colors.blue : Colors.orange,
                            ),
                          ),
                        ),
                      if (_isListening || _isAnalyzing) const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          _statusMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _isListening 
                                ? Colors.blue
                                : _isAnalyzing
                                    ? Colors.orange
                                    : AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Live transcription area
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: _transcribedText.isEmpty
                      ? Center(
                          child: Text(
                            localizationService.translate('your_description_here'),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : Text(
                          _transcribedText,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                
                // Disease result card
                if (_diseaseIdentification != null) ...[
                  _buildDiseaseInfo(localizationService),
                ] else if (_transcribedText.isNotEmpty && 
                    !_isAnalyzing && 
                    !_isListening) ...[
                  // Show message if no result but text exists
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            localizationService.translate('no_disease_identified'),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                    ],
                  ),
                ),
              ),
              // Fixed bottom section with buttons
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stop Recording button (visible only while listening)
                    if (_isListening)
                      ElevatedButton.icon(
                        onPressed: _stopListening,
                        icon: const Icon(Icons.stop),
                        label: Text(localizationService.translate('stop_recording')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    if (_isListening) const SizedBox(height: 10),

                    // Microphone, Analyze & Save buttons
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Mic button
                            FloatingActionButton.extended(
                              onPressed: _isListening ? _stopListening : _startListening,
                              backgroundColor: _isListening ? Colors.red : AppTheme.primaryGreen,
                              icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                              label: Text(
                                _isListening 
                                    ? localizationService.translate('stop')
                                    : localizationService.translate('start'),
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Analyze button (manual trigger)
                            ElevatedButton.icon(
                              onPressed: (_transcribedText.isEmpty || _isAnalyzing) 
                                  ? null 
                                  : () => _analyzeSymptoms(_transcribedText),
                              icon: const Icon(Icons.search),
                              label: Text(localizationService.translate('analyze')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Save button
                        ElevatedButton.icon(
                          onPressed: _transcribedText.isEmpty ? null : _saveDescription,
                          icon: const Icon(Icons.save),
                          label: Text(localizationService.translate('save')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _prepareTextForAnalysis(String text) async {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    final langCode = localizationService.locale.languageCode;
    if (text.trim().isEmpty) return text;

    // English and Hindi are already supported directly
    const directLanguages = {'en', 'hi'};
    if (directLanguages.contains(langCode)) {
      return text;
    }

    try {
      final translatedText = await _translationService.translate(
        text,
        'en',
        sourceLanguage: langCode,
      );
      print('🌐 Translated ($langCode → en): $translatedText');
      return translatedText;
    } catch (e) {
      print('⚠️ Translation failed ($langCode → en): $e');
      return text;
    }
  }

  Widget _buildDiseaseInfo(LocalizationService localizationService) {
    if (_diseaseIdentification == null) {
      print('⚠️ _buildDiseaseInfo called but _diseaseIdentification is null');
      return const SizedBox.shrink();
    }
    
    final identification = _diseaseIdentification!;
    print('🎨 Building disease info UI for: ${identification.disease.name}');
    final treatmentGuide = _treatmentService.getTreatmentGuide(identification.disease.name);
    final confidenceColor = identification.confidence >= 70
        ? Colors.green
        : identification.confidence >= 50
            ? Colors.orange
            : Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.medical_services, color: AppTheme.primaryGreen, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizationService.translate('identified_disease'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      identification.disease.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: confidenceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, color: confidenceColor),
                const SizedBox(width: 8),
                Text(
                  '${localizationService.translate('confidence')}: ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${identification.confidence.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: confidenceColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizationService.translate('matched_symptoms'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: identification.matchedKeywords.take(5).map(
              (keyword) => Chip(
                label: Text(
                  keyword,
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                avatar: Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen),
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              ),
            ).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            localizationService.translate('all_symptoms'),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...identification.disease.symptoms.map(
            (symptom) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 8, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      symptom,
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (treatmentGuide != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TreatmentGuidesScreen(
                      diseaseName: identification.disease.name,
                      treatmentGuide: treatmentGuide,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.book),
              label: Text(localizationService.translate('view_treatment_guide')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }

}
