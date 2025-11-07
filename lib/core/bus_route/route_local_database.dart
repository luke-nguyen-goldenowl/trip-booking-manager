import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bus_ticket_app/models/route_model.dart';

class RouteLocalDatabase {
  static final RouteLocalDatabase _instance = RouteLocalDatabase._internal();
  factory RouteLocalDatabase() => _instance;
  RouteLocalDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'routes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE routes (
            id INTEGER PRIMARY KEY,
            company_id INTEGER,
            departure TEXT,
            destination TEXT,
            distance_km INTEGER,
            status TEXT
          )
        ''');
      },
    );
  }

  Future<void> saveRoutes(List<MRoute> routes) async {
    final db = await database;
    await db.delete('routes');
    for (var route in routes) {
      final map = route.toMapLocaldb();
      await db.insert('routes', map);
    }
  }

  Future<List<MRoute>> getRoutes() async {
    final db = await database;
    final maps = await db.query('routes');
    return maps.map((map) => MRoute.fromMap(map)).toList();
  }

  Future<void> clearRoutes() async {
    final db = await database;
    await db.delete('routes');
  }
}
