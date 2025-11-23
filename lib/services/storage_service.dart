import 'package:pashu_swasthya/models/prediction_history.dart';
import 'package:pashu_swasthya/services/database_helper.dart';

class StorageService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    // DatabaseHelper initializes itself lazily, so we just mark as initialized
    _initialized = true;
  }

  // Prediction History Methods
  Future<void> savePrediction(PredictionHistory prediction) async {
    await _dbHelper.insertPrediction(prediction);
  }

  Future<List<PredictionHistory>> getPredictionHistory() async {
    return await _dbHelper.getPredictionHistory();
  }

  Future<void> deletePrediction(String id) async {
    await _dbHelper.deletePrediction(id);
  }

  Future<void> clearHistory() async {
    await _dbHelper.clearHistory();
  }

  // Settings Methods
  Future<void> saveLanguagePreference(String languageCode) async {
    await _dbHelper.saveSetting('language', languageCode);
  }

  Future<String?> getLanguagePreference() async {
    return await _dbHelper.getSetting('language');
  }

  Future<void> saveUserPreference(String key, dynamic value) async {
    await _dbHelper.saveSetting(key, value.toString());
  }

  Future<dynamic> getUserPreference(String key) async {
    // Note: This returns a Future now, unlike the synchronous Hive version.
    // Callers might need to await this.
    // Also, it returns String, so callers expecting other types might need to parse.
    return await _dbHelper.getSetting(key);
  }

  void dispose() {
    // No specific dispose needed for SQLite helper as it manages its own connection
    _initialized = false;
  }
}

