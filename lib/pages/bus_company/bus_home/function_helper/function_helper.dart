import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/trip_model.dart';

class FunctionHelper {
  static List<MTrip> getTodayTrips(List<MTrip> allTrips) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return allTrips
        .where(
          (trip) =>
              trip.departureTime != null &&
              trip.departureTime!.isAfter(todayStart) &&
              trip.departureTime!.isBefore(todayEnd),
        )
        .toList()
      ..sort((a, b) => a.departureTime!.compareTo(b.departureTime!));
  }

  static Map<String, dynamic> calculateDailyStats(
    List<MTrip> trips,
    Map<int, MRoute> routeMap,
  ) {
    final bookedSeats = countBookedSeats(trips);
    final totalSeats = countTotalSeats(trips);
    final revenue = calculateRevenue(trips, routeMap);
    final occupancyRate = calculateOccupancyRate(bookedSeats, totalSeats);

    return {
      'revenue': revenue,
      'bookedSeats': bookedSeats,
      'tripCount': trips.length,
      'occupancyRate': occupancyRate,
    };
  }

  static int countBookedSeats(List<dynamic> trips) {
    int total = 0;
    for (var trip in trips) {
      if (trip.seatLayout != null && trip.seatLayout!['seats'] is List) {
        final seats = trip.seatLayout!['seats'] as List;
        total += seats.where((s) => s['isBooked'] == true).length;
      }
    }
    return total;
  }

  static int countTotalSeats(List<dynamic> trips) {
    int total = 0;
    for (var trip in trips) {
      if (trip.seatLayout != null && trip.seatLayout!['seats'] is List) {
        final seats = trip.seatLayout!['seats'] as List;
        total += seats.length;
      }
    }
    return total;
  }

  static double calculateRevenue(
    List<dynamic> trips,
    Map<int, dynamic> routeMap,
  ) {
    double total = 0;
    for (var trip in trips) {
      if (trip.routeId != null && trip.seatLayout != null) {
        if (trip.price != null) {
          final seats = trip.seatLayout!['seats'] as List? ?? [];
          final bookedSeats = seats.where((s) => s['isBooked'] == true).length;
          total += bookedSeats * trip.price!;
        }
      }
    }
    return total;
  }

  static double calculateOccupancyRate(int bookedSeats, int totalSeats) {
    return totalSeats > 0 ? (bookedSeats / totalSeats * 100) : 0.0;
  }

  static Map<String, int> getTripSeatStats(dynamic trip) {
    int booked = 0;
    int total = 0;

    if (trip.seatLayout != null && trip.seatLayout!['seats'] is List) {
      final seats = trip.seatLayout!['seats'] as List;
      total = seats.length;
      booked = seats.where((s) => s['isBooked'] == true).length;
    }

    return {'booked': booked, 'total': total};
  }

  static List<Map<String, dynamic>> calculateRouteStats(
    List<MTrip> trips,
    Map<int, MRoute> routeMap,
  ) {
    final Map<int, List<MTrip>> routeTrips = {};
    for (var trip in trips) {
      if (trip.routeId != null) {
        routeTrips.putIfAbsent(trip.routeId!, () => []).add(trip);
      }
    }

    return routeTrips.entries.map((entry) {
        return {
          'routeId': entry.key,
          'tripCount': entry.value.length,
          'revenue': calculateRevenue(entry.value, routeMap),
        };
      }).toList()
      ..sort(
        (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double),
      );
  }

  static List<MTrip> filterTripsForDate(
    List<MTrip> allTrips,
    DateTime currentDate,
  ) {
    final dayStart = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));

    return allTrips.where((trip) {
        return trip.departureTime != null &&
            trip.departureTime!.isAfter(dayStart) &&
            trip.departureTime!.isBefore(dayEnd);
      }).toList()
      ..sort((a, b) => a.departureTime!.compareTo(b.departureTime!));
  }

  static Map<String, dynamic> calculateDayStatistics(
    List<MTrip> dayTrips,
    Map<int, MRoute> routeMap,
  ) {
    final bookedSeats = countBookedSeats(dayTrips);
    final totalSeats = countTotalSeats(dayTrips);
    final occupancyRate = calculateOccupancyRate(bookedSeats, totalSeats);
    final revenue = calculateRevenue(dayTrips, routeMap);

    return {
      'revenue': revenue,
      'bookedSeats': bookedSeats,
      'tripCount': dayTrips.length,
      'occupancyRate': occupancyRate,
    };
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String getDateLabel(bool isToday, bool isPast) {
    if (isToday) return 'Hôm nay';
    if (isPast) return 'Quá khứ';
    return 'Tương lai';
  }
}
