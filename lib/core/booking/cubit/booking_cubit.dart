import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/booking/cubit/booking_state.dart';
import 'package:bus_ticket_app/core/booking/booking_service.dart';
import 'package:bus_ticket_app/models/booking_model.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingService _bookingService;

  BookingCubit(this._bookingService) : super(BookingInitial());
  Future<void> createBooking(MBooking booking) async {
    try {
      emit(BookingLoading());
      if (booking.paymentMethod == 'cash') {
        final createdBooking = await _bookingService.createBookingbyCash(
          booking,
        );
        emit(BookingSuccess(createdBooking));
      } else {
        emit(BookingError('Không thể tạo booking'));
      }
    } catch (e) {
      emit(BookingError('Lỗi: $e'));
    }
  }

  Future<void> getBookingbyUserId(int userId) async {
    try {
      emit(BookingLoading());
      final bookings = await _bookingService.getBookingbyUserId(userId);
      emit(BookingListLoaded(bookings));
    } catch (e) {
      emit(BookingError('Lỗi: $e'));
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      emit(BookingLoading());
      await _bookingService.cancelBooking(bookingId);
      emit(BookingInitial());
    } catch (e) {
      emit(BookingError('Lỗi: $e'));
    }
  }
}
