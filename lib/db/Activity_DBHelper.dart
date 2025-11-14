import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../entities/Activity_Model.dart';

class ActivityDBHelper {
  static final ActivityDBHelper _instance = ActivityDBHelper._internal();
  static Database? _database;

  ActivityDBHelper._internal();
  factory ActivityDBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    String path = join(await getDatabasesPath(), 'activity.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        duration INTEGER,
        calories INTEGER,
        date TEXT
      )
    ''');
  }

  // CREATE
  Future<int> insertActivity(Activity a) async {
    final dbClient = await database;
    return await dbClient.insert('activities', a.toMap());
  }

  // READ all activities
  Future<List<Activity>> getActivities() async {
    final dbClient = await database;
    final res = await dbClient.query('activities', orderBy: 'id DESC');
    return res.map((m) => Activity.fromMap(m)).toList();
  }

  // READ favorite activity (most frequent type)
  Future<Map<String, dynamic>?> getFavoriteActivity() async {
    final dbClient = await database;
    final res = await dbClient.rawQuery('''
      SELECT type, COUNT(*) as count
      FROM activities
      GROUP BY type
      ORDER BY count DESC
      LIMIT 1
    ''');
    if (res.isNotEmpty) return res.first;
    return null;
  }

  // UPDATE
  Future<int> updateActivity(Activity a) async {
    final dbClient = await database;
    return await dbClient.update(
      'activities',
      a.toMap(),
      where: 'id = ?',
      whereArgs: [a.id],
    );
  }

  // DELETE
  Future<int> deleteActivity(int id) async {
    final dbClient = await database;
    return await dbClient.delete('activities', where: 'id = ?', whereArgs: [id]);
  }
}
