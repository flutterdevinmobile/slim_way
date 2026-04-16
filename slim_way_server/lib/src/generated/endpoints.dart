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
import 'package:serverpod/serverpod.dart' as _i1;
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../endpoints/ai_endpoint.dart' as _i4;
import '../endpoints/food_endpoint.dart' as _i5;
import '../endpoints/google_auth_endpoint.dart' as _i6;
import '../endpoints/stats_endpoint.dart' as _i7;
import '../endpoints/user_endpoint.dart' as _i8;
import '../endpoints/walk_endpoint.dart' as _i9;
import '../endpoints/water_endpoint.dart' as _i10;
import '../endpoints/weekly_weight_endpoint.dart' as _i11;
import '../greetings/greeting_endpoint.dart' as _i12;
import 'dart:typed_data' as _i13;
import 'package:slim_way_server/src/generated/food.dart' as _i14;
import 'package:slim_way_server/src/generated/user.dart' as _i15;
import 'package:slim_way_server/src/generated/walk.dart' as _i16;
import 'package:slim_way_server/src/generated/weekly_weight.dart' as _i17;
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as _i18;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i19;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i20;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'ai': _i4.AiEndpoint()
        ..initialize(
          server,
          'ai',
          null,
        ),
      'food': _i5.FoodEndpoint()
        ..initialize(
          server,
          'food',
          null,
        ),
      'googleAuth': _i6.GoogleAuthEndpoint()
        ..initialize(
          server,
          'googleAuth',
          null,
        ),
      'stats': _i7.StatsEndpoint()
        ..initialize(
          server,
          'stats',
          null,
        ),
      'user': _i8.UserEndpoint()
        ..initialize(
          server,
          'user',
          null,
        ),
      'walk': _i9.WalkEndpoint()
        ..initialize(
          server,
          'walk',
          null,
        ),
      'water': _i10.WaterEndpoint()
        ..initialize(
          server,
          'water',
          null,
        ),
      'weeklyWeight': _i11.WeeklyWeightEndpoint()
        ..initialize(
          server,
          'weeklyWeight',
          null,
        ),
      'greeting': _i12.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['ai'] = _i1.EndpointConnector(
      name: 'ai',
      endpoint: endpoints['ai']!,
      methodConnectors: {
        'analyzeFoodImage': _i1.MethodConnector(
          name: 'analyzeFoodImage',
          params: {
            'imageData': _i1.ParameterDescription(
              name: 'imageData',
              type: _i1.getType<_i13.ByteData>(),
              nullable: false,
            ),
            'customPrompt': _i1.ParameterDescription(
              name: 'customPrompt',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ai'] as _i4.AiEndpoint).analyzeFoodImage(
                session,
                params['imageData'],
                customPrompt: params['customPrompt'],
              ),
        ),
        'chatWithAi': _i1.MethodConnector(
          name: 'chatWithAi',
          params: {
            'history': _i1.ParameterDescription(
              name: 'history',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'message': _i1.ParameterDescription(
              name: 'message',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['ai'] as _i4.AiEndpoint).chatWithAi(
                session,
                params['history'],
                params['message'],
              ),
        ),
      },
    );
    connectors['food'] = _i1.EndpointConnector(
      name: 'food',
      endpoint: endpoints['food']!,
      methodConnectors: {
        'addFood': _i1.MethodConnector(
          name: 'addFood',
          params: {
            'food': _i1.ParameterDescription(
              name: 'food',
              type: _i1.getType<_i14.Food>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['food'] as _i5.FoodEndpoint).addFood(
                session,
                params['food'],
              ),
        ),
        'getFoodLogs': _i1.MethodConnector(
          name: 'getFoodLogs',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['food'] as _i5.FoodEndpoint).getFoodLogs(
                session,
                params['userId'],
                params['date'],
              ),
        ),
        'getFoodHistory': _i1.MethodConnector(
          name: 'getFoodHistory',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'startDate': _i1.ParameterDescription(
              name: 'startDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'endDate': _i1.ParameterDescription(
              name: 'endDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['food'] as _i5.FoodEndpoint).getFoodHistory(
                session,
                params['userId'],
                params['startDate'],
                params['endDate'],
              ),
        ),
        'deleteFood': _i1.MethodConnector(
          name: 'deleteFood',
          params: {
            'foodId': _i1.ParameterDescription(
              name: 'foodId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['food'] as _i5.FoodEndpoint).deleteFood(
                session,
                params['foodId'],
                params['userId'],
              ),
        ),
      },
    );
    connectors['googleAuth'] = _i1.EndpointConnector(
      name: 'googleAuth',
      endpoint: endpoints['googleAuth']!,
      methodConnectors: {
        'signInWithGoogle': _i1.MethodConnector(
          name: 'signInWithGoogle',
          params: {
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isAccessToken': _i1.ParameterDescription(
              name: 'isAccessToken',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleAuth'] as _i6.GoogleAuthEndpoint)
                  .signInWithGoogle(
                    session,
                    params['token'],
                    isAccessToken: params['isAccessToken'],
                  ),
        ),
        'signInWithAccessToken': _i1.MethodConnector(
          name: 'signInWithAccessToken',
          params: {
            'accessToken': _i1.ParameterDescription(
              name: 'accessToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['googleAuth'] as _i6.GoogleAuthEndpoint)
                  .signInWithAccessToken(
                    session,
                    params['accessToken'],
                  ),
        ),
      },
    );
    connectors['stats'] = _i1.EndpointConnector(
      name: 'stats',
      endpoint: endpoints['stats']!,
      methodConnectors: {
        'getDailySummary': _i1.MethodConnector(
          name: 'getDailySummary',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['stats'] as _i7.StatsEndpoint).getDailySummary(
                    session,
                    params['userId'],
                    params['date'],
                  ),
        ),
        'getHistory': _i1.MethodConnector(
          name: 'getHistory',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['stats'] as _i7.StatsEndpoint).getHistory(
                session,
                params['userId'],
              ),
        ),
      },
    );
    connectors['user'] = _i1.EndpointConnector(
      name: 'user',
      endpoint: endpoints['user']!,
      methodConnectors: {
        'createUser': _i1.MethodConnector(
          name: 'createUser',
          params: {
            'user': _i1.ParameterDescription(
              name: 'user',
              type: _i1.getType<_i15.User>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i8.UserEndpoint).createUser(
                session,
                params['user'],
              ),
        ),
        'getUser': _i1.MethodConnector(
          name: 'getUser',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i8.UserEndpoint).getUser(
                session,
                params['id'],
              ),
        ),
        'getUserByAuthId': _i1.MethodConnector(
          name: 'getUserByAuthId',
          params: {
            'authId': _i1.ParameterDescription(
              name: 'authId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['user'] as _i8.UserEndpoint).getUserByAuthId(
                    session,
                    params['authId'],
                  ),
        ),
        'updateUser': _i1.MethodConnector(
          name: 'updateUser',
          params: {
            'user': _i1.ParameterDescription(
              name: 'user',
              type: _i1.getType<_i15.User>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['user'] as _i8.UserEndpoint).updateUser(
                session,
                params['user'],
              ),
        ),
      },
    );
    connectors['walk'] = _i1.EndpointConnector(
      name: 'walk',
      endpoint: endpoints['walk']!,
      methodConnectors: {
        'addWalk': _i1.MethodConnector(
          name: 'addWalk',
          params: {
            'walk': _i1.ParameterDescription(
              name: 'walk',
              type: _i1.getType<_i16.Walk>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['walk'] as _i9.WalkEndpoint).addWalk(
                session,
                params['walk'],
              ),
        ),
        'syncSteps': _i1.MethodConnector(
          name: 'syncSteps',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'newSteps': _i1.ParameterDescription(
              name: 'newSteps',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['walk'] as _i9.WalkEndpoint).syncSteps(
                session,
                params['userId'],
                params['newSteps'],
                params['date'],
              ),
        ),
        'getWalkLogs': _i1.MethodConnector(
          name: 'getWalkLogs',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['walk'] as _i9.WalkEndpoint).getWalkLogs(
                session,
                params['userId'],
                params['date'],
              ),
        ),
        'getWalkHistory': _i1.MethodConnector(
          name: 'getWalkHistory',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'startDate': _i1.ParameterDescription(
              name: 'startDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'endDate': _i1.ParameterDescription(
              name: 'endDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['walk'] as _i9.WalkEndpoint).getWalkHistory(
                session,
                params['userId'],
                params['startDate'],
                params['endDate'],
              ),
        ),
      },
    );
    connectors['water'] = _i1.EndpointConnector(
      name: 'water',
      endpoint: endpoints['water']!,
      methodConnectors: {
        'addWater': _i1.MethodConnector(
          name: 'addWater',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'amountMl': _i1.ParameterDescription(
              name: 'amountMl',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'date': _i1.ParameterDescription(
              name: 'date',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['water'] as _i10.WaterEndpoint).addWater(
                session,
                params['userId'],
                params['amountMl'],
                params['date'],
              ),
        ),
        'updateWaterGlassSize': _i1.MethodConnector(
          name: 'updateWaterGlassSize',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'glassSize': _i1.ParameterDescription(
              name: 'glassSize',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['water'] as _i10.WaterEndpoint)
                  .updateWaterGlassSize(
                    session,
                    params['userId'],
                    params['glassSize'],
                  ),
        ),
      },
    );
    connectors['weeklyWeight'] = _i1.EndpointConnector(
      name: 'weeklyWeight',
      endpoint: endpoints['weeklyWeight']!,
      methodConnectors: {
        'addWeight': _i1.MethodConnector(
          name: 'addWeight',
          params: {
            'weight': _i1.ParameterDescription(
              name: 'weight',
              type: _i1.getType<_i17.WeeklyWeight>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['weeklyWeight'] as _i11.WeeklyWeightEndpoint)
                      .addWeight(
                        session,
                        params['weight'],
                      ),
        ),
        'getWeightHistory': _i1.MethodConnector(
          name: 'getWeightHistory',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['weeklyWeight'] as _i11.WeeklyWeightEndpoint)
                      .getWeightHistory(
                        session,
                        params['userId'],
                      ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i12.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    modules['serverpod_auth'] = _i18.Endpoints()..initializeEndpoints(server);
    modules['serverpod_auth_idp'] = _i19.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i20.Endpoints()
      ..initializeEndpoints(server);
  }
}
