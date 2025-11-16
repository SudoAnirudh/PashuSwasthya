import 'dart:io';
import 'package:pashu_swasthya/services/roboflow_service.dart';
import 'package:pashu_swasthya/services/offline_model_service.dart';

/// Unified Breed Detection Service
/// Automatically switches between Roboflow (online) and offline models
class BreedDetectionService {
  final RoboflowService _roboflowService = RoboflowService();
  final OfflineModelService _offlineService = OfflineModelService();
  bool _isOfflineModelInitialized = false;

  /// Initialize offline model (call this early in app lifecycle)
  Future<bool> initialize() async {
    try {
      _isOfflineModelInitialized = await _offlineService.initializeBreedModel();
      return _isOfflineModelInitialized;
    } catch (e) {
      print('Error initializing offline breed model: $e');
      return false;
    }
  }

  /// Detect breed from image
  /// Tries Roboflow first if online, falls back to offline model
  Future<BreedPrediction> detectBreed(File imageFile) async {
    try {
      // Try Roboflow first if online
      final isOnline = await _roboflowService.isOnline();
      if (isOnline) {
        try {
          final roboflowResult = await _roboflowService.classifyBreed(imageFile);
          return BreedPrediction(
            breedName: roboflowResult.primaryClass,
            confidence: roboflowResult.confidence,
            topPredictions: roboflowResult.topPredictions
                .map((p) => BreedPredictionItem(
                      label: p.label,
                      confidence: p.confidence,
                    ))
                .toList(),
            isOnline: true,
          );
        } catch (e) {
          print('Roboflow error, falling back to offline: $e');
          // Fall through to offline
        }
      }

      // Use offline model
      if (!_isOfflineModelInitialized) {
        await initialize();
      }

      if (!_isOfflineModelInitialized) {
        throw Exception('Offline model not available');
      }

      final offlineResult = await _offlineService.detectBreed(imageFile);
      return BreedPrediction(
        breedName: offlineResult.primaryClass,
        confidence: offlineResult.confidence,
        topPredictions: offlineResult.topPredictions
            .map((p) => BreedPredictionItem(
                  label: p.label,
                  confidence: p.confidence,
                ))
            .toList(),
        isOnline: false,
      );
    } catch (e) {
      throw Exception('Breed detection failed: $e');
    }
  }

  void dispose() {
    _offlineService.dispose();
  }

  bool get isModelLoaded => _isOfflineModelInitialized;
}

/// Breed prediction result
class BreedPrediction {
  final String breedName;
  final double confidence;
  final List<BreedPredictionItem> topPredictions;
  final bool isOnline;

  BreedPrediction({
    required this.breedName,
    required this.confidence,
    required this.topPredictions,
    required this.isOnline,
  });

  String get formattedResult {
    if (confidence < 50.0) {
      return 'Unable to determine breed. Please try with a clearer image.';
    }
    return '$breedName (${confidence.toStringAsFixed(1)}% confidence)';
  }

  String get detailedResult {
    final buffer = StringBuffer();
    buffer.writeln('Detected Breed: $breedName');
    buffer.writeln('Confidence: ${confidence.toStringAsFixed(1)}%');
    buffer.writeln('Mode: ${isOnline ? "Online (Roboflow)" : "Offline"}');
    buffer.writeln('\nTop Predictions:');
    for (int i = 0; i < topPredictions.length; i++) {
      buffer.writeln(
        '${i + 1}. ${topPredictions[i].label}: ${topPredictions[i].confidence.toStringAsFixed(1)}%',
      );
    }
    return buffer.toString();
  }
}

/// Individual breed prediction item
class BreedPredictionItem {
  final String label;
  final double confidence;

  BreedPredictionItem({
    required this.label,
    required this.confidence,
  });
}
