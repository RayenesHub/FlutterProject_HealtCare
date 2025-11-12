import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../entities/User_Model.dart';


class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'healthcare.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            email TEXT,
            password TEXT,
            age INTEGER,
            weight REAL
          )
        ''');
      },
    );
  }

  static Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<User?> getUser() async {
    final db = await database;
    final res = await db.query('users', limit: 1);
    return res.isNotEmpty ? User.fromMap(res.first) : null;
  }

  static Future<void> deleteAllUsers() async {
    final db = await database;
    await db.delete('users');
  }

  static Future<User?> getUserByEmailAndPassword(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    return res.isNotEmpty ? User.fromMap(res.first) : null;
  }
  static Future<User?> getUserById(int id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    return res.isNotEmpty ? User.fromMap(res.first) : null;
  }

  static Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}