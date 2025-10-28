import 'package:bus_ticket_app/models/route_model.dart';

abstract class BusRouteState {}

class BusRouteInitial extends BusRouteState {}

class BusRouteLoading extends BusRouteState {}

class BusRouteLoaded extends BusRouteState {
  final List<MRoute> routes;
  BusRouteLoaded(this.routes);
}

class BusRouteDeleted extends BusRouteState {
  final List<MRoute> routes;
  BusRouteDeleted(this.routes);
}

class BusRouteError extends BusRouteState {
  final String message;
  BusRouteError(this.message);
}
