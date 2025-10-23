import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/trip_model.dart';

class BusTripService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MTrip>> getTripsByCompany(int companyId) async {
    try {
      final response = await _supabase
          .from('trips')
          .select()
          .eq('company_id', companyId)
          .order('departure_time', ascending: false);

      return (response as List).map((trip) => MTrip.fromMap(trip)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách chuyến đi');
    }
  }

  Future<MTrip> createTrip(MTrip trip) async {
    try {
      final response =
          await _supabase.from('trips').insert(trip.toMap()).select().single();

      return MTrip.fromMap(response);
    } catch (e) {
      throw Exception('Không thể thêm chuyến đi');
    }
  }

  Future<void> updateTrip(int tripId, MTrip trip) async {
    try {
      await _supabase.from('trips').update(trip.toMap()).eq('id', tripId);
    } catch (e) {
      throw Exception('Không thể cập nhật chuyến đi');
    }
  }

  Future<void> deleteTrip(int tripId) async {
    try {
      await _supabase.from('trips').delete().eq('id', tripId);
    } catch (e) {
      throw Exception('Không thể xóa chuyến đi');
    }
  }

  Future<bool> checkBusAvailability({
    required int busId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    int? excludeTripId,
  }) async {
    try {
      var query = _supabase
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
      throw Exception('Không thể kiểm tra lịch xe');
    }
  }
}
