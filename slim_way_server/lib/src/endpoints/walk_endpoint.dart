import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';
import '../generated/protocol.dart';

class WalkEndpoint extends Endpoint {
  Future<void> addWalk(Session session, Walk walk) async {
    final authInfo = session.authenticated;
    
    if (authInfo == null) {
      session.log('DEBUG: [WalkEndpoint] AuthInfo is NULL', level: LogLevel.error);
      throw Exception('Serverpod: User is not authenticated.');
    }
    
    final userId = authInfo.userId;
    session.log('DEBUG: [WalkEndpoint] Authenticated User ID: $userId', level: LogLevel.debug);
    
    walk.userId = userId;
    await Walk.db.insertRow(session, walk);

    // Update Daily Log
    await _updateDailyLog(session, walk.userId, 0, walk.calories, walk.createdAt);
  }

  Future<void> syncSteps(Session session, int userId, int newSteps, DateTime date) async {
    var utcDate = date.toUtc();
    var startOfDay = DateTime.utc(utcDate.year, utcDate.month, utcDate.day);
    var endOfDay = startOfDay.add(const Duration(days: 1));

    var autoWalk = await Walk.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          (t.createdAt >= startOfDay) &
          (t.createdAt < endOfDay) &
          (t.distanceKm.equals(-1.0)), 
    );

    double addedCalories = newSteps * 0.04;

    if (autoWalk == null) {
      autoWalk = Walk(
        userId: userId,
        steps: newSteps,
        distanceKm: -1.0,
        calories: addedCalories,
        createdAt: startOfDay, // Use start of day for identification
      );
      await Walk.db.insertRow(session, autoWalk);
      
      if (addedCalories > 0) {
        await _updateDailyLog(session, userId, 0, addedCalories, date);
      }
    } else {
      // Calculate delta to update DailyLog accurately
      double calorieDelta = addedCalories - autoWalk.calories;
      
      autoWalk.steps = newSteps;
      autoWalk.calories = addedCalories;
      await Walk.db.updateRow(session, autoWalk);

      if (calorieDelta != 0) {
        await _updateDailyLog(session, userId, 0, calorieDelta, date);
      }
    }
  }

  Future<List<Walk>> getWalkLogs(
    Session session,
    int userId,
    DateTime date,
  ) async {
    var startOfDay = DateTime(date.year, date.month, date.day);
    var endOfDay = startOfDay.add(const Duration(days: 1));

    return await Walk.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          (t.createdAt >= startOfDay) &
          (t.createdAt < endOfDay),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<List<Walk>> getWalkHistory(
    Session session,
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await Walk.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          (t.createdAt >= startDate) &
          (t.createdAt <= endDate),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<void> _updateDailyLog(
    Session session,
    int userId,
    double foodCal,
    double walkCal,
    DateTime date,
  ) async {
    var utcDate = date.toUtc();
    var startOfDay = DateTime.utc(utcDate.year, utcDate.month, utcDate.day);
    var endOfDay = startOfDay.add(const Duration(days: 1));

    var log = await DailyLog.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          (t.date >= startOfDay) &
          (t.date < endOfDay),
    );

    if (log == null) {
      log = DailyLog(
        userId: userId,
        date: startOfDay,
        foodCal: foodCal,
        walkCal: walkCal,
        netCal: foodCal - walkCal,
        createdAt: DateTime.now(),
      );
      await DailyLog.db.insertRow(session, log);
    } else {
      log.foodCal += foodCal;
      if (log.foodCal < 0) log.foodCal = 0;
      
      log.walkCal += walkCal;
      if (log.walkCal < 0) log.walkCal = 0;
      
      log.netCal = log.foodCal - log.walkCal;
      await DailyLog.db.updateRow(session, log);
    }
  }
}
