import 'package:supabase_flutter/supabase_flutter.dart';

class TestDB {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<dynamic> fetchData() async {
    final response = await _supabase.from('user').select();
    return response;
  }
}
