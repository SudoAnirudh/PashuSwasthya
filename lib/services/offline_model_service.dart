import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Offline Model Service for breed and disease classification
/// Uses TFLite models from Model_New directory
class OfflineModelService {
  Interpreter? _breedInterpreter;
  Interpreter? _diseaseInterpreter;
  bool _isBreedModelLoaded = false;
  bool _isDiseaseModelLoaded = false;

  // Model paths
  static const String _breedModelPath = 'Model_New/Breed/breed_classifier.tflite';
  static const String _diseaseModelPath = 'assets/models/disease_classifier.tflite';

  // Model configuration
  static const int _inputSize = 224;
  static const int _numChannels = 3; // RGB
  static const int _numClasses = 10; // Adjust based on your model

  // Breed labels (update based on your model)
  final List<String> _breedLabels = [
    'Holstein Friesian',
    'Jersey',
    'Sahiwal',
    'Gir',
    'Red Sindhi',
    'Tharparkar',
    'Kankrej',
    'Ongole',
    'Hariana',
    'Other',
  ];

  // Disease labels (update based on your model)
  final List<String> _diseaseLabels = [
    'Healthy',
    'Foot and Mouth Disease',
    'Mastitis',
    'Lumpy Skin Disease',
    'Brucellosis',
    'Anthrax',
    'Blackleg',
    'Fever',
    'Skin Infection',
    'Other',
  ];

  /// Initialize breed detection model
  Future<bool> initializeBreedModel() async {
    if (_isBreedModelLoaded) return true;

    try {
      print('Loading breed model from: $_breedModelPath');
      _breedInterpreter = await Interpreter.fromAsset(_breedModelPath);

      final inputShape = _breedInterpreter!.getInputTensor(0).shape;
      final outputShape = _breedInterpreter!.getOutputTensor(0).shape;

      print('Breed model loaded successfully!');
      print('Input shape: $inputShape');
      print('Output shape: $outputShape');

      _isBreedModelLoaded = true;
      return true;
    } catch (e) {
      print('CRITICAL: Error loading breed model: $e');
      _isBreedModelLoaded = false;
      return false;
    }
  }

  /// Initialize disease classification model
  Future<bool> initializeDiseaseModel() async {
    if (_isDiseaseModelLoaded) return true;

    try {
      print('Loading disease model from: $_diseaseModelPath');
      _diseaseInterpreter = await Interpreter.fromAsset(_diseaseModelPath);

      final inputShape = _diseaseInterpreter!.getInputTensor(0).shape;
      final outputShape = _diseaseInterpreter!.getOutputTensor(0).shape;

      print('Disease model loaded successfully!');
      print('Input shape: $inputShape');
      print('Output shape: $outputShape');

      _isDiseaseModelLoaded = true;
      return true;
    } catch (e) {
      print('CRITICAL: Error loading disease model: $e');
      _isDiseaseModelLoaded = false;
      return false;
    }
  }

  /// Detect breed from image (offline)
  Future<OfflinePrediction> detectBreed(File imageFile) async {
    if (!_isBreedModelLoaded || _breedInterpreter == null) {
      throw Exception('Breed model not loaded. Call initializeBreedModel() first.');
    }

    try {
      final inputBuffer = await _preprocessImage(imageFile);
      final outputShape = _breedInterpreter!.getOutputTensor(0).shape;
      final outputBuffer = List.generate(
        1,
        (_) => List<double>.filled(outputShape[1], 0.0),
      );

      _breedInterpreter!.run(inputBuffer, outputBuffer);

      final predictions = outputBuffer[0];
      final topPredictions = _getTopPredictions(predictions, _breedLabels, 3);

      return OfflinePrediction(
        primaryClass: topPredictions.first.label,
        confidence: topPredictions.first.confidence,
        topPredictions: topPredictions,
      );
    } catch (e) {
      print('Error during breed detection: $e');
      rethrow;
    }
  }

  /// Classify disease from image (offline)
  Future<OfflinePrediction> classifyDisease(File imageFile) async {
    if (!_isDiseaseModelLoaded || _diseaseInterpreter == null) {
      throw Exception('Disease model not loaded. Call initializeDiseaseModel() first.');
    }

    try {
      final inputBuffer = await _preprocessImage(imageFile);
      final outputShape = _diseaseInterpreter!.getOutputTensor(0).shape;
      final outputBuffer = List.generate(
        1,
        (_) => List<double>.filled(outputShape[1], 0.0),
      );

      _diseaseInterpreter!.run(inputBuffer, outputBuffer);

      final predictions = outputBuffer[0];
      final topPredictions = _getTopPredictions(predictions, _diseaseLabels, 3);

      return OfflinePrediction(
        primaryClass: topPredictions.first.label,
        confidence: topPredictions.first.confidence,
        topPredictions: topPredictions,
      );
    } catch (e) {
      print('Error during disease classification: $e');
      rethrow;
    }
  }

  /// Preprocess image for model input
  Future<List<List<List<List<double>>>>> _preprocessImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to model input size
    final resizedImage = img.copyResize(
      originalImage,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Convert to normalized float array [1, height, width, channels]
    final inputBuffer = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );

    return inputBuffer;
  }

  /// Get top N predictions with their labels
  List<PredictionItem> _getTopPredictions(
    List<double> predictions,
    List<String> labels,
    int topN,
  ) {
    final indexed = List.generate(
      predictions.length,
      (index) => MapEntry(index, predictions[index]),
    );

    indexed.sort((a, b) => b.value.compareTo(a.value));

    return indexed.take(topN).map((entry) {
      final label = entry.key < labels.length ? labels[entry.key] : 'Unknown';
      return PredictionItem(
        label: label,
        confidence: (entry.value * 100).clamp(0.0, 100.0),
      );
    }).toList();
  }

  /// Dispose resources
  void dispose() {
    _breedInterpreter?.close();
    _diseaseInterpreter?.close();
    _breedInterpreter = null;
    _diseaseInterpreter = null;
    _isBreedModelLoaded = false;
    _isDiseaseModelLoaded = false;
  }

  bool get isBreedModelLoaded => _isBreedModelLoaded;
  bool get isDiseaseModelLoaded => _isDiseaseModelLoaded;
}

/// Offline prediction result
class OfflinePrediction {
  final String primaryClass;
  final double confidence;
  final List<PredictionItem> topPredictions;

  OfflinePrediction({
    required this.primaryClass,
    required this.confidence,
    required this.topPredictions,
  });

  String get formattedResult {
    if (confidence < 50.0) {
      return 'Low confidence prediction. Please try with a clearer image.';
    }
    return '$primaryClass (${confidence.toStringAsFixed(1)}% confidence)';
  }
}

/// Individual prediction item
class PredictionItem {
  final String label;
  final double confidence;

  PredictionItem({
    required this.label,
    required this.confidence,
  });
}

