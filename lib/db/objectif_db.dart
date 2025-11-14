import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../entities/Objectif.dart';


class ObjectiveDB {
  static Database? _database;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'objectives.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE objectives(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          date TEXT,
          completed INTEGER
        )
      ''');
    });
  }

  static Future<int> addObjective(Objective obj) async {
    final db = await getDatabase();
    return await db.insert('objectives', obj.toMap());
  }

  static Future<List<Objective>> getObjectives(String date) async {
    final db = await getDatabase();
    final res = await db.query('objectives', where: 'date = ?', whereArgs: [date]);
    return res.map((e) => Objective.fromMap(e)).toList();
  }

  static Future<int> updateObjective(Objective obj) async {
    final db = await getDatabase();
    return await db.update('objectives', obj.toMap(), where: 'id = ?', whereArgs: [obj.id]);
  }

  static Future<int> deleteObjective(int id) async {
    final db = await getDatabase();
    return await db.delete('objectives', where: 'id = ?', whereArgs: [id]);
  }
}
