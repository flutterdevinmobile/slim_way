import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class StatsEndpoint extends Endpoint {
  Future<DailyLog?> getDailySummary(
    Session session,
    int userId,
    DateTime date,
  ) async {
    var utcDate = date.toUtc();
    var startOfDay = DateTime.utc(utcDate.year, utcDate.month, utcDate.day);

    return await DailyLog.db.findFirstRow(
      session,
      where: (t) =>
          t.userId.equals(userId) &
          t.date.equals(startOfDay),
    );
  }

  Future<List<DailyLog>> getHistory(Session session, int userId) async {
    return await DailyLog.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.date,
    );
  }
}
