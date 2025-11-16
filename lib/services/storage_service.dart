import 'package:hive_flutter/hive_flutter.dart';
import 'package:pashu_swasthya/models/prediction_history.dart';

class StorageService {
  static const String _historyBoxName = 'prediction_history';
  static const String _settingsBoxName = 'app_settings';
  
  Box? _historyBox;
  Box? _settingsBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    // Open boxes (Hive.initFlutter() is called in main.dart)
    _historyBox = await Hive.openBox(_historyBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _initialized = true;
  }

  // Prediction History Methods
  Future<void> savePrediction(PredictionHistory prediction) async {
    if (!_initialized) await init();
    await _historyBox!.put(prediction.id, prediction.toMap());
  }

  Future<List<PredictionHistory>> getPredictionHistory() async {
    if (!_initialized) await init();
    final maps = _historyBox!.values.toList();
    return maps.map((map) => PredictionHistory.fromMap(Map<String, dynamic>.from(map as Map))).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> deletePrediction(String id) async {
    if (!_initialized) await init();
    await _historyBox!.delete(id);
  }

  Future<void> clearHistory() async {
    if (!_initialized) await init();
    await _historyBox!.clear();
  }

  // Settings Methods
  Future<void> saveLanguagePreference(String languageCode) async {
    if (!_initialized) await init();
    await _settingsBox!.put('language', languageCode);
  }

  Future<String?> getLanguagePreference() async {
    if (!_initialized) await init();
    return _settingsBox!.get('language') as String?;
  }

  Future<void> saveUserPreference(String key, dynamic value) async {
    if (!_initialized) await init();
    await _settingsBox!.put(key, value);
  }

  dynamic getUserPreference(String key) {
    if (!_initialized) return null;
    return _settingsBox!.get(key);
  }

  void dispose() {
    _historyBox?.close();
    _settingsBox?.close();
    _initialized = false;
  }
}

