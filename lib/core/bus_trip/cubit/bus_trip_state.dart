import 'package:bus_ticket_app/models/trip_model.dart';

abstract class BusTripState {}

class BusTripInitial extends BusTripState {}

class BusTripLoading extends BusTripState {}

class BusTripLoaded extends BusTripState {
  final List<MTrip> trips;
  BusTripLoaded(this.trips);
}

class PopularTripLoaded extends BusTripState {
  final List<MTrip> trips;
  PopularTripLoaded(this.trips);
}

class BusTripDeleted extends BusTripState {
  final List<MTrip> trips;
  BusTripDeleted(this.trips);
}

class BusTripError extends BusTripState {
  final String message;
  BusTripError(this.message);
}

class BookedUsersLoading extends BusTripState {}

class BookedUsersLoaded extends BusTripState {
  final List<Map<String, dynamic>> users;
  BookedUsersLoaded(this.users);
}

class BookedUsersError extends BusTripState {
  final String message;
  BookedUsersError(this.message);
}
