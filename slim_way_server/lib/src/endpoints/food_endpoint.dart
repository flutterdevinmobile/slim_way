import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class FoodEndpoint extends Endpoint {
  Future<Food> addFood(Session session, Food food) async {
    if (food.calories <= 0) {
      throw Exception('Kaloriya miqdori 0 dan katta bo\'lishi kerak');
    }

    await Food.db.insertRow(session, food);

    // Update Daily Log
    await _updateDailyLog(
      session,
      food.userId,
      food.calories,
      food.protein ?? 0,
      food.fat ?? 0,
      food.carbs ?? 0,
      0,
      food.createdAt,
    );

    return food;
  }

  Future<List<Food>> getFoodLogs(
    Session session,
    int userId,
    DateTime date,
  ) async {
    var utcDate = date.toUtc();
    var startOfDay = DateTime.utc(utcDate.year, utcDate.month, utcDate.day);
    var endOfDay = startOfDay.add(const Duration(days: 1));

    return await Food.db.find(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          (t.createdAt >= startOfDay) &
          (t.createdAt < endOfDay),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  Future<List<Food>> getFoodHistory(
    Session session,
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Ensure accurate ranges for filtering
    return await Food.db.find(
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
    double protein,
    double fat,
    double carbs,
    double walkCal,
    DateTime date,
  ) async {
    var utcDate = date.toUtc();
    var startOfDay = DateTime.utc(utcDate.year, utcDate.month, utcDate.day);

    var log = await DailyLog.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          t.date.equals(startOfDay),
    );

    if (log == null) {
      log = DailyLog(
        userId: userId,
        date: startOfDay,
        foodCal: foodCal,
        protein: protein,
        fat: fat,
        carbs: carbs,
        walkCal: walkCal,
        netCal: foodCal - walkCal,
        createdAt: DateTime.now(),
      );
      await DailyLog.db.insertRow(session, log);
    } else {
      log.foodCal += foodCal;
      if (log.foodCal < 0) log.foodCal = 0;
      
      log.protein = (log.protein ?? 0) + protein;
      if (log.protein! < 0) log.protein = 0;
      
      log.fat = (log.fat ?? 0) + fat;
      if (log.fat! < 0) log.fat = 0;
      
      log.carbs = (log.carbs ?? 0) + carbs;
      if (log.carbs! < 0) log.carbs = 0;
      
      log.walkCal += walkCal;
      if (log.walkCal < 0) log.walkCal = 0;
      
      log.netCal = log.foodCal - log.walkCal;
      await DailyLog.db.updateRow(session, log);
    }
  }

  Future<void> deleteFood(Session session, int foodId, int userId) async {
    final food = await Food.db.findById(session, foodId);
    if (food == null || food.userId != userId) {
      throw Exception('Food log not found or access denied');
    }

    // Delete record
    await Food.db.deleteRow(session, food);

    // Recalculate Daily Log (decrease values)
    await _updateDailyLog(
      session,
      userId,
      -food.calories,
      -(food.protein ?? 0),
      -(food.fat ?? 0),
      -(food.carbs ?? 0),
      0,
      food.createdAt,
    );
  }
}
