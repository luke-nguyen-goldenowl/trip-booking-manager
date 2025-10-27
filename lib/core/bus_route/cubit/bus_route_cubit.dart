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
      final routes = await _busRouteService.getRoutesByCompany(companyId);
      emit(BusRouteLoaded(routes));
    } catch (e) {
      emit(BusRouteError(e.toString()));
    }
  }

  Future<void> loadAllRoutes() async {
    try {
      emit(BusRouteLoading());
      final routes = await _busRouteService.getAllRoutes();
      emit(BusRouteLoaded(routes));
    } catch (e) {
      emit(BusRouteError(e.toString()));
    }
  }

  Future<void> createRoute(MRoute route) async {
    try {
      emit(BusRouteLoading());
      await _busRouteService.createRoute(route);
      await loadRoutes(route.companyId!);
    } catch (e) {
      emit(BusRouteError(e.toString()));
    }
  }

  Future<void> updateRoute(int routeId, MRoute route) async {
    try {
      emit(BusRouteLoading());
      await _busRouteService.updateRoute(routeId, route);
      await loadRoutes(route.companyId!);
    } catch (e) {
      emit(BusRouteError(e.toString()));
    }
  }

  Future<void> deleteRoute(int routeId, int companyId) async {
    try {
      emit(BusRouteLoading());
      await _busRouteService.deleteRoute(routeId);
      final routes = await _busRouteService.getRoutesByCompany(companyId);
      emit(BusRouteDeleted(routes));
    } catch (e) {
      emit(BusRouteError(e.toString()));
    }
  }

  Future<bool> checkDuplicateRouteName(
    String departure,
    String destination,
    int companyId,
  ) async {
    try {
      final routes = await _busRouteService.getRoutesByCompany(companyId);
      return routes.any(
        (route) =>
            route.departure?.trim().toUpperCase() ==
                departure.trim().toUpperCase() &&
            route.destination?.trim().toUpperCase() ==
                destination.trim().toUpperCase(),
      );
    } catch (e) {
      return false;
    }
  }
}
