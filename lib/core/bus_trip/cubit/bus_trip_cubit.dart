import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/models/trip_model.dart';
import 'package:bus_ticket_app/core/bus_trip/bus_trip_service.dart';
import 'package:bus_ticket_app/core/bus_trip/cubit/bus_trip_state.dart';

class BusTripCubit extends Cubit<BusTripState> {
  final BusTripService _busTripService;

  BusTripCubit(this._busTripService) : super(BusTripInitial());
  Future<void> loadTrips(int companyId) async {
    try {
      emit(BusTripLoading());
      final result = await _busTripService.getTripsByCompany(companyId);

      if (result.isSuccess) {
        emit(BusTripLoaded(result.data!));
      } else {
        emit(BusTripError(result.error ?? 'Không thể tải danh sách chuyến đi'));
      }
    } catch (e) {
      emit(BusTripError('Không thể tải danh sách chuyến đi'));
    }
  }

  Future<void> loadAllTrips() async {
    try {
      emit(BusTripLoading());
      final result = await _busTripService.getAllTrips();
      if (result.isSuccess) {
        emit(BusTripLoaded(result.data!));
      } else {
        emit(
          BusTripError(
            result.error ?? 'Không thể tải danh sách tất cả chuyến đi',
          ),
        );
      }
    } catch (e) {
      emit(BusTripError('Không thể tải danh sách tất cả chuyến đi'));
    }
  }

  Future<void> createTrip(MTrip trip) async {
    try {
      emit(BusTripLoading());
      final result = await _busTripService.createTrip(trip);
      if (result.isSuccess) {
        await loadTrips(trip.companyId!);
      } else {
        emit(BusTripError(result.error ?? 'Không thể tạo chuyến đi'));
      }
    } catch (e) {
      emit(BusTripError('Không thể tạo chuyến đi'));
    }
  }

  Future<void> updateTrip(int tripId, MTrip trip) async {
    try {
      emit(BusTripLoading());
      final result = await _busTripService.updateTrip(tripId, trip);
      if (result.isSuccess) {
        await loadTrips(trip.companyId!);
      } else {
        emit(BusTripError(result.error ?? 'Không thể cập nhật chuyến đi'));
      }
    } catch (e) {
      emit(BusTripError('Không thể cập nhật chuyến đi'));
    }
  }

  Future<void> deleteTrip(int tripId, int companyId) async {
    try {
      emit(BusTripLoading());
      final result = await _busTripService.deleteTrip(tripId);
      if (result.isSuccess) {
        final trips = await _busTripService.getTripsByCompany(companyId);
        if (trips.isSuccess) {
          emit(BusTripDeleted(trips.data!));
          await loadTrips(companyId);
        } else {
          emit(
            BusTripError(trips.error ?? 'Không thể tải danh sách chuyến đi'),
          );
        }
      } else {
        emit(BusTripError(result.error ?? 'Không thể xóa chuyến đi'));
      }
    } catch (e) {
      emit(BusTripError('Không thể xóa chuyến đi'));
    }
  }

  Future<bool> checkBusAvailability({
    required int busId,
    required DateTime departureTime,
    required DateTime arrivalTime,
    int? excludeTripId,
  }) async {
    try {
      return await _busTripService.checkBusAvailability(
        busId: busId,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
      );
    } catch (e) {
      emit(BusTripError('Không thể kiểm tra tình trạng xe'));
      return false;
    }
  }

  Future<void> getRandomTrips(int limit) async {
    try {
      emit(BusTripLoading());
      final result = await _busTripService.getRandomTrips(limit);
      if (result.isSuccess) {
        emit(PopularTripLoaded(result.data!));
      } else {
        emit(BusTripError(result.error ?? 'Không thể tải danh sách chuyến đi'));
      }
    } catch (e) {
      emit(BusTripError('Không thể tải danh sách chuyến đi'));
    }
  }

  Future<void> loadBookedUsers(int tripId) async {
    try {
      emit(BookedUsersLoading());
      final result = await _busTripService.fetchBookedUsers(tripId);
      if (result.isSuccess) {
        emit(BookedUsersLoaded(result.data!));
      } else {
        emit(
          BookedUsersError(
            result.error ?? 'Không thể tải danh sách người dùng đã đặt',
          ),
        );
      }
    } catch (e) {
      emit(BookedUsersError('Không thể tải danh sách người dùng đã đặt'));
    }
  }
}
