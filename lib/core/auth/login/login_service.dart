import 'package:bus_ticket_app/core/notification/device_token_service.dart';
import 'package:bus_ticket_app/models/result_model.dart';
import 'package:bus_ticket_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  late final UserService userService;
  DeviceTokenService tokenService = DeviceTokenService();

  LoginService() {
    userService = UserService(_supabase);
  }

  Future<MResult<MUser>> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        return MResult.error(
          'Email chưa được xác nhận. Vui lòng kiểm tra hộp thư và xác nhận email.',
        );
      }

      final userResult = await userService.getUserInfo(email.trim());
      if (userResult.isError) {
        await _auth.signOut();
        return MResult.error(
          userResult.error ?? 'Không thể tải thông tin người dùng',
        );
      }

      final user = userResult.data!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id);
      await tokenService.saveDeviceToken(user.id);

      return MResult.success(user);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> resendVerificationEmail(
    String email,
    String password,
  ) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      if (userCredential.user!.emailVerified) {
        await _auth.signOut();
        return MResult.error(
          'Email đã được xác nhận rồi. Bạn có thể đăng nhập.',
        );
      }
      await userCredential.user!.sendEmailVerification();
      await _auth.signOut();

      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<MUser>> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return MResult.error('Đăng nhập bị hủy');
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final String? email = userCredential.user?.email;
      final String? name = userCredential.user?.displayName;

      if (email == null) {
        return MResult.error('Không thể lấy thông tin email từ Google');
      }

      final response = await _supabase.from('user').select().eq('email', email);

      if (response.isEmpty) {
        await _supabase.from('user').insert({
          'email': email,
          'full_name': name ?? 'User',
          'role': 'Khách hàng',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      final userResult = await userService.getUserInfo(email);
      if (userResult.isError) {
        return MResult.error(
          userResult.error ?? 'Không thể tải thông tin người dùng',
        );
      }

      final user = userResult.data!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id);
      await tokenService.saveDeviceToken(user.id);

      return MResult.success(user);
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
