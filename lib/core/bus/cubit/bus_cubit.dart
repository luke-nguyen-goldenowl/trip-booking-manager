import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:bus_ticket_app/core/bus/bus_service.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';

class BusCubit extends Cubit<BusState> {
  final BusService _busService;

  BusCubit(this._busService) : super(BusInitial());

  Future<void> loadBuses(int companyId) async {
    try {
      emit(BusLoading());
      final result = await _busService.getBusesByCompany(companyId);
      if (result.isSuccess) {
        emit(BusLoaded(result.data!));
      } else {
        emit(BusError(result.error ?? 'Không thể tải danh sách xe'));
      }
    } catch (e) {
      emit(BusError('Không thể tải danh sách xe'));
    }
  }

  Future<void> loadAllBuses() async {
    try {
      emit(BusLoading());
      final result = await _busService.getAllBuses();
      if (result.isSuccess) {
        emit(BusLoaded(result.data!));
      } else {
        emit(BusError(result.error ?? 'Không thể tải danh sách xe'));
      }
    } catch (e) {
      emit(BusError('Không thể tải danh sách xe'));
    }
  }

  Future<void> createBus(MBus bus) async {
    try {
      emit(BusLoading());
      final result = await _busService.createBus(bus);
      if (result.isSuccess) {
        await loadBuses(bus.companyId!);
      } else {
        emit(BusError(result.error ?? 'Không thể tạo xe'));
      }
    } catch (e) {
      emit(BusError('Không thể tạo xe'));
    }
  }

  Future<void> updateBus(int busId, MBus bus) async {
    try {
      emit(BusLoading());
      final result = await _busService.updateBus(busId, bus);
      if (result.isSuccess) {
        await loadBuses(bus.companyId!);
      } else {
        emit(BusError(result.error ?? 'Không thể cập nhật xe'));
      }
    } catch (e) {
      emit(BusError('Không thể cập nhật xe'));
    }
  }

  Future<void> deleteBus(int busId, int companyId) async {
    try {
      emit(BusLoading());
      final result = await _busService.deleteBus(busId);
      if (result.isSuccess) {
        final loadResult = await _busService.getBusesByCompany(companyId);
        if (loadResult.isSuccess) {
          emit(BusDeleted(loadResult.data!));
        } else {
          emit(BusError(loadResult.error ?? 'Không thể tải lại danh sách xe'));
        }
      } else {
        emit(BusError(result.error ?? 'Không thể xóa xe'));
      }
    } catch (e) {
      emit(BusError('Không thể xóa xe'));
    }
  }

  Future<bool> checkDuplicateLicensePlate(
    String busNumber,
    int companyId,
  ) async {
    final result = await _busService.getBusesByCompany(companyId);

    if (result.isError) {
      return false;
    }

    final buses = result.data!;

    return buses.any(
      (bus) =>
          bus.busNumber?.trim().toUpperCase() == busNumber.trim().toUpperCase(),
    );
  }
}
