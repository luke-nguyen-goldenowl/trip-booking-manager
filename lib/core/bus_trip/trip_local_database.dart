import 'package:bus_ticket_app/models/result_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'dart:convert';

class TripLocalDatabase {
  static final TripLocalDatabase _instance = TripLocalDatabase._internal();
  factory TripLocalDatabase() => _instance;
  TripLocalDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'trips.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE trips (
            id INTEGER PRIMARY KEY,
            route_id INTEGER,
            bus_id INTEGER,
            company_id INTEGER,
            price INTEGER,
            departure_time TEXT,
            arrival_time TEXT,
            status TEXT,
            seat_layout TEXT
          )
        ''');
        },
      );
    } catch (e) {
      throw MResult.exception(e);
    }
  }

  Future<void> saveTrips(List<MTrip> trips) async {
    try {
      final db = await database;
      await db.delete('trips');
      for (var trip in trips) {
        final map = trip.toMapLocaldb();
        if (map['seat_layout'] != null && map['seat_layout'] is! String) {
          map['seat_layout'] = jsonEncode(map['seat_layout']);
        }

        await db.insert('trips', map);
      }
    } catch (e) {
      throw MResult.exception(e);
    }
  }

  Future<List<MTrip>> getTrips() async {
    try {
      final db = await database;
      final maps = await db.query('trips');
      return maps.map((map) {
        final mutableMap = Map<String, dynamic>.from(map);

        if (mutableMap['seat_layout'] != null &&
            mutableMap['seat_layout'] is String) {
          try {
            mutableMap['seat_layout'] = jsonDecode(
              mutableMap['seat_layout'] as String,
            );
          } catch (e) {
            mutableMap['seat_layout'] = null;
          }
        }
        return MTrip.fromMap(mutableMap);
      }).toList();
    } catch (e) {
      throw MResult.exception(e);
    }
  }
}
