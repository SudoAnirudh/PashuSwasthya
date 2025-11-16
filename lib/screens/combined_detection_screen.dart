import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pashu_swasthya/services/breed_detection_service.dart';
import 'package:pashu_swasthya/services/disease_service.dart';
import 'package:pashu_swasthya/services/treatment_service.dart';
import 'package:pashu_swasthya/services/storage_service.dart';
import 'package:pashu_swasthya/models/prediction_history.dart';
import 'package:pashu_swasthya/screens/treatment_guide.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:uuid/uuid.dart';

enum DetectionStep {
  breedImageInput,
  breedResult,
  diseaseImageInput,
  finalResult,
}

class CombinedDetectionScreen extends StatefulWidget {
  const CombinedDetectionScreen({super.key});

  @override
  State<CombinedDetectionScreen> createState() =>
      _CombinedDetectionScreenState();
}

class _CombinedDetectionScreenState extends State<CombinedDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  final BreedDetectionService _breedService = BreedDetectionService();
  final DiseaseService _diseaseService = DiseaseService();
  final TreatmentService _treatmentService = TreatmentService();
  final StorageService _storageService = StorageService();

  DetectionStep _currentStep = DetectionStep.breedImageInput;

  // Breed detection state
  File? _breedImage;
  BreedPrediction? _breedResult;
  bool _isDetectingBreed = false;

  // Disease detection state
  File? _diseaseImage;
  DiseasePrediction? _diseaseResult;
  bool _isDetectingDisease = false;

  @override
  void initState() {
    super.initState();
    _initializeModels();
    _storageService.init();
  }

  Future<void> _initializeModels() async {
    try {
      await _breedService.initialize();
      await _diseaseService.initialize();
    } catch (e) {
      print('Error initializing models: $e');
    }
  }

  @override
  void dispose() {
    _breedService.dispose();
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

  Future<void> _pickBreedImage(ImageSource source) async {
    await _requestCameraPermission();
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _breedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDiseaseImage(ImageSource source) async {
    await _requestCameraPermission();
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _diseaseImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _detectBreed() async {
    if (_breedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or upload image first')),
      );
      return;
    }

    setState(() {
      _isDetectingBreed = true;
    });

    try {
      final prediction = await _breedService.detectBreed(_breedImage!);

      // Save to prediction history
      final history = PredictionHistory(
        id: const Uuid().v4(),
        type: 'breed',
        result: prediction.breedName,
        confidence: prediction.confidence,
        timestamp: DateTime.now(),
        imagePath: _breedImage!.path,
      );
      await _storageService.savePrediction(history);

      if (mounted) {
        setState(() {
          _breedResult = prediction;
          _isDetectingBreed = false;
          _currentStep = DetectionStep.breedResult;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDetectingBreed = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Breed detection failed: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _detectDisease() async {
    if (_diseaseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or upload image first')),
      );
      return;
    }

    setState(() {
      _isDetectingDisease = true;
    });

    try {
      final prediction = await _diseaseService.classifyDisease(_diseaseImage!);

      // Save to prediction history
      final history = PredictionHistory(
        id: const Uuid().v4(),
        type: 'disease',
        result: prediction.diseaseName,
        confidence: prediction.confidence,
        timestamp: DateTime.now(),
        imagePath: _diseaseImage!.path,
      );
      await _storageService.savePrediction(history);

      if (mounted) {
        setState(() {
          _diseaseResult = prediction;
          _isDetectingDisease = false;
          _currentStep = DetectionStep.finalResult;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDetectingDisease = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Disease detection failed: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _proceedToDiseaseInput() {
    setState(() {
      _currentStep = DetectionStep.diseaseImageInput;
    });
  }

  void _startOver() {
    setState(() {
      _currentStep = DetectionStep.breedImageInput;
      _breedImage = null;
      _breedResult = null;
      _diseaseImage = null;
      _diseaseResult = null;
    });
  }

  String _getDiseaseStatus() {
    if (_diseaseResult == null) {
      return 'No disease detected';
    }

    // Check if the disease is "Healthy" or confidence is too low
    if (_diseaseResult!.diseaseName.toLowerCase() == 'healthy' ||
        _diseaseResult!.confidence < 50.0) {
      return 'No disease detected';
    }

    return _diseaseResult!.diseaseName;
  }

  double _getOverallAccuracy() {
    double breedAccuracy = _breedResult?.confidence ?? 0.0;
    double diseaseAccuracy = _diseaseResult?.confidence ?? 0.0;

    // If no disease detected, only use breed accuracy
    if (_diseaseResult == null ||
        _diseaseResult!.diseaseName.toLowerCase() == 'healthy' ||
        _diseaseResult!.confidence < 50.0) {
      return breedAccuracy;
    }

    // Average of both accuracies
    return (breedAccuracy + diseaseAccuracy) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 40.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        centerTitle: true,
        leading:
            _currentStep != DetectionStep.breedImageInput
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (_currentStep == DetectionStep.finalResult) {
                      _startOver();
                    } else if (_currentStep ==
                        DetectionStep.diseaseImageInput) {
                      setState(() {
                        _currentStep = DetectionStep.breedResult;
                      });
                    } else if (_currentStep == DetectionStep.breedResult) {
                      setState(() {
                        _currentStep = DetectionStep.breedImageInput;
                      });
                    }
                  },
                )
                : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 800 : double.infinity,
            ),
            child: _buildCurrentStep(isTablet),
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case DetectionStep.breedImageInput:
        return 'Breed Detection';
      case DetectionStep.breedResult:
        return 'Breed Result';
      case DetectionStep.diseaseImageInput:
        return 'Disease Detection';
      case DetectionStep.finalResult:
        return 'Detection Results';
    }
  }

  Widget _buildCurrentStep(bool isTablet) {
    switch (_currentStep) {
      case DetectionStep.breedImageInput:
        return _buildBreedImageInputStep(isTablet);
      case DetectionStep.breedResult:
        return _buildBreedResultStep(isTablet);
      case DetectionStep.diseaseImageInput:
        return _buildDiseaseImageInputStep(isTablet);
      case DetectionStep.finalResult:
        return _buildFinalResultStep(isTablet);
    }
  }

  // Step 1: Breed Image Input
  Widget _buildBreedImageInputStep(bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: isTablet ? 400 : 250,
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentGreen, width: 2),
          ),
          child:
              _breedImage == null
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: isTablet ? 120 : 80,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Upload image of your cattle for breed identification',
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
                    child: Image.file(_breedImage!, fit: BoxFit.cover),
                  ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  'Camera',
                  style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14),
                ),
                onPressed: () => _pickBreedImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: Text(
                  'Gallery',
                  style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreenLight,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                ),
                onPressed: () => _pickBreedImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                _breedImage == null || _isDetectingBreed ? null : _detectBreed,
            icon:
                _isDetectingBreed
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.search),
            label: Text(
              _isDetectingBreed ? 'Detecting...' : 'Detect Breed',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              disabledBackgroundColor: Colors.grey,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 16),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Breed Result
  Widget _buildBreedResultStep(bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGreen, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    color: AppTheme.primaryGreen,
                    size: isTablet ? 32 : 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Breed Identified',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _breedResult?.breedName ?? 'Unknown',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Confidence: ${_breedResult?.confidence.toStringAsFixed(1) ?? '0.0'}%',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 16 : 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _proceedToDiseaseInput,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Continue to Disease Detection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningOrange,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 16),
            ),
          ),
        ),
      ],
    );
  }

  // Step 3: Disease Image Input
  Widget _buildDiseaseImageInputStep(bool isTablet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          height: isTablet ? 400 : 250,
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.warningOrange, width: 2),
          ),
          child:
              _diseaseImage == null
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
                        'Upload image of the diseased area',
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
                    child: Image.file(_diseaseImage!, fit: BoxFit.cover),
                  ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  'Camera',
                  style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14),
                ),
                onPressed: () => _pickDiseaseImage(ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: Text(
                  'Gallery',
                  style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreenLight,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
                ),
                onPressed: () => _pickDiseaseImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                _diseaseImage == null || _isDetectingDisease
                    ? null
                    : _detectDisease,
            icon:
                _isDetectingDisease
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.analytics),
            label: Text(
              _isDetectingDisease ? 'Analyzing...' : 'Analyze Disease',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningOrange,
              disabledBackgroundColor: Colors.grey,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 16),
            ),
          ),
        ),
      ],
    );
  }

  // Step 4: Final Results
  Widget _buildFinalResultStep(bool isTablet) {
    final diseaseStatus = _getDiseaseStatus();
    final overallAccuracy = _getOverallAccuracy();
    final hasDisease = diseaseStatus != 'No disease detected';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Breed Result
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGreen, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    color: AppTheme.primaryGreen,
                    size: isTablet ? 32 : 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Breed',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _breedResult?.breedName ?? 'Unknown',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Disease Result
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  hasDisease ? AppTheme.warningOrange : AppTheme.primaryGreen,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    hasDisease ? Icons.healing : Icons.check_circle,
                    color:
                        hasDisease
                            ? AppTheme.warningOrange
                            : AppTheme.primaryGreen,
                    size: isTablet ? 32 : 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Disease Status',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color:
                          hasDisease
                              ? AppTheme.warningOrange
                              : AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                diseaseStatus,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Accuracy Score
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
                    Icons.assessment,
                    color: AppTheme.primaryGreen,
                    size: isTablet ? 32 : 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Overall Accuracy',
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${overallAccuracy.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 36 : 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),

        if (hasDisease &&
            _diseaseResult != null &&
            _diseaseResult!.confidence >= 50.0) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final treatmentGuide = _treatmentService.getTreatmentGuide(
                  _diseaseResult!.diseaseName,
                );
                if (treatmentGuide != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => TreatmentGuidesScreen(
                            diseaseName: _diseaseResult!.diseaseName,
                            treatmentGuide: treatmentGuide,
                          ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TreatmentGuidesScreen(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.book),
              label: const Text('View Treatment Guide'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startOver,
            icon: const Icon(Icons.refresh),
            label: const Text('Start New Detection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textSecondary,
              padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
            ),
          ),
        ),

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
              Icon(Icons.info_outline, color: AppTheme.warningOrange, size: 20),
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
    );
  }
}
