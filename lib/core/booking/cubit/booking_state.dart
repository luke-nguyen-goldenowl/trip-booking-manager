import 'package:bus_ticket_app/models/booking_model.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final MBooking booking;
  BookingSuccess(this.booking);
}

class BookingPending extends BookingState {
  final MBooking booking;
  BookingPending(this.booking);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}

class BookingListLoaded extends BookingState {
  final List<MBooking> bookings;
  BookingListLoaded(this.bookings);
}
