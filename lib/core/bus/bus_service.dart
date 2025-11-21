import 'package:bus_ticket_app/models/base_collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/bus_model.dart';
import 'package:bus_ticket_app/models/result_model.dart';

class BusService extends BaseCollection<MBus> {
  BusService(SupabaseClient supabase)
    : super(supabase: supabase, tableName: 'buses');

  Future<MResult<List<MBus>>> getBusesByCompany(int companyId) async {
    return getAll(column: 'company_id', value: companyId);
  }

  Future<MResult<List<MBus>>> getAllBuses() async {
    return getAll();
  }

  Future<MResult<MBus>> getBusById(int busId) async {
    return get(busId);
  }

  Future<MResult<MBus>> createBus(MBus bus) async {
    return insert(bus);
  }

  Future<MResult<MBus>> updateBus(int busId, MBus bus) async {
    return update(bus.copyWith(id: busId));
  }

  Future<MResult<void>> deleteBus(int busId) async {
    return delete(busId);
  }

  @override
  MBus fromMap(Map<String, dynamic> map) {
    return MBus.fromMap(map);
  }

  @override
  int getId(MBus item) {
    return item.id!;
  }

  @override
  MBus setId(MBus item, int id) {
    return item.copyWith(id: id);
  }

  @override
  Map<String, dynamic> toMap(MBus item) {
    return item.toMap();
  }
}
