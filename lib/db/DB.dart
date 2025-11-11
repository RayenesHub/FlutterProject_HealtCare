import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DB {

  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'cart.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMET, 
        title TEXT,
        image TEXT,
        description TEXT,
        price REAL
        )
        ''');
      },
    );
    print('DB path: $_db');
    return _db!;
  }

  static Future<void> addItem(String title, String image, String description,
      double price) async {
    final db = await database;
    await db.insert('cart', {
      'title': title,
      'image': image,
      'description': description,
      'price': price,
    });
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await database;
    return await db.query('cart');

  }

  static Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }
}

