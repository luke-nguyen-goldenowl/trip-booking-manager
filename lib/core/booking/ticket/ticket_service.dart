import 'package:bus_ticket_app/core/bus/bus_service.dart';
import 'package:bus_ticket_app/core/bus_route/bus_route_service.dart';
import 'package:bus_ticket_app/core/bus_trip/bus_trip_service.dart';
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:bus_ticket_app/models/ticket_model.dart';
import 'package:bus_ticket_app/models/booking_model.dart';
import 'package:bus_ticket_app/core/booking/booking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TicketService {
  Future<MTicket> fetchFullTicketInfo(MBooking booking) async {
    final supabaseClient = Supabase.instance.client;
    final tripService = BusTripService(supabaseClient);
    final routeService = BusRouteService(supabaseClient);
    final busService = BusService(supabaseClient);
    final userService = UserService(supabaseClient);

    //fetch trip
    final tripResult = await tripService.getTripById(booking.tripId!);
    if (tripResult.isError) {
      throw Exception(tripResult.error ?? 'Không thể tải thông tin chuyến đi');
    }
    final trip = tripResult.data!;

    //fetch bus
    final busResult = await busService.getBusById(trip.busId!);
    if (busResult.isError) {
      throw Exception(busResult.error ?? 'Không thể tải thông tin xe');
    }
    final bus = busResult.data!;

    //fetch route
    final routeResult = await routeService.getRouteById(trip.routeId!);
    if (routeResult.isError) {
      throw Exception(
        routeResult.error ?? 'Không thể tải thông tin tuyến đường',
      );
    }
    final route = routeResult.data!;

    //fetch company
    final companyResult = await userService.getUserbyId(trip.companyId!);
    if (companyResult.isError) {
      throw Exception(companyResult.error ?? 'Không thể tải thông tin nhà xe');
    }
    final company = companyResult.data!;

    //fetch user
    final userResult = await userService.getUserbyId(booking.userId!);
    if (userResult.isError) {
      throw Exception(userResult.error ?? 'Không thể tải thông tin người dùng');
    }
    final user = userResult.data!;

    if (booking.paymentStatus == 'completed') {
      final bookingService = BookingService(supabaseClient);
      await bookingService.handleAfterBooking(booking.id!);
    }
    return MTicket(
      booking: booking,
      trip: trip,
      route: route,
      bus: bus,
      company: company,
      user: user,
    );
  }
}
