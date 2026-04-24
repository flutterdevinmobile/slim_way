import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';

abstract class SummaryRepository {
  Future<Safed<BaseException, DailyLog?>> getDailySummary(int userId, DateTime date);
  Future<Safed<BaseException, List<Food>>> getFoodLogs(int userId, DateTime date);
  Future<Safed<BaseException, void>> addWater(int userId, int amount, DateTime date);
  Future<Safed<BaseException, void>> deleteFood(int foodId, int userId);
}
