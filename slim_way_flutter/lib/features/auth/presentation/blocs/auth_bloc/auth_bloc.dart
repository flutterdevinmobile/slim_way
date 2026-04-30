import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthInitRequested>(_onAuthInitRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserUpdateRequested>(_onAuthUserUpdateRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthVerifyRequested>(_onAuthVerifyRequested);
  }

  Future<void> _onAuthInitRequested(AuthInitRequested event, Emitter<AuthState> emit) async {
    emit(AuthPrepare());
    final initResult = await _authRepository.initializeSession();

    await initResult.when<Future<void>>(
      success: (_) async {
        if (_authRepository.isSignedIn) {
          final userInfo = _authRepository.signedInUser;
          if (userInfo != null) {
            final userInfoId = userInfo.id!;
            final userResult = await _authRepository.getUserByAuthId(userInfoId);
            userResult.when(
              success: (user) {
                if (user != null) {
                  if (user.name.trim().isEmpty) {
                    user.name = userInfo.userName ?? userInfo.email?.split('@').first ?? 'User';
                  }
                  if (user.activityLevel == null || user.activityLevel!.isEmpty) {
                    emit(AuthNeedsSetup(userInfoId));
                  } else {
                    emit(AuthAuthenticated(user));
                  }
                } else {
                  emit(AuthNeedsSetup(userInfoId));
                }
              },
              failure: (err) {
                final errStr = err.toString().toLowerCase();
                if (errStr.contains('socket') || errStr.contains('timeout') || errStr.contains('host')) {
                  final dummyUser = User(
                    userInfoId: userInfo.id!,
                    name: userInfo.userName ?? userInfo.email?.split('@').first ?? 'Offline User',
                    age: 0,
                    gender: '',
                    height: 0,
                    currentWeight: 0,
                    targetWeight: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  emit(AuthAuthenticated(dummyUser));
                } else {
                  emit(AuthUnauthenticated());
                }
              },
            );
          } else {
            final meResult = await _authRepository.getMe();
            meResult.when(
              success: (user) {
                if (user != null) {
                  if (user.name.trim().isEmpty) {
                    user.name = _authRepository.signedInUser?.userName ?? 'User';
                  }
                  emit(AuthAuthenticated(user));
                } else {
                  emit(AuthUnauthenticated());
                }
              },
              failure: (_) => emit(AuthUnauthenticated()),
            );
          }
        } else {
          emit(AuthUnauthenticated());
        }
      },
      failure: (error) async {
        if (kDebugMode) debugPrint('AuthBloc: initializeSession failed: $error');
        emit(AuthFailure(error));
      },
    );
  }

  Future<void> _onAuthLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthPrepare());
    final result = await _authRepository.signInWithEmail(event.email, event.password);
    result.when(
      success: (user) {
        if (user != null) {
          if (user.activityLevel == null || user.activityLevel!.isEmpty) {
            emit(AuthNeedsSetup(_authRepository.signedInUser!.id!));
          } else {
            emit(AuthAuthenticated(user));
          }
        } else {
          final userInfoId = _authRepository.signedInUser?.id;
          if (userInfoId != null) {
            emit(AuthNeedsSetup(userInfoId));
          } else {
            emit(AuthUnauthenticated());
          }
        }
      },
      failure: (error) => emit(AuthFailure(error)),
    );
  }

  Future<void> _onAuthRegisterRequested(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthPrepare());
    final result = await _authRepository.createAccountRequest(event.name, event.email, event.password);
    result.when(
      success: (sent) {
        if (sent) {
          // Trigger automatic verification in the background
          add(AuthVerifyRequested(event.email, '12345'));
        } else {
          emit(const AuthFailure(AppUnknownException(message: 'Registration failed', stackTrace: null)));
        }
      },
      failure: (error) => emit(AuthFailure(error)),
    );
  }

  Future<void> _onAuthVerifyRequested(AuthVerifyRequested event, Emitter<AuthState> emit) async {
    emit(AuthPrepare());
    final result = await _authRepository.validateAccount(event.email, event.code);
    result.when(
      success: (user) {
        if (user != null) {
          if (user.activityLevel == null || user.activityLevel!.isEmpty) {
            emit(AuthNeedsSetup(_authRepository.signedInUser!.id!));
          } else {
            emit(AuthAuthenticated(user));
          }
        } else {
          final userInfoId = _authRepository.signedInUser?.id;
          if (userInfoId != null) {
            emit(AuthNeedsSetup(userInfoId));
          } else {
            emit(AuthUnauthenticated());
          }
        }
      },
      failure: (error) => emit(AuthFailure(error)),
    );
  }

  Future<void> _onAuthUserUpdateRequested(AuthUserUpdateRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated || currentState is AuthNeedsSetup) {
      emit(AuthPrepare());
      final result = await _authRepository.updateUser(event.user);
      result.when(
        success: (user) => emit(AuthAuthenticated(user)),
        failure: (error) {
          if (currentState is AuthAuthenticated) {
            emit(AuthAuthenticated(currentState.user));
          } else {
            emit(AuthNeedsSetup(event.user.userInfoId!));
          }
          emit(AuthFailure(error));
        },
      );
    }
  }

  Future<void> _onAuthLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthGoogleLoginRequested(AuthGoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthPrepare());
    final result = await _authRepository.signInWithGoogle();
    result.when(
      success: (user) {
        if (user != null) {
          if (user.activityLevel == null || user.activityLevel!.isEmpty) {
            emit(AuthNeedsSetup(_authRepository.signedInUser!.id!));
          } else {
            emit(AuthAuthenticated(user));
          }
        } else {
          final userInfoId = _authRepository.signedInUser?.id;
          if (userInfoId != null) {
            emit(AuthNeedsSetup(userInfoId));
          } else {
            emit(AuthUnauthenticated());
          }
        }
      },
      failure: (error) => emit(AuthFailure(error)),
    );
  }
}
