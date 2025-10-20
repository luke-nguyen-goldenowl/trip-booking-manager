import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:bus_ticket_app/utils/helper/validation_email.dart';

class ForgotPasswordService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  Future<void> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      throw ('Vui lòng nhập địa chỉ email');
    }

    if (!isValidEmail(email)) {
      throw ('Địa chỉ email không hợp lệ');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw ('Không tìm thấy tài khoản với email này');
        case 'invalid-email':
          throw ('Địa chỉ email không hợp lệ');
        case 'too-many-requests':
          throw ('Bạn đã yêu cầu quá nhiều lần. Hãy thử lại sau');
        case 'network-request-failed':
          throw ('Lỗi kết nối mạng. Kiểm tra Internet và thử lại');
        default:
          throw ('Đã xảy ra lỗi. Vui lòng thử lại sau');
      }
    }
  }
}
