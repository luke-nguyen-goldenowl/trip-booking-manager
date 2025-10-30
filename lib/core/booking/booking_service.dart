import 'package:bus_ticket_app/utils/helper/booking_helper.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/booking_model.dart';
import 'package:bus_ticket_app/core/email/email_service.dart';

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
      final user = fullBookingData['user'];
      final route = trip['route'];
      final bus = trip['bus'];
      final company = trip['company'];

      await sendBookingConfirmationEmail(
        toEmail: user['email'],
        userName: user['full_name'] ?? 'Quý khách',
        bookingCode: fullBookingData['booking_code'],
        departure: route['departure'],
        destination: route['destination'],
        departureTime: FormatHelper.formatDateTime(trip['departure_time']),
        seats: fullBookingData['seats'],
        createdAt: FormatHelper.formatDateTime(fullBookingData['created_at']),
        totalPrice: fullBookingData['total_price'],
        companyName: company['full_name'],
        companyPhone: company['phone'],
        licensePlate: bus['bus_number'],
        companyLogo: company['avatar_url'],
        paymentMethod: BookingHelper.getPaymentMethodText(
          fullBookingData['payment_method'],
        ),
      );

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

  Future<bool> _releaseSeatLayout({
    required int tripId,
    required String bookedSeatsString,
  }) async {
    try {
      final response =
          await _supabase
              .from('trips')
              .select('seat_layout')
              .eq('id', tripId)
              .single();

      final seatLayout = response['seat_layout'] as Map<String, dynamic>?;
      if (seatLayout == null || seatLayout['seats'] == null) return false;

      final seatsToRelease =
          bookedSeatsString
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

      if (seatsToRelease.isEmpty) return false;

      final seats = seatLayout['seats'] as List;
      List<Map<String, dynamic>> updatedSeats = [];

      for (var seat in seats) {
        if (seat is! Map<String, dynamic>) continue;

        Map<String, dynamic> seatCopy = Map<String, dynamic>.from(seat);
        final seatId = seatCopy['id']?.toString();

        if (seatId != null && seatsToRelease.contains(seatId)) {
          seatCopy['isBooked'] = false;
        }

        updatedSeats.add(seatCopy);
      }

      Map<String, dynamic> newSeatLayout = Map<String, dynamic>.from(
        seatLayout,
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

  Future<List<MBooking>> getBookingbyUserId(int userId) async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .eq('user_id', userId);
      return (response as List)
          .map((booking) => MBooking.fromMap(booking))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy thông tin booking: $e');
    }
  }

  Future<void> _handleAfterCancellBooking(int bookingId) async {
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
      final user = fullBookingData['user'];
      final route = trip['route'];
      final bus = trip['bus'];
      final company = trip['company'];

      await sendBookingCancellationEmail(
        toEmail: user['email'],
        userName: user['full_name'] ?? 'Quý khách',
        bookingCode: fullBookingData['booking_code'],
        departure: route['departure'],
        destination: route['destination'],
        departureTime: FormatHelper.formatDateTime(trip['departure_time']),
        seats: fullBookingData['seats'],
        createdAt: FormatHelper.formatDateTime(fullBookingData['created_at']),
        totalPrice: fullBookingData['total_price'],
        companyName: company['full_name'],
        companyPhone: company['phone'],
        licensePlate: bus['bus_number'],
        companyLogo: company['avatar_url'],
        paymentMethod: BookingHelper.getPaymentMethodText(
          fullBookingData['payment_method'],
        ),
      );

      await _releaseSeatLayout(
        tripId: trip['id'],
        bookedSeatsString: fullBookingData['seats'],
      );
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
      await _handleAfterCancellBooking(bookingId);
    } catch (e) {
      throw Exception('Không thể hủy booking: $e');
    }
  }
}
