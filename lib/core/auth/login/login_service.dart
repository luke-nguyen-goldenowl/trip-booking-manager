import 'package:bus_ticket_app/core/notification/device_token_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:bus_ticket_app/utils/helper/validation_email.dart';
import 'package:bus_ticket_app/models/user_model.dart' as user_model;
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  UserService userService = UserService();
  DeviceTokenService tokenService = DeviceTokenService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> loginWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      return {'error': 'Vui lòng nhập email và mật khẩu'};
    }

    if (!isValidEmail(email)) {
      return {'error': 'Vui lòng nhập email hợp lệ'};
    }

    try {
      firebase_auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        return {
          'error': 'Email chưa được xác nhận',
          'needVerification': true,
          'email': email.trim(),
        };
      }

      user_model.MUser? user = await userService.getUserInfo(email.trim());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user?.id ?? 0);
      if (user != null) {
        await tokenService.saveDeviceToken(user.id);
      }
      return {'success': true, 'user': user};
    } on firebase_auth.FirebaseAuthException catch (e) {
      return {'error': e.message ?? 'Có lỗi xảy ra'};
    } catch (e) {
      return {'error': 'Có lỗi xảy ra: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> resendVerificationEmail(
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
        return {'error': 'Email đã được xác nhận rồi'};
      }
      await userCredential.user!.sendEmailVerification();
      await _auth.signOut();

      return {'success': true, 'message': 'Email xác nhận đã được gửi'};
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        return {'error': 'Quá nhiều yêu cầu. Vui lòng thử lại sau vài phút'};
      }
      return {'error': e.message ?? 'Có lỗi xảy ra'};
    } catch (e) {
      return {'error': 'Có lỗi xảy ra: ${e.toString()}'};
    }
  }

  Future<firebase_auth.UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final String? email = userCredential.user?.email;
      final String? name = userCredential.user?.displayName;
      final response = await _supabase
          .from('user')
          .select()
          .eq('email', email!);
      if (response.isEmpty) {
        await _supabase.from('user').insert({
          'email': email,
          'full_name': name,
          'role': 'Khách hàng',
          'created_at': DateTime.now().toIso8601String(),
        });
        final newUser = await userService.getUserInfo(email);
        if (newUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', newUser.id);
          await tokenService.saveDeviceToken(newUser.id);
        }
      } else {
        final existingUser = await userService.getUserInfo(email);
        if (existingUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', existingUser.id);
          await tokenService.saveDeviceToken(existingUser.id);
        }
      }
      return userCredential;
    } catch (e) {
      throw Exception('Đăng nhập thất bại');
    }
  }
}
