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
    // 1. Identify the calendar day based on client's local components
    var startOfDay = DateTime.utc(date.year, date.month, date.day);
    var endOfDay = startOfDay.add(const Duration(days: 1));

    // 2. Find ALL automatic walk records for this day (to handle/clean existing duplicates)
    var autoWalks = await Walk.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          (t.createdAt >= startOfDay) &
          (t.createdAt < endOfDay) &
          (t.distanceKm.equals(-1.0)),
    );

    double totalCalories = newSteps * 0.04;
    
    if (autoWalks.isEmpty) {
      // Create new record
      var autoWalk = Walk(
        userId: userId,
        steps: newSteps,
        distanceKm: -1.0,
        calories: totalCalories,
        createdAt: startOfDay,
      );
      await Walk.db.insertRow(session, autoWalk);
      
      if (totalCalories > 0) {
        await _updateDailyLog(session, userId, 0, totalCalories, date);
      }
    } else {
      // Calculate current total calories from ALL existing automatic records for this day
      double existingTotalCalories = autoWalks.fold(0.0, (sum, w) => sum + w.calories);
      double calorieDelta = totalCalories - existingTotalCalories;

      // Update the first record and delete others (cleanup)
      var primary = autoWalks.first;
      primary.steps = newSteps;
      primary.calories = totalCalories;
      await Walk.db.updateRow(session, primary);

      if (autoWalks.length > 1) {
        for (int i = 1; i < autoWalks.length; i++) {
          await Walk.db.deleteRow(session, autoWalks[i]);
        }
      }

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

    var walks = await Walk.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          (t.createdAt >= startOfDay) &
          (t.createdAt < endOfDay),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );

    // Merge automatic steps (distanceKm == -1.0) into one entry for UI
    var manualWalks = walks.where((w) => w.distanceKm != -1.0).toList();
    var autoWalks = walks.where((w) => w.distanceKm == -1.0).toList();

    if (autoWalks.isEmpty) return manualWalks;

    // Use the one with most steps as primary, or merge if they look different
    var combinedAuto = autoWalks.first;
    if (autoWalks.length > 1) {
      // If the values are identical (duplicate bug), just use one. 
      // If they are different, we might have a timezone overlap issue.
      // But for UI, showing the MAX steps is usually what user expects for "Automatic" today.
      int maxSteps = autoWalks.fold(0, (max, w) => w.steps > max ? w.steps : max);
      double maxCal = maxSteps * 0.04;

      combinedAuto.steps = maxSteps;
      combinedAuto.calories = maxCal;
    }

    return [combinedAuto, ...manualWalks];
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
