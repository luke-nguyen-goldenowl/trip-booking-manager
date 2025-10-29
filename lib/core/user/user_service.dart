import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/user_model.dart' as user_model;
import 'dart:typed_data';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;
  Future<user_model.MUser?> getUserInfo(String email) async {
    final response =
        await _supabase.from('user').select().eq('email', email).single();
    return user_model.MUser.fromMap(response);
  }

  Future<user_model.MUser?> getUserbyId(int id) async {
    final response =
        await _supabase.from('user').select().eq('id', id).single();
    return user_model.MUser.fromMap(response);
  }

  Future<void> updateUserProfile(
    String email,
    Map<String, dynamic> data,
  ) async {
    await _supabase.from('user').update(data).eq('email', email);
  }

  Future<String?> uploadAvatar(String email, Uint8List imageBytes) async {
    try {
      final String fileName =
          'avatar_${email.replaceAll('@', '_').replaceAll('.', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = fileName;
      await _supabase.storage
          .from('avatar')
          .uploadBinary(
            path,
            imageBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      final String publicUrl = _supabase.storage
          .from('avatar')
          .getPublicUrl(path);
      await updateUserProfile(email, {'avatar_url': publicUrl});

      return publicUrl;
    } catch (e) {
      throw Exception('Không thể tải ảnh lên: ${e.toString()}');
    }
  }
}
