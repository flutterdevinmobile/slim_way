import 'package:slim_way_client/slim_way_client.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';

abstract class AuthRepository {
  Future<Safed<BaseException, User?>> getUserByAuthId(int authId);
  Future<Safed<BaseException, void>> signOut();
  bool get isSignedIn;
  UserInfo? get signedInUser;
  Future<Safed<BaseException, void>> initializeSession();
  Future<Safed<BaseException, User>> updateUser(User user);
  Future<Safed<BaseException, User?>> signInWithEmail(String email, String password);
  Future<Safed<BaseException, User?>> signInWithGoogle();
  Future<Safed<BaseException, bool>> createAccountRequest(String name, String email, String password);
  Future<Safed<BaseException, User?>> validateAccount(String email, String code);
  Future<Safed<BaseException, User?>> getMe();
}

