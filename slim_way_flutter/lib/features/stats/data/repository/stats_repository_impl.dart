import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/stats/domain/repository/stats_repository.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/utils/safe_call.dart';

class StatsRepositoryImpl implements StatsRepository {
  final Client client;

  StatsRepositoryImpl({required this.client});

  @override
  Future<Safed<BaseException, List<DailyLog>>> getWeeklyStats(int userId) =>
      safeCall(() => client.stats.getHistory(userId));

  @override
  Future<Safed<BaseException, List<WeeklyWeight>>> getWeightHistory(int userId) =>
      safeCall(() => client.weeklyWeight.getWeightHistory(userId));
}
