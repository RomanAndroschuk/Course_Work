import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService{
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async{
    if(_db != null) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  Future<Database> getDatabase() async {
  if (_db != null) return _db!;

  final dataseDirPath = await getDatabasesPath();
  final databasePath = join(dataseDirPath, "my_db.db");
  
  _db = await openDatabase(
    databasePath,
    version: 3,
    onCreate: (db, version) {
      
      db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          password TEXT NOT NULL,
          email TEXT NOT NULL
        );
      '''); 
      db.execute('''
        CREATE TABLE calculations(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          expression TEXT NOT NULL
          
        );
      ''');
      
    },
  );

  return _db!;
}


  Future<void> addUser(String user, password, email) async{
    final db = await database;
    await db.insert("users", {
      "name": user,
      "password" : password,
      "email" : email,
    });
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> addCalculation(int userId, String expression) async {
  final db = await database;

  await db.insert("calculations", {
    "user_id": userId,
    "expression": expression,
  });

}


  Future<List<Map<String, dynamic>>> getUserCalculations(int userId) async {
    final db = await database;
    return await db.query(
      "calculations",
      where: "user_id = ?",
      whereArgs: [userId],
      orderBy: "id DESC",
    );
  }

  Future<void> deleteUserByEmail(String email) async {
    final db = await database;
    await db.delete(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );
  }



}