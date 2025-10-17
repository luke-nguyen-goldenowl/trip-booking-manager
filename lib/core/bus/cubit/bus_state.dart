import 'package:bus_ticket_app/models/MBus.dart';

abstract class BusState {}

class BusInitial extends BusState {}

class BusLoading extends BusState {}

class BusLoaded extends BusState {
  final List<MBus> buses;
  BusLoaded(this.buses);
}

class BusDeleted extends BusState {
  final List<MBus> buses;
  BusDeleted(this.buses);
}

class BusError extends BusState {
  final String message;
  BusError(this.message);
}
