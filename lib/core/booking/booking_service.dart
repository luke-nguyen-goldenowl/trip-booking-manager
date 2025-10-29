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
      return MBooking.fromMap(response);
    } catch (e) {
      throw Exception('Không thể tạo booking: $e');
    }
  }
}
