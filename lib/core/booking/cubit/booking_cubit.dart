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
        final result = await _bookingService.createBookingByCash(booking);

        if (result.isError) {
          emit(BookingError(result.error ?? 'Không thể tạo booking'));
        } else {
          emit(BookingSuccess(result.data!));
        }
      } else if (booking.paymentMethod == 'momo') {
        final result = await _bookingService.createBookingByMomo(booking);

        if (result.isError) {
          emit(BookingError(result.error ?? 'Không thể tạo booking'));
        } else {
          emit(BookingPending(result.data!));
        }
      } else {
        emit(BookingError('Phương thức thanh toán không hợp lệ'));
      }
    } catch (e) {
      emit(BookingError('Không thể tạo booking: ${e.toString()}'));
    }
  }

  Future<void> getBookingByUserId(int userId) async {
    emit(BookingLoading());

    final result = await _bookingService.getBookingsByUserId(userId);

    if (result.isSuccess) {
      emit(BookingListLoaded(result.data!));
    } else {
      emit(BookingError(result.error ?? 'Không thể tải danh sách đặt chỗ'));
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      emit(BookingLoading());

      final result = await _bookingService.cancelBooking(bookingId);

      if (result.isError) {
        emit(BookingError(result.error ?? 'Không thể hủy đặt chỗ'));
      } else {
        emit(BookingInitial());
      }
    } catch (e) {
      emit(BookingError('Không thể hủy đặt chỗ: ${e.toString()}'));
    }
  }
}
