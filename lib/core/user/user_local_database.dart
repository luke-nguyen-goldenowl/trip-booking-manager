import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bus_ticket_app/models/user_model.dart';

class UserLocalDatabase {
  static final UserLocalDatabase _instance = UserLocalDatabase._internal();
  factory UserLocalDatabase() => _instance;
  UserLocalDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            email TEXT,
            full_name TEXT,
            phone TEXT,
            role TEXT,
            created_at DATETIME,
            avatar_url TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveUsers(List<MUser> users) async {
    final db = await database;
    await db.delete('users');
    for (var user in users) {
      await db.insert('users', user.toMapLocaldb());
    }
  }

  Future<MUser?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return MUser.fromMapLocaldb(maps.first);
    }
    return null;
  }

  Future<MUser?> getCompanyUserById(int companyId) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ? AND role = ?',
      whereArgs: [companyId, 'Nhà xe'],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return MUser.fromMapLocaldb(maps.first);
    }
    return null;
  }

  Future<List<MUser>> getUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((map) => MUser.fromMapLocaldb(map)).toList();
  }
}
