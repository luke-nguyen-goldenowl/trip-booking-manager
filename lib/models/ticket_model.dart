import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:bus_ticket_app/models/booking_model.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/models/user_model.dart';

class MTicket {
  final MBooking booking;
  final MTrip trip;
  final MRoute route;
  final MBus bus;
  final MUser company;
  final MUser user;
  MTicket({
    required this.booking,
    required this.trip,
    required this.route,
    required this.bus,
    required this.company,
    required this.user,
  });
}
