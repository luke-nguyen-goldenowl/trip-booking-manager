import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sqflite/sqflite.dart';

class MResult<T> {
  MResult.exception(Object? e) {
    data = null;
    if (e is DatabaseException) {
      error = _handleDatabaseException(e);
    } else if (e is PostgrestException) {
      error = _handlePostgrestException(e);
    } else if (e is StorageException) {
      error = _handleStorageException(e);
    } else if (e is firebase_auth.FirebaseAuthException) {
      error = _handleFirebaseAuthException(e);
    } else if (e is PlatformException) {
      error = e.message ?? 'Đã xảy ra lỗi hệ thống';
    } else if (e is AssertionError) {
      error = e.message?.toString() ?? 'Lỗi xác thực dữ liệu';
    } else if (e is FlutterError) {
      error = e.message;
    } else if (e is Exception) {
      final message = e.toString();
      error = message.replaceFirst('Exception: ', '');
    } else {
      error = 'Đã xảy ra lỗi không xác định';
    }
  }

  MResult.error(String? error) {
    data = null;
    this.error = error ?? 'Đã xảy ra lỗi không xác định';
  }

  MResult.success(this.data) {
    error = null;
  }

  T? data;
  String? error;
  bool get isError => error != null;
  bool get isSuccess => !isError;

  String _handlePostgrestException(PostgrestException e) {
    final code = e.code;
    final message = e.message;

    switch (code) {
      case '23505':
        return 'Dữ liệu đã tồn tại trong hệ thống';
      case '23503':
        return 'Dữ liệu liên quan không tồn tại';
      case '23502':
        return 'Thiếu thông tin bắt buộc';
      case '42501':
        return 'Bạn không có quyền thực hiện thao tác này';
      case '42P01':
        return 'Bảng dữ liệu không tồn tại';
      case '42703':
        return 'Trường dữ liệu không tồn tại';
      case 'PGRST116':
        return 'Không tìm thấy dữ liệu';
      case 'PGRST301':
        return 'Yêu cầu không hợp lệ';
      default:
        if (message.isNotEmpty) {
          return message;
        }
        return 'Lỗi cơ sở dữ liệu: $code';
    }
  }

  String _handleStorageException(StorageException e) {
    final message = e.message.toLowerCase();

    if (message.contains('not found')) {
      return 'Tệp không tồn tại';
    } else if (message.contains('unauthorized')) {
      return 'Bạn không có quyền truy cập tệp này';
    } else if (message.contains('payload too large')) {
      return 'Kích thước tệp quá lớn';
    } else if (message.contains('invalid mime type')) {
      return 'Định dạng tệp không được hỗ trợ';
    }

    return e.message.isNotEmpty ? e.message : 'Lỗi lưu trữ';
  }

  String _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng sử dụng email khác hoặc đăng nhập.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ. Vui lòng kiểm tra lại.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa. Vui lòng liên hệ hỗ trợ.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác. Vui lòng thử lại.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn (ít nhất 6 ký tự).';
      case 'invalid-password':
        return 'Mật khẩu không hợp lệ.';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ. Vui lòng kiểm tra email và mật khẩu.';
      case 'invalid-verification-code':
        return 'Mã xác thực không hợp lệ. Vui lòng thử lại.';
      case 'invalid-verification-id':
        return 'ID xác thực không hợp lệ.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau vài phút.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt.';
      case 'requires-recent-login':
        return 'Thao tác này yêu cầu đăng nhập lại. Vui lòng đăng xuất và đăng nhập lại.';
      case 'email-already-verified':
        return 'Email đã được xác thực rồi.';
      case 'expired-action-code':
        return 'Mã xác thực đã hết hạn. Vui lòng yêu cầu mã mới.';
      case 'invalid-action-code':
        return 'Mã xác thực không hợp lệ hoặc đã được sử dụng.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet và thử lại.';
      case 'timeout':
        return 'Yêu cầu quá lâu. Vui lòng thử lại.';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với phương thức đăng nhập khác. Vui lòng sử dụng phương thức đăng nhập ban đầu.';
      case 'credential-already-in-use':
        return 'Thông tin xác thực này đã được sử dụng cho tài khoản khác.';
      case 'session-expired':
        return 'Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.';
      case 'invalid-user-token':
        return 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.';
      case 'user-token-expired':
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
      case 'popup-closed-by-user':
        return 'Cửa sổ đăng nhập đã bị đóng. Vui lòng thử lại.';
      case 'popup-blocked':
        return 'Trình duyệt đã chặn cửa sổ đăng nhập. Vui lòng cho phép popup và thử lại.';
      case 'unauthorized-domain':
        return 'Tên miền không được phép sử dụng cho phương thức đăng nhập này.';
      case 'invalid-phone-number':
        return 'Số điện thoại không hợp lệ.';
      case 'missing-phone-number':
        return 'Vui lòng nhập số điện thoại.';
      case 'quota-exceeded':
        return 'Đã vượt quá số lượng SMS cho phép. Vui lòng thử lại sau.';
      default:
        if (e.message != null && e.message!.isNotEmpty) {
          return e.message!;
        }
        return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại. (Mã lỗi: ${e.code})';
    }
  }

  String _handleDatabaseException(DatabaseException e) {
    final message = e.toString().toLowerCase();

    if (e.isUniqueConstraintError()) {
      return 'Dữ liệu đã tồn tại trong hệ thống';
    }
    if (e.isNotNullConstraintError()) {
      return 'Thiếu thông tin bắt buộc';
    }
    if (e.isSyntaxError()) {
      return 'Lỗi cú pháp truy vấn cơ sở dữ liệu';
    }
    if (e.isOpenFailedError()) {
      return 'Không thể mở cơ sở dữ liệu';
    }

    if (e.isDatabaseClosedError()) {
      return 'Cơ sở dữ liệu đã bị đóng';
    }

    if (e.isReadOnlyError()) {
      return 'Cơ sở dữ liệu chỉ đọc, không thể ghi dữ liệu';
    }

    if (message.contains('no such table')) {
      return 'Bảng dữ liệu không tồn tại';
    }

    if (message.contains('no such column')) {
      return 'Trường dữ liệu không tồn tại';
    }

    if (message.contains('disk i/o error')) {
      return 'Lỗi đọc/ghi dữ liệu';
    }

    if (message.contains('database is locked')) {
      return 'Cơ sở dữ liệu đang bị khóa, vui lòng thử lại';
    }

    if (message.contains('out of memory')) {
      return 'Không đủ bộ nhớ';
    }

    if (message.contains('disk full')) {
      return 'Bộ nhớ đầy, vui lòng giải phóng dung lượng';
    }

    if (message.contains('corrupt')) {
      return 'Cơ sở dữ liệu bị lỗi';
    }
    return e.toString().isNotEmpty ? e.toString() : 'Lỗi cơ sở dữ liệu';
  }
}
