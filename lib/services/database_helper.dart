import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._privateConstructor();
  static DatabaseHelper get instance =>
      _instance ??= DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(path, version: 1, onCreate: _createTable);
  }

  /// ဇယား ဖန်တီးခြင်း
  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        category TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at INTEGER
      )
    ''');
  }

  /// အလုပ်အသစ် ထည့်ခြင်း
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;

    // created_at ကို အလိုအလျောက် ထည့်ပေးမယ်
    final taskWithDate = Map<String, dynamic>.from(task);
    taskWithDate['created_at'] = DateTime.now().millisecondsSinceEpoch;

    return await db.insert('tasks', taskWithDate);
  }

  /// အလုပ်များ အားလုံး ယူခြင်း (အသစ်ဆုံး အရင်)
  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'created_at DESC');
  }

  /// အလုပ်တစ်ခု ပြင်ခြင်း
  Future<int> updateTask(int id, Map<String, dynamic> task) async {
    final db = await database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [id]);
  }

  /// အလုပ်တစ်ခု ဖျက်ခြင်း
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// ပြီးစီးပြီး အလုပ်များ ယူခြင်း
  Future<List<Map<String, dynamic>>> getCompletedTasks() async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'is_completed = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
  }

  /// မပြီးသေး အလုပ်များ ယူခြင်း
  Future<List<Map<String, dynamic>>> getPendingTasks() async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'is_completed = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
  }

  /// သတ်မှတ် category ရဲ့ အလုပ်များ
  Future<List<Map<String, dynamic>>> getTasksByCategory(String category) async {
    final db = await database;
    return await db.query(
      'tasks',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }
}
