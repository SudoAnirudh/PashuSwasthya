import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

/// Roboflow Service for online breed and disease classification
class RoboflowService {
  static const String _apiKey = 'QeWAo5gSXC1Eq6DuYAeD';
  static const String _breedProject = 'cattle-breed-classifier-zkn1l';
  static const String _diseaseProject = 'disease-detector-zbjtj';
  static const int _version = 1;

  /// Check if device is online
  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }

  /// Classify breed using Roboflow API
  Future<RoboflowPrediction> classifyBreed(File imageFile) async {
    final isConnected = await isOnline();
    if (!isConnected) {
      throw Exception('No internet connection. Please use offline mode.');
    }

    try {
      final url = Uri.parse(
        'https://detect.roboflow.com/$_breedProject/$_version?api_key=$_apiKey',
      );

      final request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseRoboflowResponse(data);
      } else {
        throw Exception(
          'Roboflow API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      }
      rethrow;
    }
  }

  /// Classify disease using Roboflow API
  Future<RoboflowPrediction> classifyDisease(File imageFile) async {
    final isConnected = await isOnline();
    if (!isConnected) {
      throw Exception('No internet connection. Please use offline mode.');
    }

    try {
      final url = Uri.parse(
        'https://detect.roboflow.com/$_diseaseProject/$_version?api_key=$_apiKey',
      );

      final request = http.MultipartRequest('POST', url);
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseRoboflowResponse(data);
      } else {
        throw Exception(
          'Roboflow API error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Request timeout. Please check your internet connection.');
      }
      rethrow;
    }
  }

  /// Parse Roboflow API response
  RoboflowPrediction _parseRoboflowResponse(Map<String, dynamic> data) {
    final predictions = data['predictions'] as List<dynamic>? ?? [];

    if (predictions.isEmpty) {
      return RoboflowPrediction(
        primaryClass: 'Unknown',
        confidence: 0.0,
        topPredictions: [],
      );
    }

    // Sort by confidence
    predictions.sort((a, b) {
      final confA = (a['confidence'] as num?)?.toDouble() ?? 0.0;
      final confB = (b['confidence'] as num?)?.toDouble() ?? 0.0;
      return confB.compareTo(confA);
    });

    final primary = predictions.first;
    final primaryClass = primary['class'] as String? ?? 'Unknown';
    final primaryConfidence =
        ((primary['confidence'] as num?)?.toDouble() ?? 0.0) * 100;

    final topPredictions = predictions.take(3).map((pred) {
      return PredictionItem(
        label: pred['class'] as String? ?? 'Unknown',
        confidence: ((pred['confidence'] as num?)?.toDouble() ?? 0.0) * 100,
      );
    }).toList();

    return RoboflowPrediction(
      primaryClass: primaryClass,
      confidence: primaryConfidence,
      topPredictions: topPredictions,
    );
  }
}

/// Roboflow prediction result
class RoboflowPrediction {
  final String primaryClass;
  final double confidence;
  final List<PredictionItem> topPredictions;

  RoboflowPrediction({
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

