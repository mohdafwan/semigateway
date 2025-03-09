import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  void _createDb(Database db, int newVersion) async {
    await db.execute('''
      CREATE TABLE last_change_time (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            time TEXT
          )
    ''');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  // Insert
  Future<void> saveLastChangeTime(String time) async {
    final db = await database;
    await db.insert(
      'last_change_time',
      {'time': time},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getLastChangeTime() async {
    final db = await database;
    final List<Map<String,dynamic>> maps = await db.query('last_change_time');
    if(maps.isNotEmpty){
      return maps.first['time'] as String?;
    } 
    return null; 
  }
}
