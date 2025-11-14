import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../entities/hydration_model.dart';

class HydrationDB {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hydration.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE hydration (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            quantity REAL,
            date TEXT
          )
        ''');
      },
    );
  }
  static Future<List<Map<String, dynamic>>> getLast7DaysTotals(int userId) async {
    final db = await database;
    final res = await db.rawQuery('''
    SELECT date, SUM(quantity) as total
    FROM hydration
    WHERE userId = ?
    GROUP BY date
    ORDER BY date DESC
    LIMIT 7
  ''', [userId]);
    return res;
  }

  // CREATE
  static Future<int> addEntry(HydrationEntry entry) async {
    final db = await database;
    return await db.insert('hydration', entry.toMap());
  }

  // READ (toutes les entrées)
  static Future<List<HydrationEntry>> getAllEntries(int userId) async {
    final db = await database;
    final res = await db.query('hydration', where: 'userId = ?', whereArgs: [userId]);
    return res.map((e) => HydrationEntry.fromMap(e)).toList();
  }

  // READ (filtré par date)
  static Future<List<HydrationEntry>> getEntriesForDate(int userId, String date) async {
    final db = await database;
    final res = await db.query('hydration', where: 'userId = ? AND date = ?', whereArgs: [userId, date]);
    return res.map((e) => HydrationEntry.fromMap(e)).toList();
  }

  // UPDATE
  static Future<int> updateEntry(HydrationEntry entry) async {
    final db = await database;
    return await db.update(
      'hydration',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // DELETE
  static Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete('hydration', where: 'id = ?', whereArgs: [id]);
  }
}
