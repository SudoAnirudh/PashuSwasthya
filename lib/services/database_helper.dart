import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pashu_swasthya/models/prediction_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pashu_swasthya.db');

    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mobile_number TEXT NOT NULL,
        user_name TEXT,
        user_place TEXT,
        is_logged_in INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE prediction_history (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        result TEXT NOT NULL,
        confidence REAL NOT NULL,
        timestamp TEXT NOT NULL,
        imagePath TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE prediction_history (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          result TEXT NOT NULL,
          confidence REAL NOT NULL,
          timestamp TEXT NOT NULL,
          imagePath TEXT,
          notes TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE app_settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
    }
    
    if (oldVersion < 4) {
      // Check if columns exist before adding them to avoid errors if upgrading from v2 to v4 directly
      // However, SQLite doesn't support IF NOT EXISTS for ADD COLUMN easily in all versions.
      // Since we are controlling the versions, we can just add them.
      // But for safety, we can try-catch or just execute.
      // A safer way for SQLite is to check pragma table_info, but for simplicity here:
      try {
        await db.execute('ALTER TABLE user_session ADD COLUMN user_name TEXT');
        await db.execute('ALTER TABLE user_session ADD COLUMN user_place TEXT');
      } catch (e) {
        // Columns might already exist if dev environment was messy, ignore
        print('Error adding columns: $e');
      }
    }

    if (oldVersion < 5) {
      // Fix for user data not saving: Recreate user_session table to ensure schema is correct
      await db.execute('DROP TABLE IF EXISTS user_session');
      await db.execute('''
        CREATE TABLE user_session (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mobile_number TEXT NOT NULL,
          user_name TEXT,
          user_place TEXT,
          is_logged_in INTEGER NOT NULL
        )
      ''');
    }
  }

  // User Session Methods
  Future<int> loginUser(String mobileNumber, {String? userName, String? userPlace}) async {
    final db = await database;
    // Clear previous sessions just in case
    await db.delete('user_session');
    return await db.insert('user_session', {
      'mobile_number': mobileNumber,
      'user_name': userName,
      'user_place': userPlace,
      'is_logged_in': 1,
    });
  }

  Future<bool> isUserLoggedIn() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_session');
    if (maps.isNotEmpty) {
      return maps.first['is_logged_in'] == 1;
    }
    return false;
  }

  Future<void> logoutUser() async {
    final db = await database;
    await db.delete('user_session');
  }
  
  Future<Map<String, String?>> getUserDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_session');
    if (maps.isNotEmpty) {
      return {
        'mobile_number': maps.first['mobile_number'] as String,
        'user_name': maps.first['user_name'] as String?,
        'user_place': maps.first['user_place'] as String?,
      };
    }
    return {};
  }

  // Prediction History Methods
  Future<int> insertPrediction(PredictionHistory prediction) async {
    final db = await database;
    return await db.insert(
      'prediction_history',
      prediction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PredictionHistory>> getPredictionHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('prediction_history', orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) {
      return PredictionHistory.fromMap(maps[i]);
    });
  }

  Future<int> deletePrediction(String id) async {
    final db = await database;
    return await db.delete(
      'prediction_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('prediction_history');
  }

  // App Settings Methods
  Future<int> saveSetting(String key, String value) async {
    final db = await database;
    return await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }
}
