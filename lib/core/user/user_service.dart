import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/models/user_model.dart' as user_model;
import 'package:bus_ticket_app/models/base_collection.dart';
import 'package:bus_ticket_app/models/result_model.dart';
import 'dart:typed_data';

class UserService extends BaseCollection<user_model.MUser> {
  UserService(SupabaseClient supabase)
    : super(supabase: supabase, tableName: 'user');

  Future<MResult<user_model.MUser>> getUserInfo(String email) async {
    try {
      final response =
          await supabase.from('user').select().eq('email', email).single();
      return MResult.success(user_model.MUser.fromMap(response));
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<user_model.MUser>> getUserbyId(int id) async {
    return get(id);
  }

  Future<MResult<List<user_model.MUser>>> getAllUsers() async {
    return getAll();
  }

  Future<MResult<void>> updateUserProfile(
    String email,
    Map<String, dynamic> data,
  ) async {
    try {
      await supabase.from('user').update(data).eq('email', email);
      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<String>> uploadAvatar(
    String email,
    Uint8List imageBytes,
  ) async {
    try {
      final Uint8List resizedBytes =
          await FlutterImageCompress.compressWithList(
            imageBytes,
            minWidth: 512,
            minHeight: 512,
            quality: 85,
            format: CompressFormat.jpeg,
            keepExif: false,
            autoCorrectionAngle: true,
          );
      final String fileName =
          'avatar_${email.replaceAll('@', '_').replaceAll('.', '_')}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = fileName;
      await supabase.storage
          .from('avatar')
          .uploadBinary(
            path,
            resizedBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );
      final String publicUrl = supabase.storage
          .from('avatar')
          .getPublicUrl(path);

      final updateResult = await updateUserProfile(email, {
        'avatar_url': publicUrl,
      });
      if (updateResult.isError) {
        return MResult.error(updateResult.error ?? 'Không thể cập nhật avatar');
      }

      return MResult.success(publicUrl);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<int?> getUserIdFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  @override
  user_model.MUser fromMap(Map<String, dynamic> map) {
    return user_model.MUser.fromMap(map);
  }

  @override
  int getId(user_model.MUser item) {
    return item.id;
  }

  @override
  user_model.MUser setId(user_model.MUser item, int id) {
    return item.copyWith(id: id);
  }

  @override
  Map<String, dynamic> toMap(user_model.MUser item) {
    return item.toMapLocaldb();
  }
}
