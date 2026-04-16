import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class WaterEndpoint extends Endpoint {
  /// Foydalanuvchining bugungi suv iste'molini oshirish
  Future<DailyLog> addWater(
    Session session,
    int userId,
    int amountMl,
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
        foodCal: 0,
        protein: 0,
        fat: 0,
        carbs: 0,
        waterMl: amountMl,
        walkCal: 0,
        netCal: 0,
        createdAt: DateTime.now(),
      );
      return await DailyLog.db.insertRow(session, log);
    } else {
      log.waterMl = (log.waterMl ?? 0) + amountMl;
      return await DailyLog.db.updateRow(session, log);
    }
  }

  /// Foydalanuvchi stakanining hajmini yangilash
  Future<User> updateWaterGlassSize(Session session, int userId, int glassSize) async {
    final user = await User.db.findById(session, userId);
    if (user == null) {
      throw Exception('Foydalanuvchi topilmadi');
    }
    user.waterGlassSize = glassSize;
    user.updatedAt = DateTime.now();
    return await User.db.updateRow(session, user);
  }
}
