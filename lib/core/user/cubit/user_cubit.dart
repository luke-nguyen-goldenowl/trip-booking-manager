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

      final result = await _userService.getUserInfo(email);

      if (result.isSuccess) {
        emit(UserLoaded(result.data!));
      } else {
        emit(UserError(result.error ?? 'Không thể tải thông tin người dùng'));
      }
    } catch (e) {
      emit(UserError('Không thể tải thông tin người dùng'));
    }
  }

  Future<void> loadAllUser() async {
    try {
      emit(UserLoading());

      final result = await _userService.getAllUsers();

      if (result.isSuccess) {
        emit(MultiUserLoaded(result.data!));
      } else {
        emit(UserError(result.error ?? 'Không thể tải danh sách người dùng'));
      }
    } catch (e) {
      emit(UserError('Không thể tải danh sách người dùng'));
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      if (currentUser.email == null) {
        emit(UserLoading());
        emit(UserError('Email không hợp lệ'));
        return;
      }

      emit(UserLoading());

      final updateResult = await _userService.updateUserProfile(
        currentUser.email!,
        data,
      );

      if (updateResult.isSuccess) {
        final userResult = await _userService.getUserInfo(currentUser.email!);
        if (userResult.isSuccess) {
          emit(UserLoaded(userResult.data!));
        } else {
          emit(
            UserError(
              userResult.error ??
                  'Không tìm thấy thông tin người dùng sau khi cập nhật',
            ),
          );
        }
      } else {
        emit(
          UserError(
            updateResult.error ?? 'Không thể cập nhật thông tin người dùng',
          ),
        );
      }
    }
  }

  Future<void> uploadAvatar(Uint8List imageBytes) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final currentEmail = currentUser.email!;

      emit(UserLoading());

      final result = await _userService.uploadAvatar(currentEmail, imageBytes);

      if (result.isSuccess) {
        await loadUser(currentEmail);
      } else {
        emit(UserError(result.error ?? 'Không thể tải ảnh lên'));
        await loadUser(currentEmail);
      }
    }
  }
}
