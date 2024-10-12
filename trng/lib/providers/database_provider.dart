import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String path = join(await getDatabasesPath(), 'trng.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> addUser(String name, String email) async {
  final db = await database; // Get the database instance
  await db.insert(
    'User',
    {'name': name, 'email': email},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
  Stream<List<Map<String, dynamic>>> get usersStream async* {
    final db = await database;
    yield* Stream.periodic(Duration(seconds: 1), (_) async {
      return await db.query('users');
    }).asyncMap((event) async => await event);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE User (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE Session (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        start_time TEXT,
        end_time TEXT,
        FOREIGN KEY (user_id) REFERENCES User (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE TrngData (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        data TEXT,
        timestamp TEXT,
        FOREIGN KEY (session_id) REFERENCES Session (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE Program (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER,
        phase TEXT,
        description TEXT,
        FOREIGN KEY (session_id) REFERENCES Session (id)
      )
    ''');
  }
}
