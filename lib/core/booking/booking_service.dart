import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/booking_model.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<MBooking> createBookingbyCash(MBooking booking) async {
    try {
      final response =
          await _supabase
              .from('bookings')
              .insert(booking.toMap())
              .select()
              .single();
      final bookingId = response['id'];
      await handleAfterBooking(bookingId);
      return MBooking.fromMap(response);
    } catch (e) {
      throw Exception('Không thể tạo booking: $e');
    }
  }

  Future<void> handleAfterBooking(int bookingId) async {
    try {
      final fullBookingData =
          await _supabase
              .from('bookings')
              .select('''
            *,
            user:user_id (email, full_name),
            trip:trip_id (
              id,
              departure_time,
              seat_layout,
              route:route_id (departure, destination),
              bus:bus_id (bus_number),
              company:company_id (full_name, phone, avatar_url)
            )
          ''')
              .eq('id', bookingId)
              .single();

      final trip = fullBookingData['trip'];
      await _updateSeatLayout(
        tripId: trip['id'],
        bookedSeatsString: fullBookingData['seats'],
        currentSeatLayout: trip['seat_layout'],
      );
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<bool> _updateSeatLayout({
    required int tripId,
    required String bookedSeatsString,
    required Map<String, dynamic>? currentSeatLayout,
  }) async {
    try {
      if (bookedSeatsString.isEmpty ||
          currentSeatLayout == null ||
          currentSeatLayout.isEmpty) {
        return false;
      }
      final bookedSeats =
          bookedSeatsString
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

      if (bookedSeats.isEmpty) return false;

      final seats = currentSeatLayout['seats'];
      if (seats == null || seats is! List) return false;

      List<Map<String, dynamic>> updatedSeats = [];
      for (var seat in seats) {
        if (seat is! Map<String, dynamic>) continue;

        Map<String, dynamic> seatCopy = Map<String, dynamic>.from(seat);
        final seatId = seatCopy['id']?.toString();

        if (seatId != null && bookedSeats.contains(seatId)) {
          seatCopy['isBooked'] = true;
        }
        updatedSeats.add(seatCopy);
      }
      Map<String, dynamic> newSeatLayout = Map<String, dynamic>.from(
        currentSeatLayout,
      );
      newSeatLayout['seats'] = updatedSeats;

      await _supabase
          .from('trips')
          .update({'seat_layout': newSeatLayout})
          .eq('id', tripId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
