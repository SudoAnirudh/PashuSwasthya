import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pashu_swasthya/services/disease_service.dart';
import 'package:pashu_swasthya/services/treatment_service.dart';
import 'package:pashu_swasthya/services/storage_service.dart';
import 'package:pashu_swasthya/models/prediction_history.dart';
import 'package:pashu_swasthya/screens/treatment_guide.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:pashu_swasthya/services/localization_service.dart';

class CameraDiagnosisScreen extends StatefulWidget {
  const CameraDiagnosisScreen({super.key});

  @override
  State<CameraDiagnosisScreen> createState() => _CameraDiagnosisScreenState();
}

class _CameraDiagnosisScreenState extends State<CameraDiagnosisScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final DiseaseService _diseaseService = DiseaseService();
  final TreatmentService _treatmentService = TreatmentService();
  final StorageService _storageService = StorageService();

  String? _analysisResult;
  String? _detectedDisease;
  double? _confidence;
  bool _isAnalyzing = false;
  bool _isModelLoaded = false;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
    _storageService.init();
  }

  Future<void> _initializeModel() async {
    try {
      final loaded = await _diseaseService.initialize();
      if (mounted) {
        setState(() {
          _isModelLoaded = loaded;
        });
      }
    } catch (e) {
      print('Error initializing disease model: $e');
    }
  }

  @override
  void dispose() {
    _diseaseService.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    await _requestCameraPermission();
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _analysisResult = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or upload image first')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final prediction = await _diseaseService.classifyDisease(_image!);

      // Save to prediction history
      final history = PredictionHistory(
        id: const Uuid().v4(),
        type: 'disease',
        result: prediction.diseaseName,
        confidence: prediction.confidence,
        timestamp: DateTime.now(),
        imagePath: _image!.path,
      );
      await _storageService.savePrediction(history);

      if (mounted) {
        setState(() {
          _analysisResult = prediction.formattedResult;
          _detectedDisease = prediction.diseaseName;
          _confidence = prediction.confidence;
          _isOnline = prediction.isOnline;
          _isAnalyzing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              prediction.confidence >= 50.0
                  ? 'Analysis complete'
                  : 'Low confidence. Please consult a veterinarian.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult =
              'Error during analysis: $e\n\nPlease try again or consult a veterinarian.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 40.0 : 20.0;
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Disease Diagnosis'), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image Preview
                Container(
                  width: double.infinity,
                  height: isTablet ? 400 : 250,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.accentGreen, width: 2),
                  ),
                  child:
                      _image == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.healing,
                                size: isTablet ? 120 : 80,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Upload or capture your cattle\'s photo',
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 18 : 14,
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                ),
                const SizedBox(height: 30),

                // Image Selection Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                          'Camera',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                        onPressed: () => _pickImage(ImageSource.camera),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_library),
                        label: Text(
                          'Gallery',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreenLight,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 12,
                          ),
                        ),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Analyze Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeImage,
                    icon:
                        _isAnalyzing
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.analytics),
                    label: Text(
                      _isAnalyzing ? 'Analyzing...' : 'Analyze Disease',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.warningOrange,
                      disabledBackgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 18 : 16,
                      ),
                    ),
                  ),
                ),

                // Model Status
                if (!_isModelLoaded)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppTheme.warningOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Offline model not loaded',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 14 : 12,
                            color: AppTheme.warningOrange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Results
                if (_analysisResult != null) ...[
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.accentGreen, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.medical_services,
                              color: AppTheme.primaryGreen,
                              size: isTablet ? 32 : 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localizationService.translate('result'),
                                style: GoogleFonts.poppins(
                                  fontSize: isTablet ? 24 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _isOnline
                                        ? AppTheme.primaryGreen
                                        : AppTheme.textSecondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isOnline ? 'Online' : 'Offline',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _analysisResult!,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 18 : 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (_detectedDisease != null &&
                            _detectedDisease!.toLowerCase() != 'healthy')
                          _buildFirstAidSummary(context, _detectedDisease!),
                        if (_detectedDisease != null &&
                            _confidence != null &&
                            _confidence! >= 50.0) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final treatmentGuide = _treatmentService
                                    .getTreatmentGuide(_detectedDisease!);
                                if (treatmentGuide != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => TreatmentGuidesScreen(
                                            diseaseName: _detectedDisease!,
                                            treatmentGuide: treatmentGuide,
                                          ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => const TreatmentGuidesScreen(),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.book),
                              label: const Text('View Treatment Guide'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                padding: EdgeInsets.symmetric(
                                  vertical: isTablet ? 16 : 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warningOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.warningOrange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This is an AI-assisted diagnosis. Always consult a qualified veterinarian for confirmation.',
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 14 : 12,
                                    color: AppTheme.warningOrange,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildFirstAidSummary(BuildContext context, String diseaseName) {
    final localizationService = Provider.of<LocalizationService>(
      context,
      listen: false,
    );
    final guide = _treatmentService.getTreatmentGuide(diseaseName);

    if (guide == null || guide.firstAid.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                localizationService.translate('first_aid'),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...guide.firstAid
              .take(3)
              .map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• ",
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
