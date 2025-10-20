import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/models/MBus.dart';
import 'package:bus_ticket_app/core/bus/bus_service.dart';
import 'package:bus_ticket_app/core/bus/cubit/bus_state.dart';

class BusCubit extends Cubit<BusState> {
  final BusService _busService;

  BusCubit(this._busService) : super(BusInitial());

  Future<void> loadBuses(int companyId) async {
    try {
      emit(BusLoading());
      final buses = await _busService.getBusesByCompany(companyId);
      emit(BusLoaded(buses));
    } catch (e) {
      emit(BusError(e.toString()));
    }
  }

  Future<void> createBus(MBus bus) async {
    try {
      emit(BusLoading());
      await _busService.createBus(bus);
      await loadBuses(bus.companyId!);
    } catch (e) {
      emit(BusError(e.toString()));
    }
  }

  Future<void> updateBus(int busId, MBus bus) async {
    try {
      emit(BusLoading());
      await _busService.updateBus(busId, bus);
      await loadBuses(bus.companyId!);
    } catch (e) {
      emit(BusError(e.toString()));
    }
  }

  Future<void> deleteBus(int busId, int companyId) async {
    try {
      emit(BusLoading());
      await _busService.deleteBus(busId);
      final buses = await _busService.getBusesByCompany(companyId);
      emit(BusDeleted(buses));
    } catch (e) {
      emit(BusError(e.toString()));
    }
  }

  Future<bool> checkDuplicateLicensePlate(
    String busNumber,
    int companyId,
  ) async {
    try {
      final buses = await _busService.getBusesByCompany(companyId);
      return buses.any(
        (bus) =>
            bus.busNumber?.trim().toUpperCase() ==
            busNumber.trim().toUpperCase(),
      );
    } catch (e) {
      return false;
    }
  }
}
