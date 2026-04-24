/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:slim_way_client/src/protocol/ai_analysis_result.dart' as _i5;
import 'dart:typed_data' as _i6;
import 'package:slim_way_client/src/protocol/daily_log.dart' as _i7;
import 'package:slim_way_client/src/protocol/food.dart' as _i8;
import 'package:slim_way_client/src/protocol/user.dart' as _i9;
import 'package:slim_way_client/src/protocol/walk.dart' as _i10;
import 'package:slim_way_client/src/protocol/weekly_weight.dart' as _i11;
import 'package:slim_way_client/src/protocol/greetings/greeting.dart' as _i12;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i13;
import 'protocol.dart' as _i14;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// {@category Endpoint}
class EndpointAi extends _i2.EndpointRef {
  EndpointAi(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'ai';

  _i3.Future<_i5.AiAnalysisResult> analyzeFoodImage(
    _i6.ByteData imageData, {
    String? customPrompt,
  }) => caller.callServerEndpoint<_i5.AiAnalysisResult>(
    'ai',
    'analyzeFoodImage',
    {
      'imageData': imageData,
      'customPrompt': customPrompt,
    },
  );

  _i3.Future<String> chatWithAi(
    List<String> history,
    String message, {
    _i7.DailyLog? dailyLog,
  }) => caller.callServerEndpoint<String>(
    'ai',
    'chatWithAi',
    {
      'history': history,
      'message': message,
      'dailyLog': dailyLog,
    },
  );
}

/// {@category Endpoint}
class EndpointFood extends _i2.EndpointRef {
  EndpointFood(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'food';

  _i3.Future<_i8.Food> addFood(_i8.Food food) =>
      caller.callServerEndpoint<_i8.Food>(
        'food',
        'addFood',
        {'food': food},
      );

  _i3.Future<List<_i8.Food>> getFoodLogs(
    int userId,
    DateTime date,
  ) => caller.callServerEndpoint<List<_i8.Food>>(
    'food',
    'getFoodLogs',
    {
      'userId': userId,
      'date': date,
    },
  );

  _i3.Future<List<_i8.Food>> getFoodHistory(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) => caller.callServerEndpoint<List<_i8.Food>>(
    'food',
    'getFoodHistory',
    {
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
    },
  );

  _i3.Future<void> deleteFood(
    int foodId,
    int userId,
  ) => caller.callServerEndpoint<void>(
    'food',
    'deleteFood',
    {
      'foodId': foodId,
      'userId': userId,
    },
  );
}

/// {@category Endpoint}
class EndpointGoogleAuth extends _i2.EndpointRef {
  EndpointGoogleAuth(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'googleAuth';

  /// Google ID token yoki access token orqali Serverpod session yaratadi.
  /// [token] — idToken yoki accessToken bo'lishi mumkin.
  /// [isAccessToken] — true bo'lsa access token sifatida tekshiriladi.
  _i3.Future<String?> signInWithGoogle(
    String token, {
    required bool isAccessToken,
  }) => caller.callServerEndpoint<String?>(
    'googleAuth',
    'signInWithGoogle',
    {
      'token': token,
      'isAccessToken': isAccessToken,
    },
  );

  /// Access token orqali kirish (idToken null bo'lganda ishlatiladi).
  _i3.Future<String?> signInWithAccessToken(String accessToken) =>
      caller.callServerEndpoint<String?>(
        'googleAuth',
        'signInWithAccessToken',
        {'accessToken': accessToken},
      );
}

/// {@category Endpoint}
class EndpointLeaderboard extends _i2.EndpointRef {
  EndpointLeaderboard(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'leaderboard';

  /// Top 10 users by streak count
  _i3.Future<List<_i9.User>> getTopUsers() =>
      caller.callServerEndpoint<List<_i9.User>>(
        'leaderboard',
        'getTopUsers',
        {},
      );

  /// Get rank of a specific user
  _i3.Future<int> getUserRank(int userId) => caller.callServerEndpoint<int>(
    'leaderboard',
    'getUserRank',
    {'userId': userId},
  );
}

/// {@category Endpoint}
class EndpointStats extends _i2.EndpointRef {
  EndpointStats(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'stats';

  _i3.Future<_i7.DailyLog?> getDailySummary(
    int userId,
    DateTime date,
  ) => caller.callServerEndpoint<_i7.DailyLog?>(
    'stats',
    'getDailySummary',
    {
      'userId': userId,
      'date': date,
    },
  );

  _i3.Future<List<_i7.DailyLog>> getHistory(int userId) =>
      caller.callServerEndpoint<List<_i7.DailyLog>>(
        'stats',
        'getHistory',
        {'userId': userId},
      );
}

/// {@category Endpoint}
class EndpointUser extends _i2.EndpointRef {
  EndpointUser(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'user';

  _i3.Future<_i9.User> createUser(_i9.User user) =>
      caller.callServerEndpoint<_i9.User>(
        'user',
        'createUser',
        {'user': user},
      );

  _i3.Future<_i9.User?> getUser(int id) => caller.callServerEndpoint<_i9.User?>(
    'user',
    'getUser',
    {'id': id},
  );

  _i3.Future<_i9.User?> getUserByAuthId(int authId) =>
      caller.callServerEndpoint<_i9.User?>(
        'user',
        'getUserByAuthId',
        {'authId': authId},
      );

  _i3.Future<_i9.User> updateUser(_i9.User user) =>
      caller.callServerEndpoint<_i9.User>(
        'user',
        'updateUser',
        {'user': user},
      );

  _i3.Future<_i9.User?> getMe() => caller.callServerEndpoint<_i9.User?>(
    'user',
    'getMe',
    {},
  );
}

/// {@category Endpoint}
class EndpointWalk extends _i2.EndpointRef {
  EndpointWalk(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'walk';

  _i3.Future<void> addWalk(_i10.Walk walk) => caller.callServerEndpoint<void>(
    'walk',
    'addWalk',
    {'walk': walk},
  );

  _i3.Future<void> syncSteps(
    int userId,
    int newSteps,
    DateTime date,
  ) => caller.callServerEndpoint<void>(
    'walk',
    'syncSteps',
    {
      'userId': userId,
      'newSteps': newSteps,
      'date': date,
    },
  );

  _i3.Future<List<_i10.Walk>> getWalkLogs(
    int userId,
    DateTime date,
  ) => caller.callServerEndpoint<List<_i10.Walk>>(
    'walk',
    'getWalkLogs',
    {
      'userId': userId,
      'date': date,
    },
  );

  _i3.Future<List<_i10.Walk>> getWalkHistory(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) => caller.callServerEndpoint<List<_i10.Walk>>(
    'walk',
    'getWalkHistory',
    {
      'userId': userId,
      'startDate': startDate,
      'endDate': endDate,
    },
  );
}

/// {@category Endpoint}
class EndpointWater extends _i2.EndpointRef {
  EndpointWater(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'water';

  /// Foydalanuvchining bugungi suv iste'molini oshirish
  _i3.Future<_i7.DailyLog> addWater(
    int userId,
    int amountMl,
    DateTime date,
  ) => caller.callServerEndpoint<_i7.DailyLog>(
    'water',
    'addWater',
    {
      'userId': userId,
      'amountMl': amountMl,
      'date': date,
    },
  );

  /// Foydalanuvchi stakanining hajmini yangilash
  _i3.Future<_i9.User> updateWaterGlassSize(
    int userId,
    int glassSize,
  ) => caller.callServerEndpoint<_i9.User>(
    'water',
    'updateWaterGlassSize',
    {
      'userId': userId,
      'glassSize': glassSize,
    },
  );
}

/// {@category Endpoint}
class EndpointWeeklyWeight extends _i2.EndpointRef {
  EndpointWeeklyWeight(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'weeklyWeight';

  _i3.Future<_i11.WeeklyWeight> addWeight(_i11.WeeklyWeight weight) =>
      caller.callServerEndpoint<_i11.WeeklyWeight>(
        'weeklyWeight',
        'addWeight',
        {'weight': weight},
      );

  _i3.Future<List<_i11.WeeklyWeight>> getWeightHistory(int userId) =>
      caller.callServerEndpoint<List<_i11.WeeklyWeight>>(
        'weeklyWeight',
        'getWeightHistory',
        {'userId': userId},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i2.EndpointRef {
  EndpointGreeting(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i3.Future<_i12.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i12.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    auth = _i13.Caller(client);
    auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i13.Caller auth;

  late final _i1.Caller auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i14.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    ai = EndpointAi(this);
    food = EndpointFood(this);
    googleAuth = EndpointGoogleAuth(this);
    leaderboard = EndpointLeaderboard(this);
    stats = EndpointStats(this);
    user = EndpointUser(this);
    walk = EndpointWalk(this);
    water = EndpointWater(this);
    weeklyWeight = EndpointWeeklyWeight(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointAi ai;

  late final EndpointFood food;

  late final EndpointGoogleAuth googleAuth;

  late final EndpointLeaderboard leaderboard;

  late final EndpointStats stats;

  late final EndpointUser user;

  late final EndpointWalk walk;

  late final EndpointWater water;

  late final EndpointWeeklyWeight weeklyWeight;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'ai': ai,
    'food': food,
    'googleAuth': googleAuth,
    'leaderboard': leaderboard,
    'stats': stats,
    'user': user,
    'walk': walk,
    'water': water,
    'weeklyWeight': weeklyWeight,
    'greeting': greeting,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'auth': modules.auth,
    'auth_idp': modules.auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
