import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';

class CompanyCubit extends Cubit<UserState> {
  final UserService _userService;

  CompanyCubit(this._userService) : super(UserInitial());
  Future<void> loadCompanyById(int companyId) async {
    emit(UserLoading());

    final result = await _userService.getUserbyId(companyId);

    if (result.isSuccess) {
      emit(UserLoaded(result.data!));
    } else {
      emit(UserError(result.error ?? 'Không thể tải thông tin nhà xe'));
    }
  }
}
