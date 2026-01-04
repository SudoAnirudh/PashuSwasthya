import 'dart:io';
import 'dart:ui';
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
import 'package:provider/provider.dart';
import 'package:pashu_swasthya/services/localization_service.dart';
import 'package:pashu_swasthya/screens/navigation_screen.dart';
import 'package:lottie/lottie.dart';

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

class _CombinedDetectionScreenState extends State<CombinedDetectionScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final BreedDetectionService _breedService = BreedDetectionService();
  final DiseaseService _diseaseService = DiseaseService();
  final TreatmentService _treatmentService = TreatmentService();
  final StorageService _storageService = StorageService();

  late AnimationController _scanController;
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
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initializeModels();
    _storageService.init();
  }

  Future<void> _initializeModels() async {
    try {
      await _breedService.initialize();
      await _diseaseService.initialize();
    } catch (e) {
      debugPrint('Error initializing models: $e');
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _breedService.dispose();
    _diseaseService.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LocalizationService>(
                context,
                listen: false,
              ).translate('camera_permission_required'),
            ),
          ),
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
        SnackBar(
          content: Text(
            Provider.of<LocalizationService>(
              context,
              listen: false,
            ).translate('please_capture_image'),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isDetectingBreed = true;
    });

    try {
      // Small artificial delay for premium animation feel
      await Future.delayed(const Duration(seconds: 3));
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
            content: Text(
              '${Provider.of<LocalizationService>(context, listen: false).translate('breed_detection_failed')}: $e',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _detectDisease() async {
    if (_diseaseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LocalizationService>(
              context,
              listen: false,
            ).translate('please_capture_image'),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isDetectingDisease = true;
    });

    try {
      // Artificial delay for scanning animation
      await Future.delayed(const Duration(seconds: 3));
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
            content: Text(
              '${Provider.of<LocalizationService>(context, listen: false).translate('disease_detection_failed')}: $e',
            ),
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

    if (_diseaseResult!.diseaseName.toLowerCase() == 'healthy' ||
        _diseaseResult!.confidence < 50.0) {
      return 'no_disease_detected';
    }

    return _diseaseResult!.diseaseName;
  }

  double _getOverallAccuracy() {
    double breedAccuracy = _breedResult?.confidence ?? 0.0;
    double diseaseAccuracy = _diseaseResult?.confidence ?? 0.0;

    if (_diseaseResult == null ||
        _diseaseResult!.diseaseName.toLowerCase() == 'healthy' ||
        _diseaseResult!.confidence < 50.0) {
      return breedAccuracy;
    }

    return (breedAccuracy + diseaseAccuracy) / 2;
  }

  /// ✨ Premium Scanning Overlay
  Widget _buildScanningOverlay(File imageFile, String label) {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(
                imageFile,
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return Positioned(
                  top: _scanController.value * 340,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.greenAccent.withOpacity(0),
                          Colors.greenAccent.withOpacity(0.8),
                          Colors.greenAccent.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.greenAccent,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "ANALYZING...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 📊 Premium Step Indicator
  Widget _buildStepIndicator() {
    final localizationService = Provider.of<LocalizationService>(context);
    int activeIndex = 0;
    if (_currentStep == DetectionStep.breedResult) activeIndex = 1;
    if (_currentStep == DetectionStep.diseaseImageInput) activeIndex = 2;
    if (_currentStep == DetectionStep.finalResult) activeIndex = 3;

    final steps = [
      localizationService.translate('step_breed_input'),
      localizationService.translate('step_analyze_breed'),
      localizationService.translate('step_disease_input'),
      localizationService.translate('step_results'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        children: List.generate(steps.length, (index) {
          bool isActive = index <= activeIndex;
          bool isCurrent = index == activeIndex;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        color:
                            index == 0
                                ? Colors.transparent
                                : (isActive
                                    ? AppTheme.primaryGreen
                                    : Colors.grey[300]),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primaryGreen : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isActive
                                  ? AppTheme.primaryGreen
                                  : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow:
                            isCurrent
                                ? [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child:
                            isActive
                                ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                                : Text(
                                  "${index + 1}",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 4,
                        color:
                            index == steps.length - 1
                                ? Colors.transparent
                                : (index < activeIndex
                                    ? AppTheme.primaryGreen
                                    : Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w400,
                    color: isActive ? AppTheme.primaryGreen : Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final padding = isTablet ? 30.0 : 20.0;
    final localizationService = Provider.of<LocalizationService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(color: AppTheme.primaryGreen),
        title: Text(
          localizationService.translate('disease_detection'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Decorative Circle
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: _buildCurrentStep(isTablet),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: AppTheme.primaryGreen,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => NavigationScreen(initialIndex: index),
              ),
            );
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.mic_rounded),
              label: localizationService.translate('voice'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: localizationService.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: localizationService.translate('settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(bool isTablet) {
    final localizationService = Provider.of<LocalizationService>(context);
    if (_isDetectingBreed && _breedImage != null) {
      return _buildScanningOverlay(
        _breedImage!,
        localizationService.translate('detecting_breed_status'),
      );
    }
    if (_isDetectingDisease && _diseaseImage != null) {
      return _buildScanningOverlay(
        _diseaseImage!,
        localizationService.translate('detecting_disease_status'),
      );
    }

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

  Widget _buildGlassCard({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8F5E9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // Step 1: Breed Image Input
  Widget _buildBreedImageInputStep(bool isTablet) {
    final localizationService = Provider.of<LocalizationService>(context);
    return Column(
      children: [
        _buildGlassCard(
          child: Column(
            children: [
              Container(
                height: isTablet ? 400 : 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child:
                    _breedImage == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localizationService.translate(
                                'upload_cattle_image',
                              ),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                        : ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: Image.file(_breedImage!, fit: BoxFit.cover),
                        ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.camera_alt_rounded,
                        label: localizationService.translate('camera'),
                        onPressed: () => _pickBreedImage(ImageSource.camera),
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.photo_library_rounded,
                        label: localizationService.translate('gallery'),
                        onPressed: () => _pickBreedImage(ImageSource.gallery),
                        color: const Color(0xFF6A9C89),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _breedImage == null ? null : _detectBreed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Text(
              localizationService.translate('detect_breed'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      onPressed: onPressed,
    );
  }

  // Step 2: Breed Result
  Widget _buildBreedResultStep(bool isTablet) {
    final localizationService = Provider.of<LocalizationService>(context);
    return Column(
      children: [
        _buildGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 60,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(height: 16),
                Text(
                  localizationService.translate('breed_identified'),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _breedResult?.breedName ?? 'Unknown',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${localizationService.translate('confidence')}: ${_breedResult?.confidence.toStringAsFixed(1) ?? '0.0'}%',
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: _proceedToDiseaseInput,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              localizationService.translate('continue_disease_detection'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9A825),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 3: Disease Image Input
  Widget _buildDiseaseImageInputStep(bool isTablet) {
    final localizationService = Provider.of<LocalizationService>(context);
    return Column(
      children: [
        _buildGlassCard(
          child: Column(
            children: [
              Container(
                height: isTablet ? 400 : 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child:
                    _diseaseImage == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.healing_rounded,
                              size: 80,
                              color: Colors.orange[200],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              localizationService.translate(
                                'upload_disease_image',
                              ),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        )
                        : ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: Image.file(_diseaseImage!, fit: BoxFit.cover),
                        ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.camera_alt_rounded,
                        label: localizationService.translate('camera'),
                        onPressed: () => _pickDiseaseImage(ImageSource.camera),
                        color: Colors.orange[800]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.photo_library_rounded,
                        label: localizationService.translate('gallery'),
                        onPressed: () => _pickDiseaseImage(ImageSource.gallery),
                        color: Colors.orange[400]!,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _diseaseImage == null ? null : _detectDisease,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9A825),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              localizationService.translate('analyze_disease'),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Step 4: Final Results
  Widget _buildFinalResultStep(bool isTablet) {
    final localizationService = Provider.of<LocalizationService>(context);
    final diseaseStatus = _getDiseaseStatus();
    final overallAccuracy = _getOverallAccuracy();
    final hasDisease = diseaseStatus != 'no_disease_detected';

    return Column(
      children: [
        _buildResultCard(
          title: localizationService.translate('breed_identified'),
          value:
              _breedResult?.breedName ??
              localizationService.translate('unknown'),
          icon: Icons.pets_rounded,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(height: 16),
        _buildResultCard(
          title: localizationService.translate('disease_status'),
          value:
              diseaseStatus == 'no_disease_detected'
                  ? localizationService.translate('no_disease_detected')
                  : diseaseStatus,
          icon:
              hasDisease
                  ? Icons.warning_amber_rounded
                  : Icons.health_and_safety_rounded,
          color: hasDisease ? Colors.redAccent : Colors.green[600]!,
        ),
        const SizedBox(height: 16),
        _buildGlassCard(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: CircularProgressIndicator(
                        value: overallAccuracy / 100,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    Text(
                      "${overallAccuracy.toStringAsFixed(0)}%",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizationService.translate('overall_accuracy'),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        localizationService.translate(
                          'based_on_dual_scanning_models',
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasDisease) _buildFirstAidSection(localizationService),
        const SizedBox(height: 24),
        if (hasDisease)
          _buildWideButton(
            label: localizationService.translate('view_treatment_guide'),
            icon: Icons.menu_book_rounded,
            color: AppTheme.primaryGreen,
            onPressed: () {
              final treatmentGuide = _treatmentService.getTreatmentGuide(
                _diseaseResult!.diseaseName,
              );
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
            },
          ),
        const SizedBox(height: 12),
        _buildWideButton(
          label: localizationService.translate('start_new_detection'),
          icon: Icons.refresh_rounded,
          color: Colors.grey[700]!,
          onPressed: _startOver,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.amber[800]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizationService.translate('ai_diagnosis_disclaimer'),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7B5A00),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFirstAidSection(LocalizationService ls) {
    if (_diseaseResult == null) return const SizedBox.shrink();

    final treatmentGuide = _treatmentService.getTreatmentGuide(
      _diseaseResult!.diseaseName,
    );
    if (treatmentGuide == null || treatmentGuide.firstAid.isEmpty)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: _buildGlassCard(
        color: const Color(0xFFFFF8E1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.emergency_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    ls.translate('first_aid'),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...treatmentGuide.firstAid
                  .map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "• ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              step,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
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
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return _buildGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: onPressed,
      ),
    );
  }
}
