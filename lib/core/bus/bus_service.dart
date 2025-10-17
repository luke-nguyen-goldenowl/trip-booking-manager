import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/MBus.dart';

class BusService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<MBus>> getBusesByCompany(int companyId) async {
    try {
      final response = await _supabase
          .from('buses')
          .select()
          .eq('company_id', companyId);

      return (response as List).map((bus) => MBus.fromMap(bus)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách xe');
    }
  }

  Future<MBus> createBus(MBus bus) async {
    try {
      final response =
          await _supabase.from('buses').insert(bus.toMap()).select().single();

      return MBus.fromMap(response);
    } catch (e) {
      throw Exception('Không thể thêm xe');
    }
  }

  Future<void> updateBus(int busId, MBus bus) async {
    try {
      await _supabase.from('buses').update(bus.toMap()).eq('id', busId);
    } catch (e) {
      throw Exception('Không thể cập nhật xe');
    }
  }

  Future<void> deleteBus(int busId) async {
    try {
      await _supabase.from('buses').delete().eq('id', busId);
    } catch (e) {
      throw Exception('Không thể xóa xe');
    }
  }
}
