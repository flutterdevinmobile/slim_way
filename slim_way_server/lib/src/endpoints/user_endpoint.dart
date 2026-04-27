import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../generated/protocol.dart';

class UserEndpoint extends Endpoint {
  Future<User> createUser(Session session, User user) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('Unauthenticated: Please log in again.');
    }

    final userId = authInfo.userId;
    session.log('SERVER createUser: userId=$userId, name=${user.name}', level: LogLevel.info);

    // Set mandatory fields
    user.createdAt = DateTime.now();
    user.updatedAt = DateTime.now();
    user.userInfoId = userId;

    // Check for existing profile
    final existingUser = await User.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    if (existingUser != null) {
      session.log('SERVER createUser: Profile already exists for userId=$userId. Returning existing.', level: LogLevel.info);
      return existingUser;
    }

    // Cleaned up for production stability
    return await User.db.insertRow(session, user);
  }

  Future<User?> getUser(Session session, int id) async {
    return await User.db.findById(session, id);
  }

  Future<User?> getUserByAuthId(Session session, int authId) async {
    session.log('DEBUG: getUserByAuthId called for authId: $authId', level: LogLevel.debug);
    
    try {
      final user = await User.db.findFirstRow(
        session,
        where: (t) => t.userInfoId.equals(authId),
      );

      if (user == null) {
        session.log('DEBUG: No profile found in "users" table for serverpod_user_info.id: $authId', level: LogLevel.info);
        // Automatically create a default profile
        final userInfo = await Users.findUserByUserId(session, authId);
        final newUser = User(
          userInfoId: authId,
          name: userInfo?.userName ?? userInfo?.email?.split('@').first ?? 'User $authId',
          age: 25,
          gender: 'Not specified',
          height: 170,
          currentWeight: 70.0,
          targetWeight: 65.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        try {
          final insertedUser = await User.db.insertRow(session, newUser);
          session.log('DEBUG: Auto-created default profile for authId: $authId', level: LogLevel.info);
          return insertedUser;
        } catch (e) {
          // If insert fails (e.g., unique constraint violation from a race condition),
          // try to fetch the profile again.
          session.log('DEBUG: Insert failed ($e), trying to fetch again for authId: $authId', level: LogLevel.warning);
          final existing = await User.db.findFirstRow(
            session,
            where: (t) => t.userInfoId.equals(authId),
          );
          if (existing != null) return existing;
          rethrow;
        }
      } else {
        session.log('DEBUG: Found profile for user: ${user.name} (ID: ${user.id})', level: LogLevel.debug);
      }
      return user;
    } catch (e, stack) {
      session.log('ERROR: Database exception in getUserByAuthId: $e', level: LogLevel.error, stackTrace: stack);
      return null;
    }
  }

  Future<User> updateUser(Session session, User user) async {
    final authInfo = session.authenticated;
    session.log('DEBUG-AUTH: [Endpoint] session.authenticated result: $authInfo', level: LogLevel.debug);
    
    if (authInfo == null) {
      session.log('DEBUG-AUTH-ERROR: [Endpoint] authInfo is null. Authentication failed.', level: LogLevel.error);
      throw Exception('Serverpod: User is not authenticated. Please ensure the authorization header is sent correctly.');
    }
    
    final userId = authInfo.userId;

    // Find the actual user record for this authenticated account
    final existingUser = await User.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(userId),
    );

    if (existingUser == null) {
      throw Exception('User profile not found. Please complete registration first.');
    }

    // AI GENERATION FOR NUTRITION
    final apiKey = session.passwords['googleAiApiKey'];
    if (apiKey != null && apiKey.isNotEmpty && user.activityLevel != null && user.monthlyWeightLossGoal != null) {
      try {
        final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);
        final prompt = '''
        You are an elite clinical nutritionist AI.
        User Profile:
        Age: ${user.age}
        Gender: ${user.gender}
        Height: ${user.height} cm
        Current Weight: ${user.currentWeight} kg
        Activity Level: ${user.activityLevel}
        Goal: Lose ${user.monthlyWeightLossGoal} kg per month.
        
        Calculate the precise daily calorie limit (integer) and daily water intake in ml (integer) for this user to achieve their goal safely. Use established scientific formulas (like Mifflin-St Jeor).
        Respond ONLY with valid JSON. Example: {"calories": 1800, "water": 2500}
        ''';
        
        session.log('AI Calculation started for user \$userId', level: LogLevel.info);
        final response = await model.generateContent([Content.text(prompt)]);
        final text = response.text;
        if (text != null && text.isNotEmpty) {
          final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
          final match = RegExp(r'\{[^{}]*\}').firstMatch(cleaned);
          if (match != null) {
            final json = jsonDecode(match.group(0)!);
            final cal = (json['calories'] as num?)?.toInt();
            final h2o = (json['water'] as num?)?.toInt();
            if (cal != null) user.dailyCalorieGoal = cal;
            if (h2o != null) user.dailyWaterGoal = h2o;
            session.log('AI Success: \$cal kcal, \$h2o ml water', level: LogLevel.info);
          }
        }
      } catch (e) {
        session.log('AI Recalculation failed: \$e', level: LogLevel.error);
      }
    }

    // Merge incoming data into existing record to preserve the correct 'id' and 'userInfoId'
    existingUser.name = user.name;
    existingUser.age = user.age;
    existingUser.gender = user.gender;
    existingUser.height = user.height;
    existingUser.currentWeight = user.currentWeight;
    existingUser.targetWeight = user.targetWeight;
    existingUser.waterGlassSize = user.waterGlassSize;
    existingUser.activityLevel = user.activityLevel;
    existingUser.monthlyWeightLossGoal = user.monthlyWeightLossGoal;
    
    if (user.dailyCalorieGoal != null) existingUser.dailyCalorieGoal = user.dailyCalorieGoal;
    if (user.dailyWaterGoal != null) existingUser.dailyWaterGoal = user.dailyWaterGoal;
    
    existingUser.updatedAt = DateTime.now();

    return await User.db.updateRow(session, existingUser);
  }

  Future<User?> getMe(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) return null;
    
    return await getUserByAuthId(session, authInfo.userId);
  }
}

