import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class WeeklyWeightEndpoint extends Endpoint {
  Future<WeeklyWeight> addWeight(Session session, WeeklyWeight weight) async {
    await WeeklyWeight.db.insertRow(session, weight);

    // Also update current weight in User profile
    var user = await User.db.findById(session, weight.userId);
    if (user != null) {
      user.currentWeight = weight.weight;
      user.updatedAt = DateTime.now();
      await User.db.updateRow(session, user);
    }

    return weight;
  }

  Future<List<WeeklyWeight>> getWeightHistory(
    Session session,
    int userId,
  ) async {
    return await WeeklyWeight.db.find(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: (t) => t.weekStart,
    );
  }
}
