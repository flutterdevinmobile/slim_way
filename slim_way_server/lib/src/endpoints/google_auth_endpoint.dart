import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';

class GoogleAuthEndpoint extends Endpoint {
  /// Google ID token yoki access token orqali Serverpod session yaratadi.
  /// [token] — idToken yoki accessToken bo'lishi mumkin.
  /// [isAccessToken] — true bo'lsa access token sifatida tekshiriladi.
  Future<String?> signInWithGoogle(
    Session session,
    String token, {
    bool isAccessToken = false,
  }) async {
    try {
      Map<String, dynamic>? userInfo;

      if (isAccessToken) {
        userInfo = await _verifyAccessToken(token);
      } else {
        userInfo = await _verifyIdToken(token);
        // idToken ishlamasa access token sifatida ham sinab ko'rish
        userInfo ??= await _verifyAccessToken(token);
      }

      if (userInfo == null) {
        session.log('Google token tekshiruvdan o\'tmadi', level: LogLevel.warning);
        return null;
      }

      final googleId = userInfo['sub'] as String?;
      final email = userInfo['email'] as String?;
      final name = userInfo['name'] as String? ?? email?.split('@').first ?? 'User';

      if (googleId == null || email == null) {
        session.log('Token da email yoki ID yo\'q', level: LogLevel.warning);
        return null;
      }

      return await _createOrFindUserSession(session, googleId, email, name);
    } catch (e, stack) {
      session.log('Google auth xatosi: $e', level: LogLevel.error, stackTrace: stack);
      return null;
    }
  }

  /// Access token orqali kirish (idToken null bo'lganda ishlatiladi).
  Future<String?> signInWithAccessToken(Session session, String accessToken) async {
    try {
      final userInfo = await _verifyAccessToken(accessToken);
      if (userInfo == null) {
        session.log('Access token tekshiruvdan o\'tmadi', level: LogLevel.warning);
        return null;
      }

      final googleId = userInfo['sub'] as String?;
      final email = userInfo['email'] as String?;
      final name = userInfo['name'] as String? ?? email?.split('@').first ?? 'User';

      if (googleId == null || email == null) return null;

      return await _createOrFindUserSession(session, googleId, email, name);
    } catch (e, stack) {
      session.log('Access token auth xatosi: $e', level: LogLevel.error, stackTrace: stack);
      return null;
    }
  }

  /// Foydalanuvchini topadi yoki yaratadi va auth key qaytaradi.
  Future<String?> _createOrFindUserSession(
    Session session,
    String googleId,
    String email,
    String name,
  ) async {
    var userInfo = await UserInfo.db.findFirstRow(
      session,
      where: (t) => t.userIdentifier.equals(googleId),
    );

    if (userInfo == null) {
      userInfo = UserInfo(
        userIdentifier: googleId,
        email: email,
        userName: name,
        fullName: name,
        created: DateTime.now(),
        scopeNames: [],
        blocked: false,
      );
      userInfo = await Users.createUser(session, userInfo, 'google');
      if (userInfo == null) {
        session.log('Foydalanuvchi yaratib bo\'lmadi', level: LogLevel.error);
        return null;
      }
      session.log('Yangi Google foydalanuvchi yaratildi: $email');
    } else {
      session.log('Mavjud Google foydalanuvchi: $email');
    }

    final authKey = await UserAuthentication.signInUser(session, userInfo.id!, 'google');
    return '${authKey.id}:${authKey.key}';
  }

  /// Google tokeninfo API orqali ID tokenni tekshiradi.
  Future<Map<String, dynamic>?> _verifyIdToken(String idToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://oauth2.googleapis.com/tokeninfo?id_token=$idToken'),
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('error')) return null;
      if (data['email_verified'] != 'true' && data['email_verified'] != true) return null;
      return data;
    } catch (e) {
      return null;
    }
  }

  /// Google userinfo API orqali access tokenni tekshiradi.
  Future<Map<String, dynamic>?> _verifyAccessToken(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.containsKey('error')) return null;
      if (data['email_verified'] != true && data['email_verified'] != 'true') return null;
      return data;
    } catch (e) {
      return null;
    }
  }
}
