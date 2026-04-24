part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  T when<T>({
    required T Function() initial,
    required T Function() prepare,
    required T Function(User user) authenticated,
    required T Function(int userInfoId) needsSetup,
    required T Function() unauthenticated,
    required T Function(BaseException error) failure,
  }) {
    return switch (this) {
      AuthInitial() => initial(),
      AuthPrepare() => prepare(),
      AuthAuthenticated(:final user) => authenticated(user),
      AuthNeedsSetup(:final userInfoId) => needsSetup(userInfoId),
      AuthUnauthenticated() => unauthenticated(),
      AuthFailure(:final error) => failure(error),
    };
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? prepare,
    T Function(User user)? authenticated,
    T Function(int userInfoId)? needsSetup,
    T Function()? unauthenticated,
    T Function(BaseException error)? failure,
    required T Function() orElse,
  }) {
    return when(
      initial: initial ?? orElse,
      prepare: prepare ?? orElse,
      authenticated: authenticated ?? (_) => orElse(),
      needsSetup: needsSetup ?? (_) => orElse(),
      unauthenticated: unauthenticated ?? orElse,
      failure: failure ?? (_) => orElse(),
    );
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? prepare,
    T Function(User user)? authenticated,
    T Function(int userInfoId)? needsSetup,
    T Function()? unauthenticated,
    T Function(BaseException error)? failure,
  }) {
    return maybeWhen(
      initial: initial,
      prepare: prepare,
      authenticated: authenticated,
      needsSetup: needsSetup,
      unauthenticated: unauthenticated,
      failure: failure,
      orElse: () => null,
    );
  }

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthPrepare extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

final class AuthNeedsSetup extends AuthState {
  final int userInfoId;
  const AuthNeedsSetup(this.userInfoId);
  @override
  List<Object?> get props => [userInfoId];
}

final class AuthUnauthenticated extends AuthState {}

final class AuthFailure extends AuthState {
  final BaseException error;
  const AuthFailure(this.error);
  @override
  List<Object?> get props => [error];
}
