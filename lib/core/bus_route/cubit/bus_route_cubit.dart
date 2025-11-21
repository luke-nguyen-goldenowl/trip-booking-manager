import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/models/route_model.dart';
import 'package:bus_ticket_app/core/bus_route/bus_route_service.dart';
import 'package:bus_ticket_app/core/bus_route/cubit/bus_route_state.dart';

class BusRouteCubit extends Cubit<BusRouteState> {
  final BusRouteService _busRouteService;

  BusRouteCubit(this._busRouteService) : super(BusRouteInitial());

  Future<void> loadRoutes(int companyId) async {
    try {
      emit(BusRouteLoading());
      final result = await _busRouteService.getRoutesByCompany(companyId);
      if (result.isSuccess) {
        emit(BusRouteLoaded(result.data!));
      } else {
        emit(
          BusRouteError(result.error ?? 'Không thể tải danh sách tuyến đường'),
        );
      }
    } catch (e) {
      emit(BusRouteError('Không thể tải danh sách tuyến đường'));
    }
  }

  Future<void> loadAllRoutes() async {
    try {
      emit(BusRouteLoading());
      final result = await _busRouteService.getAllRoutes();
      if (result.isSuccess) {
        emit(BusRouteLoaded(result.data!));
      } else {
        emit(
          BusRouteError(
            result.error ?? 'Không thể tải danh sách tất cả tuyến đường',
          ),
        );
      }
    } catch (e) {
      emit(BusRouteError('Không thể tải danh sách tất cả tuyến đường'));
    }
  }

  Future<void> createRoute(MRoute route) async {
    try {
      emit(BusRouteLoading());
      final result = await _busRouteService.createRoute(route);
      if (result.isSuccess) {
        await loadRoutes(route.companyId!);
      } else {
        emit(BusRouteError(result.error ?? 'Không thể tạo tuyến đường'));
      }
    } catch (e) {
      emit(BusRouteError('Không thể tạo tuyến đường'));
    }
  }

  Future<void> updateRoute(int routeId, MRoute route) async {
    try {
      emit(BusRouteLoading());
      final result = await _busRouteService.updateRoute(routeId, route);
      if (result.isSuccess) {
        await loadRoutes(route.companyId!);
      } else {
        emit(BusRouteError(result.error ?? 'Không thể cập nhật tuyến đường'));
      }
    } catch (e) {
      emit(BusRouteError('Không thể cập nhật tuyến đường'));
    }
  }

  Future<void> deleteRoute(int routeId, int companyId) async {
    try {
      emit(BusRouteLoading());
      final result = await _busRouteService.deleteRoute(routeId);
      if (result.isSuccess) {
        final routes = await _busRouteService.getRoutesByCompany(companyId);
        if (routes.isSuccess) {
          emit(BusRouteDeleted(routes.data!));
        } else {
          emit(
            BusRouteError(
              routes.error ?? "Không thể tải danh sách tuyến đường",
            ),
          );
        }
      } else {
        emit(BusRouteError(result.error ?? "Không thể xóa tuyến đường"));
      }
    } catch (e) {
      emit(BusRouteError("Không thể xóa tuyến đường"));
    }
  }

  Future<bool> checkDuplicateRouteName(
    String departure,
    String destination,
    int companyId,
  ) async {
    try {
      final result = await _busRouteService.getRoutesByCompany(companyId);
      if (result.isSuccess) {
        return result.data!.any(
          (route) =>
              route.departure?.trim().toUpperCase() ==
                  departure.trim().toUpperCase() &&
              route.destination?.trim().toUpperCase() ==
                  destination.trim().toUpperCase(),
        );
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
