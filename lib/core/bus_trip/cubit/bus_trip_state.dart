import 'package:bus_ticket_app/models/trip_model.dart';

abstract class BusTripState {}

class BusTripInitial extends BusTripState {}

class BusTripLoading extends BusTripState {}

class BusTripLoaded extends BusTripState {
  final List<MTrip> trips;
  BusTripLoaded(this.trips);
}

class BusTripDeleted extends BusTripState {
  final List<MTrip> trips;
  BusTripDeleted(this.trips);
}

class BusTripError extends BusTripState {
  final String message;
  BusTripError(this.message);
}
