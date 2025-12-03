import 'package:bus_ticket_app/utils/helper/booking_helper.dart';
import 'package:bus_ticket_app/utils/helper/format_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/booking_model.dart';
import 'package:bus_ticket_app/models/base_collection.dart';
import 'package:bus_ticket_app/models/result_model.dart';
import 'package:bus_ticket_app/core/email/email_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bus_ticket_app/constants/payment_url.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';

class BookingService extends BaseCollection<MBooking> {
  BookingService(SupabaseClient supabase)
    : super(supabase: supabase, tableName: 'bookings');

  Future<MResult<List<MBooking>>> getBookingsByUserId(int userId) async {
    return getAll(
      column: 'user_id',
      value: userId,
      orderBy: 'created_at',
      ascending: false,
    );
  }

  Future<MResult<MBooking>> createBookingByCash(MBooking booking) async {
    try {
      final seatCheckResult = await _validateSeats(
        booking.tripId!,
        booking.seats!,
      );
      if (seatCheckResult.isError) {
        return MResult.error(seatCheckResult.error!);
      }

      final createResult = await insert(booking);
      if (createResult.isError) {
        return createResult;
      }

      final createdBooking = createResult.data!;
      await handleAfterBooking(createdBooking.id!);

      return MResult.success(createdBooking);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<MBooking>> createBookingByMomo(MBooking booking) async {
    try {
      final seatCheckResult = await _validateSeats(
        booking.tripId!,
        booking.seats!,
      );
      if (seatCheckResult.isError) {
        return MResult.error(seatCheckResult.error!);
      }

      final createResult = await insert(booking);
      if (createResult.isError) {
        return createResult;
      }

      final createdBooking = createResult.data!;
      final paymentResult = await _paymentWithMomo(createdBooking);
      if (paymentResult.isError) {
        return MResult.error(paymentResult.error!);
      }

      return MResult.success(createdBooking);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<void>> cancelBooking(int bookingId) async {
    try {
      final bookingResult = await get(bookingId);
      if (bookingResult.isError) {
        return MResult.error(bookingResult.error!);
      }

      final booking = bookingResult.data!;

      final tripResponse =
          await supabase
              .from('trips')
              .select('departure_time')
              .eq('id', booking.tripId!)
              .single();

      final departureTime = DateTime.parse(tripResponse['departure_time']);
      final currentTime = DateTime.now();

      if (departureTime.difference(currentTime).inHours < 3) {
        return MResult.error('Chỉ có thể hủy vé trước giờ khởi hành 3 tiếng');
      }

      await supabase
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
      await _handleAfterCancelBooking(bookingId);

      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> isSeatBooked(int tripId, String seatId) async {
    try {
      final response =
          await supabase
              .from('trips')
              .select('seat_layout')
              .eq('id', tripId)
              .single();

      final seatLayout = response['seat_layout'] as Map<String, dynamic>?;
      if (seatLayout == null || seatLayout['seats'] == null) {
        return MResult.success(false);
      }

      final seats = seatLayout['seats'] as List;

      for (var seat in seats) {
        if (seat is! Map<String, dynamic>) continue;

        final currentSeatId = seat['id']?.toString();
        final isBooked = seat['isBooked'] as bool? ?? false;

        if (currentSeatId == seatId) {
          return MResult.success(isBooked);
        }
      }

      return MResult.success(false);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<void>> _validateSeats(int tripId, String seatsString) async {
    try {
      final seatIds = seatsString.split(',').map((s) => s.trim()).toList();

      for (final seatId in seatIds) {
        final result = await isSeatBooked(tripId, seatId);
        if (result.isError) {
          return MResult.error(result.error!);
        }

        if (result.data == true) {
          return MResult.error(
            'Ghế $seatId đã được đặt. Vui lòng chọn ghế khác.',
          );
        }
      }

      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<void>> _updateSeatLayout({
    required int tripId,
    required String bookedSeatsString,
    required Map<String, dynamic>? currentSeatLayout,
  }) async {
    try {
      if (bookedSeatsString.isEmpty ||
          currentSeatLayout == null ||
          currentSeatLayout.isEmpty) {
        return MResult.error('Dữ liệu ghế không hợp lệ');
      }

      final bookedSeats =
          bookedSeatsString
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

      if (bookedSeats.isEmpty) {
        return MResult.error('Danh sách ghế trống');
      }

      final seats = currentSeatLayout['seats'];
      if (seats == null || seats is! List) {
        return MResult.error('Cấu trúc ghế không hợp lệ');
      }

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

      await supabase
          .from('trips')
          .update({'seat_layout': newSeatLayout})
          .eq('id', tripId);

      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<void>> _releaseSeatLayout({
    required int tripId,
    required String bookedSeatsString,
  }) async {
    try {
      final response =
          await supabase
              .from('trips')
              .select('seat_layout')
              .eq('id', tripId)
              .single();

      final seatLayout = response['seat_layout'] as Map<String, dynamic>?;
      if (seatLayout == null || seatLayout['seats'] == null) {
        return MResult.error('Không tìm thấy thông tin ghế');
      }

      final seatsToRelease =
          bookedSeatsString
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

      if (seatsToRelease.isEmpty) {
        return MResult.error('Danh sách ghế trống');
      }

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

      await supabase
          .from('trips')
          .update({'seat_layout': newSeatLayout})
          .eq('id', tripId);

      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<void>> markEmailSent(int bookingId) async {
    try {
      await supabase
          .from('bookings')
          .update({'isMailSended': true})
          .eq('id', bookingId);

      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<void>> _paymentWithMomo(MBooking booking) async {
    try {
      final momoResponse = await http.post(
        Uri.parse(MOMO_URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': booking.bookingCode,
          'amount': booking.totalPrice,
          'orderInfo': 'Thanh toán đơn hàng vé xe khách ${booking.bookingCode}',
        }),
      );

      final data = jsonDecode(momoResponse.body);
      if (data != null && data['payUrl'] != null) {
        await launchUrl(
          Uri.parse(data['payUrl']),
          mode: LaunchMode.externalApplication,
        );
        return MResult.success(null);
      } else {
        return MResult.error('Không thể tạo liên kết thanh toán Momo');
      }
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<void> handleAfterBooking(int bookingId) async {
    final fullBookingData =
        await supabase
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
  }

  Future<void> _handleAfterCancelBooking(int bookingId) async {
    final fullBookingData =
        await supabase
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
  }

  @override
  MBooking fromMap(Map<String, dynamic> map) {
    return MBooking.fromMap(map);
  }

  @override
  int getId(MBooking item) {
    return item.id!;
  }

  @override
  MBooking setId(MBooking item, int id) {
    return item.copyWith(id: id);
  }

  @override
  Map<String, dynamic> toMap(MBooking item) {
    return item.toMap();
  }
}
