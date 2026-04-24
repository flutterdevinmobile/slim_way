import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class LeaderboardEndpoint extends Endpoint {
  /// Top 10 users by streak count
  Future<List<User>> getTopUsers(Session session) async {
    return await User.db.find(
      session,
      orderBy: (t) => t.streakCount,
      orderDescending: true,
      limit: 10,
    );
  }

  /// Get rank of a specific user
  Future<int> getUserRank(Session session, int userId) async {
    final user = await User.db.findById(session, userId);
    if (user == null) return 0;

    // Count how many users have a higher streak
    final count = await User.db.count(
      session,
      where: (t) => t.streakCount > user.streakCount,
    );

    return count + 1;
  }
}
