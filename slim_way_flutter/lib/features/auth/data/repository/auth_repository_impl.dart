import 'package:slim_way_client/slim_way_client.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_auth_email_flutter/serverpod_auth_email_flutter.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart' as google_auth;
import 'package:slim_way_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/utils/safe_call.dart';
import 'package:slim_way_flutter/shared/application/configs/app_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Client client;
  final SessionManager sessionManager;
  late final EmailAuthController _authController;

  String? _pendingPassword;

  AuthRepositoryImpl({
    required this.client,
    required this.sessionManager,
  }) {
    _authController = EmailAuthController(client.modules.auth);
  }

  @override
  Future<Safed<BaseException, User?>> getUserByAuthId(int authId) =>
      safeCall(() async {
        return await client.user.getUserByAuthId(authId);
      });

  @override
  Future<Safed<BaseException, void>> signOut() =>
      safeCall(() => sessionManager.signOutDevice());

  @override
  bool get isSignedIn => sessionManager.isSignedIn;

  @override
  UserInfo? get signedInUser => sessionManager.signedInUser;

  @override
  Future<Safed<BaseException, void>> initializeSession() =>
      safeCall(() async {
        // sessionManager.initialize() is already called in main.dart
      });

  @override
  Future<Safed<BaseException, User>> updateUser(User user) =>
      safeCall(() => client.user.updateUser(user));

  @override
  Future<Safed<BaseException, User?>> signInWithEmail(String email, String password) =>
      safeCall(() async {
        final userInfo = await _authController.signIn(email, password);
        if (userInfo == null) throw Exception('Invalid credentials or sign in failed');
        return await client.user.getUserByAuthId(userInfo.id!);
      });

  @override
  Future<Safed<BaseException, User?>> signInWithGoogle() =>
      safeCall(() async {
        try {
          final userInfo = await google_auth.signInWithGoogle(
            client.modules.auth,
            redirectUri: Uri.parse(AppConfig.googleRedirectUri),
            serverClientId: AppConfig.googleServerClientId,
          );

          if (userInfo == null) {
            throw Exception('Google orqali kirish bekor qilindi yoki xato yuz berdi.');
          }

          return await client.user.getUserByAuthId(userInfo.id!);
        } catch (e) {
          rethrow;
        }
      });

  @override
  Future<Safed<BaseException, bool>> createAccountRequest(String name, String email, String password) =>
      safeCall(() async {
        _pendingPassword = password;
        final success = await _authController.createAccountRequest(name, email, password);
        return success;
      });

  @override
  Future<Safed<BaseException, User?>> validateAccount(String email, String code) {
    return safeCall(() async {
      final userInfo = await _authController.validateAccount(email, code);
      if (userInfo == null) {
        throw Exception('Invalid verification code');
      }

      if (_pendingPassword != null) {
        final loginInfo = await _authController.signIn(email, _pendingPassword!);
        if (loginInfo != null) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      _pendingPassword = null;
      return await client.user.getUserByAuthId(userInfo.id!);
    });
  }

  @override
  Future<Safed<BaseException, User?>> getMe() =>
      safeCall(() => client.user.getMe());
}
