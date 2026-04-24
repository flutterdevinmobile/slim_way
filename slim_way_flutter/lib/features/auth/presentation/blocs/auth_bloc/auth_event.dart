part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthInitRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthUserUpdateRequested extends AuthEvent {
  final User user;
  const AuthUserUpdateRequested(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthGoogleLoginRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthRegisterRequested(this.name, this.email, this.password);
  @override
  List<Object?> get props => [name, email, password];
}

class AuthVerifyRequested extends AuthEvent {
  final String email;
  final String code;
  const AuthVerifyRequested(this.email, this.code);
  @override
  List<Object?> get props => [email, code];
}
