import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'dart:typed_data';

class UserCubit extends Cubit<UserState> {
  final UserService _userService;

  UserCubit(this._userService) : super(UserInitial());

  Future<void> loadUser(String email) async {
    try {
      emit(UserLoading());
      final user = await _userService.getUserInfo(email);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('Không tìm thấy thông tin người dùng'));
      }
    } catch (e) {
      emit(UserError('Không thể tải thông tin người dùng'));
    }
  }

  Future<void> loadAllUser() async {
    try {
      emit(UserLoading());
      final users = await _userService.getAllUsers();
      emit(MultiUserLoaded(users));
    } catch (e) {
      emit(UserError('Không thể tải danh sách người dùng'));
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      try {
        emit(UserLoading());
        await _userService.updateUserProfile(currentUser.email!, data);
        final updatedUser = await _userService.getUserInfo(currentUser.email!);
        if (updatedUser != null) {
          emit(UserLoaded(updatedUser));
        } else {
          emit(
            const UserError(
              'Không tìm thấy thông tin người dùng sau khi cập nhật',
            ),
          );
        }
      } catch (e) {
        emit(UserError('Không thể cập nhật thông tin người dùng'));
      }
    }
  }

  Future<void> uploadAvatar(Uint8List imageBytes) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final currentEmail = currentUser.email!;

      try {
        emit(UserLoading());

        final avatarUrl = await _userService.uploadAvatar(
          currentEmail,
          imageBytes,
        );

        if (avatarUrl != null) {
          await loadUser(currentEmail);
        }
      } catch (e) {
        emit(UserError('Không thể tải ảnh lên'));
        try {
          await loadUser(currentEmail);
        } catch (reloadError) {
          emit(
            UserError('Không thể tải ảnh lên và tải lại thông tin người dùng'),
          );
        }
      }
    }
  }
}
