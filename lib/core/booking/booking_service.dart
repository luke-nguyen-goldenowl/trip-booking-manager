import 'package:bus_ticket_app/utils/helper/booking_helper.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/booking_model.dart';
import 'package:bus_ticket_app/core/email/email_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bus_ticket_app/constants/payment_url.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';

class BookingService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<MBooking> createBookingbyCash(MBooking booking) async {
    try {
      for (final seatId in booking.seats!.split(',')) {
        final isSeatBooked = await _isSeatBooked(
          booking.tripId!,
          seatId.trim(),
        );
        if (isSeatBooked) {
          return Future.error(
            'Ghế $seatId đã được đặt. Vui lòng chọn ghế khác.',
          );
        }
      }
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

  Future<MBooking?> createBookingbyMomo(MBooking booking) async {
    try {
      final bookingData = booking.toMap();
      bookingData.remove('id');
      final response =
          await _supabase
              .from('bookings')
              .insert(bookingData)
              .select()
              .single();
      await _paymentWithMomo(booking);
      return MBooking.fromMap(response);
    } catch (e) {
      throw Exception('Không thể tạo booking: $e');
    }
  }

  Future<void> _paymentWithMomo(MBooking booking) async {
    try {
      final bookingData = booking.toMap();
      bookingData.remove('id');
      final momoResponse = await http.post(
        Uri.parse(MOMO_URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': bookingData['booking_code'],
          'amount': booking.totalPrice,
          'orderInfo':
              'Thanh toán đơn hàng vé xe khách ${bookingData['booking_code']}',
        }),
      );

      final data = jsonDecode(momoResponse.body);
      if (data != null && data['payUrl'] != null) {
        await launchUrl(
          Uri.parse(data['payUrl']),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      throw Exception('Không thể tạo booking: $e');
    }
  }

  Future<void> markEmailSent(int bookingId) async {
    try {
      await _supabase
          .from('bookings')
          .update({'isMailSended': true})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Không thể đánh dấu email đã gửi: $e');
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
      if (fullBookingData['isMailSended'] == true) {
        return;
      }
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
      await markEmailSent(bookingId);
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
          .eq('user_id', userId)
          .order('created_at', ascending: false);
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

  Future<bool> _isSeatBooked(int tripId, String seatId) async {
    try {
      final response =
          await _supabase
              .from('trips')
              .select('seat_layout')
              .eq('id', tripId)
              .single();

      final seatLayout = response['seat_layout'] as Map<String, dynamic>?;
      if (seatLayout == null || seatLayout['seats'] == null) return false;

      final seats = seatLayout['seats'] as List;

      for (var seat in seats) {
        if (seat is! Map<String, dynamic>) continue;

        final currentSeatId = seat['id']?.toString();
        final isBooked = seat['isBooked'] as bool? ?? false;

        if (currentSeatId == seatId) {
          return isBooked;
        }
      }

      return false;
    } catch (e) {
      throw Exception('Không thể kiểm tra trạng thái ghế: $e');
    }
  }
}
