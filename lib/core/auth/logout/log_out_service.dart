import 'package:bus_ticket_app/core/notification/device_token_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogOutService {
  DeviceTokenService tokenService = DeviceTokenService();
  Future<void> logout() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("userId");

    if (userId != null && fcmToken != null) {
      await tokenService.removeToken(userId);
    }
    await prefs.remove("userId");
    await FirebaseAuth.instance.signOut();
  }
}
