import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pashu_swasthya/services/breed_detection_service.dart';
import 'package:pashu_swasthya/services/storage_service.dart';
import 'package:pashu_swasthya/models/prediction_history.dart';
import 'package:pashu_swasthya/utils/app_theme.dart';
import 'package:uuid/uuid.dart';

class BreedDetectionScreen extends StatefulWidget {
  const BreedDetectionScreen({super.key});

  @override
  State<BreedDetectionScreen> createState() => _BreedDetectionScreenState();
}

class _BreedDetectionScreenState extends State<BreedDetectionScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final BreedDetectionService _breedService = BreedDetectionService();
  final StorageService _storageService = StorageService();

  String? _detectionResult;
  bool _isDetecting = false;
  bool _isModelLoaded = false;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _initializeBreedModel();
    _storageService.init();
  }

  Future<void> _initializeBreedModel() async {
    try {
      final loaded = await _breedService.initialize();
      if (mounted) {
        setState(() {
          _isModelLoaded = loaded;
        });
      }
    } catch (e) {
      print('Error initializing breed detection model: $e');
    }
  }

  @override
  void dispose() {
    _breedService.dispose();
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
        _detectionResult = null;
      });
    }
  }

  Future<void> _detectBreed() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture or upload image first')),
      );
      return;
    }

    setState(() {
      _isDetecting = true;
      _detectionResult = null;
    });

    try {
      final prediction = await _breedService.detectBreed(_image!);

      // Save to prediction history
      final history = PredictionHistory(
        id: const Uuid().v4(),
        type: 'breed',
        result: prediction.breedName,
        confidence: prediction.confidence,
        timestamp: DateTime.now(),
        imagePath: _image!.path,
      );
      await _storageService.savePrediction(history);

      if (mounted) {
        setState(() {
          _detectionResult = prediction.formattedResult;
          _isOnline = prediction.isOnline;
          _isDetecting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              prediction.confidence >= 50.0
                  ? 'Breed detection complete'
                  : 'Low confidence. Please try with a clearer image.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDetecting = false;
          _detectionResult = 'Error during breed detection: $e\n\nPlease try again.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Detection failed: $e'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breed Detection'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
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
                  child: _image == null
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
                              'Capture or upload a photo of your cattle',
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
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
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
                          style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14),
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
                          style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14),
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

                // Detect Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isDetecting ? null : _detectBreed,
                    icon: _isDetecting
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
                      _isDetecting ? 'Detecting...' : 'Detect Breed',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
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
                if (_detectionResult != null) ...[
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
                              Icons.pets,
                              color: AppTheme.primaryGreen,
                              size: isTablet ? 32 : 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Breed Detection Result',
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
                                color: _isOnline
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
                          _detectionResult!,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 18 : 16,
                            color: AppTheme.textPrimary,
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
}
