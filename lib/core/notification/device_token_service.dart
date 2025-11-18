import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeviceTokenService {
  final supabase = Supabase.instance.client;

  Future<void> saveDeviceToken(int userId) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) return;

    await supabase.from('user_devices').upsert({
      'user_id': userId,
      'device_token': fcmToken,
      'device_type': Platform.operatingSystem,
    }, onConflict: 'user_id');
  }

  Future<void> removeToken(int userId) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) return;

    await supabase
        .from('user_devices')
        .delete()
        .eq('user_id', userId)
        .eq('device_token', fcmToken);
  }
}
