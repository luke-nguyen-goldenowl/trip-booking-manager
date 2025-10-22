import 'package:bus_ticket_app/models/MRoute.dart';

abstract class BusRouteState {}

class BusRouteInitial extends BusRouteState {}

class BusRouteLoading extends BusRouteState {}

class BusRouteLoaded extends BusRouteState {
  final List<MRoute> buses;
  BusRouteLoaded(this.buses);
}

class BusRouteDeleted extends BusRouteState {
  final List<MRoute> buses;
  BusRouteDeleted(this.buses);
}

class BusRouteError extends BusRouteState {
  final String message;
  BusRouteError(this.message);
}
