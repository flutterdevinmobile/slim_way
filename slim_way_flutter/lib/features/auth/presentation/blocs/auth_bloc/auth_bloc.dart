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
    debugPrint('DEBUG: AuthBloc._onAuthInitRequested starting...');
    emit(AuthPrepare());
    final initResult = await _authRepository.initializeSession();
    
    await initResult.when<Future<void>>(
      success: (_) async {
        debugPrint('DEBUG: initializeSession success. isSignedIn: ${_authRepository.isSignedIn}');
        if (_authRepository.isSignedIn) {
          final userInfo = _authRepository.signedInUser;
          if (userInfo != null) {
            debugPrint('DEBUG: userInfo found in cache. ID: ${userInfo.id}');
            final userInfoId = userInfo.id!;
            final userResult = await _authRepository.getUserByAuthId(userInfoId);
            userResult.when(
              success: (user) {
                if (user != null) {
                  debugPrint('DEBUG: User profile fetched. Name: ${user.name}');
                  
                  // Ensure name is not empty
                  if (user.name.trim().isEmpty) {
                    user.name = userInfo.userName ?? userInfo.email?.split('@').first ?? 'User';
                  }

                  emit(AuthAuthenticated(user));
                } else {
                  debugPrint('DEBUG: No profile found for ID $userInfoId');
                  emit(AuthNeedsSetup(userInfoId));
                }
              },
              failure: (err) {
                debugPrint('DEBUG: getUserByAuthId failed: $err');
                // OFFLINE MODE Support:
                // If it's a network error (SocketException, timeout, etc.), 
                // stay authenticated using a placeholder user or cached info.
                final errStr = err.toString().toLowerCase();
                if (errStr.contains('socket') || errStr.contains('timeout') || errStr.contains('host')) {
                  debugPrint('DEBUG: Connectivity issue detected. Entering Offline Mode.');
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
            debugPrint('DEBUG: signedInUser is null. Calling getMe()...');
            final meResult = await _authRepository.getMe();
            meResult.when(
              success: (user) {
                if (user != null) {
                  debugPrint('DEBUG: getMe() success. User: ${user.name}');

                  // Ensure name is not empty
                  if (user.name.trim().isEmpty) {
                     user.name = _authRepository.signedInUser?.userName ?? 'User';
                  }

                  emit(AuthAuthenticated(user));
                } else {
                  debugPrint('DEBUG: getMe() returned null');
                  emit(AuthUnauthenticated());
                }
              },
              failure: (err) {
                debugPrint('DEBUG: getMe() failed: $err');
                emit(AuthUnauthenticated());
              },
            );
          }
        } else {
          debugPrint('DEBUG: isSignedIn is false');
          emit(AuthUnauthenticated());
        }
      },
      failure: (error) async {
        debugPrint('DEBUG: initializeSession failed: $error');
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
          emit(AuthAuthenticated(user));
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
          emit(AuthUnauthenticated()); // Wait for verification
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
          emit(AuthAuthenticated(user));
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
    if (currentState is AuthAuthenticated) {
      final result = await _authRepository.updateUser(event.user);
      result.when(
        success: (user) => emit(AuthAuthenticated(user)),
        failure: (error) {
          // Send error to UI but DO NOT change the state to AuthFailure 
          // because we don't want to logout the user for a transient update error.
          debugPrint('DEBUG: Profile update failed: $error');
          // We can't easily send a "one-off" notification through Bloc state without a new state,
          // but at least we stay Authenticated.
          emit(AuthAuthenticated(currentState.user)); 
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
          emit(AuthAuthenticated(user));
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
