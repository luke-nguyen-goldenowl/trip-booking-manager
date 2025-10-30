import 'package:bus_ticket_app/core/bus/bus_service.dart';
import 'package:bus_ticket_app/core/bus_route/bus_route_service.dart';
import 'package:bus_ticket_app/core/bus_trip/bus_trip_service.dart';
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:bus_ticket_app/models/ticket_model.dart';
import 'package:bus_ticket_app/models/booking_model.dart';

class TicketService {
  Future<MTicket> fetchFullTicketInfo(MBooking booking) async {
    final tripService = BusTripService();
    final routeService = BusRouteService();
    final busService = BusService();
    final userService = UserService();

    final trip = await tripService.getTripById(booking.tripId!);
    final route = await routeService.getRouteById(trip!.routeId!);
    final bus = await busService.getBusById(trip.busId!);
    final company = await userService.getUserbyId(trip.companyId!);
    final user = await userService.getUserbyId(booking.userId!);
    return MTicket(
      booking: booking,
      trip: trip,
      route: route!,
      bus: bus!,
      company: company!,
      user: user!,
    );
  }
}
