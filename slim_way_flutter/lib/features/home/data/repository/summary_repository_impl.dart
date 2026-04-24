import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/home/domain/repository/summary_repository.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/utils/safe_call.dart';
import 'package:slim_way_flutter/features/home/data/datasources/summary_local_data_source.dart';


class SummaryRepositoryImpl implements SummaryRepository {
  final Client client;
  final SummaryLocalDataSource localDataSource;

  SummaryRepositoryImpl({
    required this.client,
    required this.localDataSource,
  });

  @override
  Future<Safed<BaseException, DailyLog?>> getDailySummary(int userId, DateTime date) async {
    // 1. Try to get from local first
    final localData = localDataSource.getDailySummary(userId, date);
    
    // 2. Try to fetch from remote
    final remoteCall = await safeCall(() => client.stats.getDailySummary(userId, date));
    
    return remoteCall.when(
      success: (log) {
        localDataSource.cacheDailySummary(log);
        return Success<BaseException, DailyLog?>(log);
      },
      failure: (e) {
        if (localData != null) return Success<BaseException, DailyLog?>(localData);
        return Failure<BaseException, DailyLog?>(e);
      },
    );
  }

  @override
  Future<Safed<BaseException, List<Food>>> getFoodLogs(int userId, DateTime date) async {
    final localData = localDataSource.getFoodLogs(userId, date);

    final remoteCall = await safeCall(() => client.food.getFoodLogs(userId, date));

    return remoteCall.when(
      success: (foods) {
        localDataSource.cacheFoodLogs(foods, userId, date);
        return Success<BaseException, List<Food>>(foods);
      },
      failure: (e) {
        if (localData.isNotEmpty) return Success<BaseException, List<Food>>(localData);
        return Failure<BaseException, List<Food>>(e);
      },
    );
  }

  @override
  Future<Safed<BaseException, void>> addWater(int userId, int amount, DateTime date) async {
    final remoteCall = await safeCall(() => client.water.addWater(userId, amount, date));
    
    return remoteCall.when(
      success: (_) => const Success<BaseException, void>(null),
      failure: (e) async {
        await localDataSource.addToSyncQueue({
          'type': 'water',
          'userId': userId,
          'amount': amount,
          'date': date.toIso8601String(),
        });
        return Failure<BaseException, void>(e);
      },
    );
  }

  @override
  Future<Safed<BaseException, void>> deleteFood(int foodId, int userId) =>
      safeCall(() => client.food.deleteFood(foodId, userId));
}


