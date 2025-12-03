import 'package:bus_ticket_app/models/result_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<MResult<bool>> signUpWithEmailAndPassword(
    String email,
    String password,
    String confirmPassword,
    String phoneNumber,
    String fullName,
    String role,
  ) async {
    try {
      firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      await userCredential.user?.updateDisplayName(fullName.trim());
      await userCredential.user?.reload();
      await userCredential.user?.sendEmailVerification();

      await _supabase.from('user').insert({
        'email': userCredential.user?.email,
        'full_name': fullName.trim(),
        'phone': phoneNumber.trim(),
        'role': role.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<bool>> resendVerificationEmail() async {
    try {
      firebase_auth.User? user = _auth.currentUser;

      if (user == null) {
        return MResult.error(
          'Không tìm thấy người dùng. Vui lòng đăng nhập lại.',
        );
      }

      if (user.emailVerified) {
        return MResult.error('Email đã được xác thực rồi.');
      }

      await user.sendEmailVerification();
      return MResult.success(true);
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
