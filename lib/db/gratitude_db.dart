import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../entities/Gratitude.dart';


class GratitudeDB {
  static Database? _db;

  static Future<Database> getDb() async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  static Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'wellcare.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE gratitude (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER,
          content TEXT,
          date TEXT
        )
      ''');
    });
  }

  static Future<int> addEntry(GratitudeEntry entry) async {
    final db = await getDb();
    return await db.insert('gratitude', entry.toMap());
  }

  static Future<List<GratitudeEntry>> getEntries(int userId, String date) async {
    final db = await getDb();
    final result = await db.query(
      'gratitude',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, date],
    );
    return result.map((e) => GratitudeEntry.fromMap(e)).toList();
  }

  static Future<int> updateEntry(GratitudeEntry entry) async {
    final db = await getDb();
    return await db.update('gratitude', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  static Future<int> deleteEntry(int id) async {
    final db = await getDb();
    return await db.delete('gratitude', where: 'id = ?', whereArgs: [id]);
  }
}
