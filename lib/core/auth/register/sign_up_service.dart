import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bus_ticket_app/utils/helper/validation_email.dart';

class SignUpService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> signUpWithEmailAndPassword(
    String email,
    String password,
    String confirmPassword,
    String phoneNumber,
    String fullName,
    String role,
  ) async {
    if (email.isEmpty ||
        password.isEmpty ||
        fullName.isEmpty ||
        confirmPassword.isEmpty ||
        role.isEmpty ||
        phoneNumber.isEmpty) {
      return 'Vui lòng nhập đầy đủ thông tin';
    }

    if (!isValidEmail(email)) {
      return 'Vui lòng nhập địa chỉ email hợp lệ';
    }

    if (password.length < 6) {
      return 'Mật khẩu phải chứa ít nhất 6 ký tự';
    }

    if (password != confirmPassword) {
      return 'Mật khẩu và xác nhận mật khẩu không khớp';
    }

    try {
      firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      await userCredential.user?.updateDisplayName(fullName.trim());
      await userCredential.user?.reload();

      await _supabase.from('user').insert({
        'email': userCredential.user?.email,
        'full_name': fullName.trim(),
        'phone': phoneNumber.trim(),
        'role': role.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      return e.message ?? 'Có lỗi xảy ra';
    } catch (e) {
      throw Exception("Có lỗi xảy ra");
    }
  }
}
