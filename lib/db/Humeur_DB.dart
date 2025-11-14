import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../entities/humeur.dart';

class HumeurDB {
  static final HumeurDB _instance = HumeurDB._internal();
  factory HumeurDB() => _instance;
  HumeurDB._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('humeurs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE humeurs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        niveau INTEGER NOT NULL,
        commentaire TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> addHumeur(Humeur humeur) async {
    final db = await database;
    await db.insert(
      'humeurs',
      humeur.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateHumeur(String id, Humeur humeur) async {
    final db = await database;
    await db.update(
      'humeurs',
      humeur.toMap(),
      where: 'id = ?',
      whereArgs: [int.parse(id)], // SQLite id est int
    );
  }

  Future<void> deleteHumeur(String id) async {
    final db = await database;
    await db.delete(
      'humeurs',
      where: 'id = ?',
      whereArgs: [int.parse(id)],
    );
  }

  Future<List<Humeur>> getHumeurs() async {
    final db = await database;
    final result = await db.query('humeurs');
    return result.map((json) => Humeur.fromMap(json)).toList();
  }
}
