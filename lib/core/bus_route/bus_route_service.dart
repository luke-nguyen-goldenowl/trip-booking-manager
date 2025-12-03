import 'package:bus_ticket_app/models/base_collection.dart';
import 'package:bus_ticket_app/models/result_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/route_model.dart';

class BusRouteService extends BaseCollection<MRoute> {
  BusRouteService(SupabaseClient supabase)
    : super(supabase: supabase, tableName: 'routes');

  Future<MResult<List<MRoute>>> getRoutesByCompany(int companyId) async {
    return getAll(column: 'company_id', value: companyId);
  }

  Future<MResult<List<MRoute>>> getAllRoutes() async {
    return getAll();
  }

  Future<MResult<MRoute>> createRoute(MRoute route) async {
    return insert(route);
  }

  Future<MResult<MRoute>> updateRoute(int routeId, MRoute route) async {
    return update(route.copyWith(id: routeId));
  }

  Future<MResult<void>> deleteRoute(int routeId) async {
    return delete(routeId);
  }

  Future<MResult<MRoute>> getRouteById(int routeId) async {
    return get(routeId);
  }

  @override
  MRoute fromMap(Map<String, dynamic> map) {
    return MRoute.fromMap(map);
  }

  @override
  int getId(MRoute item) {
    return item.id!;
  }

  @override
  MRoute setId(MRoute item, int id) {
    return item.copyWith(id: id);
  }

  @override
  Map<String, dynamic> toMap(MRoute item) {
    return item.toMap();
  }
}
