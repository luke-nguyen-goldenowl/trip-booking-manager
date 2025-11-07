import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/route_model.dart';

class BusRouteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MRoute>> getRoutesByCompany(int companyId) async {
    final response =
        await _supabase.from('routes').select().eq('company_id', companyId)
            as List<dynamic>;

    return response
        .map((e) => MRoute.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MRoute>> getAllRoutes() async {
    final response = await _supabase.from('routes').select() as List<dynamic>;

    return response
        .map((e) => MRoute.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRoute(MRoute route) async {
    await _supabase.from('routes').insert(route.toMap());
  }

  Future<void> updateRoute(int routeId, MRoute route) async {
    await _supabase.from('routes').update(route.toMap()).eq('id', routeId);
  }

  Future<void> deleteRoute(int routeId) async {
    await _supabase.from('routes').delete().eq('id', routeId);
  }

  Future<MRoute?> getRouteById(int routeId) async {
    try {
      final response =
          await _supabase.from('routes').select().eq('id', routeId).single();

      return MRoute.fromMap(response);
    } catch (e) {
      return null;
    }
  }
}
