import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/base_collection.dart';
import 'package:bus_ticket_app/models/result_model.dart';

class BusTripService extends BaseCollection<MTrip> {
  BusTripService(SupabaseClient supabase)
    : super(supabase: supabase, tableName: 'trips');

  Future<MResult<List<MTrip>>> getTripsByCompany(int companyId) async {
    return getAll(
      column: 'company_id',
      value: companyId,
      orderBy: 'departure_time',
      ascending: false,
    );
  }

  Future<MResult<MTrip>> createTrip(MTrip trip) async {
    return insert(trip);
  }

  Future<MResult<MTrip>> updateTrip(int tripId, MTrip trip) async {
    return update(trip.copyWith(id: tripId));
  }

  Future<MResult<void>> deleteTrip(int tripId) async {
    return delete(tripId);
  }

  Future<bool> checkBusAvailability({
    required int busId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    int? excludeTripId,
  }) async {
    try {
      var query = supabase
          .from('trips')
          .select()
          .eq('bus_id', busId)
          .neq('status', 'cancelled');

      if (excludeTripId != null) {
        query = query.neq('id', excludeTripId);
      }
      final response = await query;
      final trips =
          (response as List).map((trip) => MTrip.fromMap(trip)).toList();
      for (var trip in trips) {
        if (trip.departureTime != null && trip.arrivalTime != null) {
          final overlap =
              departureTime.isBefore(trip.arrivalTime!) &&
              trip.departureTime!.isBefore(arrivalTime);

          if (overlap) {
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  Future<MResult<List<MTrip>>> getRandomTrips(int limit) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await supabase
          .from('trips')
          .select(
            'id, status, route_id, bus_id, company_id, departure_time, arrival_time, price, seat_layout, routes:route_id(id, departure, destination), buses:bus_id(id, company_id, bus_number, type, seat_count, user:company_id(full_name, email, phone)))',
          )
          .eq('status', 'scheduled')
          .gt('departure_time', now)
          .order('departure_time', ascending: true)
          .limit(limit);
      final trips =
          (response as List).map((trip) => MTrip.fromMap(trip)).toList();
      return MResult.success(trips);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<List<MTrip>>> getAllTrips() async {
    return getAll();
  }

  Future<MResult<MTrip>> getTripById(int tripId) async {
    return get(tripId);
  }

  Future<MResult<List<Map<String, dynamic>>>> fetchBookedUsers(
    int tripId,
  ) async {
    try {
      final response = await supabase
          .from('bookings')
          .select('user_id, seats, user:user_id(full_name, email, phone)')
          .eq('trip_id', tripId);

      return MResult.success(
        (response as List)
            .map((booking) => booking as Map<String, dynamic>)
            .toList(),
      );
    } catch (e) {
      return MResult.exception(e);
    }
  }

  @override
  MTrip fromMap(Map<String, dynamic> map) {
    return MTrip.fromMap(map);
  }

  @override
  int getId(MTrip item) {
    return item.id!;
  }

  @override
  MTrip setId(MTrip item, int id) {
    return item.copyWith(id: id);
  }

  @override
  Map<String, dynamic> toMap(MTrip item) {
    return item.toMap();
  }
}
