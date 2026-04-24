import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';

abstract class StatsRepository {
  Future<Safed<BaseException, List<DailyLog>>> getWeeklyStats(int userId);
  Future<Safed<BaseException, List<WeeklyWeight>>> getWeightHistory(int userId);
}
