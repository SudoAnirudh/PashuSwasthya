import 'package:flutter/material.dart';
import 'package:pashu_swasthya/models/disease.dart';
import 'package:pashu_swasthya/services/symptom_disease_service.dart';
import 'package:pashu_swasthya/services/treatment_service.dart';
import 'package:pashu_swasthya/services/storage_service.dart';
import 'package:pashu_swasthya/models/prediction_history.dart';
import 'package:pashu_swasthya/screens/treatment_guide.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

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

  bool _isListening = false;
  String _transcribedText = '';
  String _statusMessage = 'Tap the microphone to describe the cattle health';
  DiseaseIdentification? _diseaseIdentification;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _storageService.init();
  }

  Future<void> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    }
  }

  Future<void> _startListening() async {
    await _requestMicrophonePermission();
    setState(() {
      _diseaseIdentification = null;
    });
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
            _statusMessage = 'Tap the microphone to describe the cattle health';
          });
        }
      },
      onError: (error) {
        setState(() {
          _statusMessage = 'Error: ${error.errorMsg}';
          _isListening = false;
        });
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _statusMessage = 'Listening...';
      });
      _speech.listen(
        onResult: (result) {
          setState(() {
            _transcribedText = result.recognizedWords;
          });
        },
        localeId: widget.localeId,
      );
    } else {
      setState(() {
        _statusMessage = 'Speech recognition not available';
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    if (!_isListening) return;
    await _speech.stop();
    
    // Identify disease from transcribed text
    final identification = _diseaseService.identifyDisease(_transcribedText);
    
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
      _isListening = false;
      _statusMessage = identification != null
          ? 'Disease identified: ${identification.disease.name}'
          : 'Tap the microphone to describe the cattle health';
      _diseaseIdentification = identification;
    });
    
    // Provide TTS feedback
    if (identification != null) {
      await _flutterTts.speak(
        'Disease identified: ${identification.disease.name}. Confidence: ${identification.confidence.toStringAsFixed(0)} percent.',
      );
    }
  }

  Future<void> _saveDescription() async {
    if (_transcribedText.isEmpty) return;

    // TODO: Replace with actual save logic (API / local DB)
    print('Cattle Health Description Saved: $_transcribedText');

    // TTS feedback
    await _flutterTts.speak('Description saved successfully');

    setState(() {
      _transcribedText = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Describe Cattle Health'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Status message
            Text(_statusMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Live transcription area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _transcribedText.isEmpty
                        ? 'Your description will appear here...'
                        : _transcribedText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Stop Recording button (visible only while listening)
            if (_isListening)
              ElevatedButton.icon(
                onPressed: _stopListening,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Recording'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            const SizedBox(height: 10),

            // Microphone & Save buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mic button
                FloatingActionButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  backgroundColor: _isListening ? Colors.red : Colors.blue,
                  child: Icon(_isListening ? Icons.mic_off : Icons.mic),
                ),
                const SizedBox(width: 30),
                // Save button
                ElevatedButton(
                  onPressed: _transcribedText.isEmpty ? null : _saveDescription,
                  child: const Text('Save Description'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_diseaseIdentification != null) _buildDiseaseInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseInfo() {
    if (_diseaseIdentification == null) return const SizedBox.shrink();
    
    final identification = _diseaseIdentification!;
    final treatmentGuide = _treatmentService.getTreatmentGuide(identification.disease.name);
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medical_services, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Identified Disease: ${identification.disease.name}',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Confidence: ${identification.confidence.toStringAsFixed(1)}%',
            style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            'Matched Symptoms:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...identification.matchedKeywords.map(
            (keyword) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  Text(keyword, style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'All Symptoms:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...identification.disease.symptoms.map(
            (symptom) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text('• $symptom', style: GoogleFonts.poppins(fontSize: 14)),
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
              label: const Text('View Treatment Guide'),
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
