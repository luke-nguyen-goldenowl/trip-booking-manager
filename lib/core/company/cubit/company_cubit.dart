import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bus_ticket_app/core/user/user_service.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';

class CompanyCubit extends Cubit<UserState> {
  final UserService _userService;

  CompanyCubit(this._userService) : super(UserInitial());

  Future<void> loadCompanyById(int companyId) async {
    emit(UserLoading());
    try {
      final company = await _userService.getUserbyId(companyId);
      emit(UserLoaded(company!));
    } catch (e) {
      emit(UserError('Lỗi'));
    }
  }
}
