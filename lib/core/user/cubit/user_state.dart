import 'package:bus_ticket_app/models/user_model.dart';

abstract class UserState {
  const UserState();
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final MUser user;

  const UserLoaded(this.user);
}

class MultiUserLoaded extends UserState {
  final List<MUser> users;

  const MultiUserLoaded(this.users);
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);
}
