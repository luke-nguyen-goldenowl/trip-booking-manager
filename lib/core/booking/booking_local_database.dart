import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:bus_ticket_app/models/booking_model.dart';

class BookingLocalDatabase {
  static final BookingLocalDatabase _instance =
      BookingLocalDatabase._internal();
  factory BookingLocalDatabase() => _instance;
  BookingLocalDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'booking_offline.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE bookingOffline (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              trip_id INTEGER NOT NULL,
              total_price INTEGER NOT NULL,
              status TEXT NOT NULL,
              payment_method TEXT NOT NULL,
              seats TEXT NOT NULL,
              booking_code TEXT NOT NULL,
              created_at TEXT NOT NULL,
              is_mail_sended INTEGER DEFAULT 0
            )
          ''');
        },
      );
    } catch (e) {
      throw Exception('Lỗi');
    }
  }

  Future<void> saveOfflineBooking(MBooking booking) async {
    try {
      final db = await database;
      final bookingMap = booking.toMapLocaldb();
      await db.insert('bookingOffline', bookingMap);
    } catch (e) {
      throw Exception('Lỗi');
    }
  }

  Future<List<MBooking>> getOfflineBookings(int userId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'bookingOffline',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      return maps.map((map) {
        final bookingMap = Map<String, dynamic>.from(map);
        if (bookingMap.containsKey('is_mail_sended')) {
          bookingMap['isMailSended'] = bookingMap['is_mail_sended'] == 1;
          bookingMap.remove('is_mail_sended');
        }
        return MBooking.fromMap(bookingMap);
      }).toList();
    } catch (e) {
      throw Exception('Lỗi');
    }
  }

  Future<void> deleteOfflineTicket(int id) async {
    try {
      final db = await database;
      await db.delete('bookingOffline', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Lỗi');
    }
  }

  Future<void> deleteAllOfflineTickets() async {
    try {
      final db = await database;
      await db.delete('bookingOffline');
    } catch (e) {
      throw Exception('Lỗi');
    }
  }

  Future<MBooking?> getOfflineBookingByCode(String bookingCode) async {
    try {
      final db = await database;
      final maps = await db.query(
        'bookingOffline',
        where: 'booking_code = ?',
        whereArgs: [bookingCode],
        limit: 1,
      );

      if (maps.isEmpty) return null;

      final bookingMap = Map<String, dynamic>.from(maps.first);
      if (bookingMap.containsKey('is_mail_sended')) {
        bookingMap['isMailSended'] = bookingMap['is_mail_sended'] == 1;
        bookingMap.remove('is_mail_sended');
      }

      return MBooking.fromMap(bookingMap);
    } catch (e) {
      throw Exception('Lỗi');
    }
  }
}
