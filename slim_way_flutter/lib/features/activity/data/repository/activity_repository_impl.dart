import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/activity/domain/repository/activity_repository.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/utils/safe_call.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final Client client;

  ActivityRepositoryImpl({required this.client});

  @override
  Future<Safed<BaseException, List<Walk>>> getWalkHistory(int userId, DateTime start, DateTime end) =>
      safeCall(() => client.walk.getWalkHistory(userId, start, end));

  @override
  Future<Safed<BaseException, void>> syncSteps(int userId, int steps, DateTime date) =>
      safeCall(() => client.walk.syncSteps(userId, steps, date));

  @override
  Future<Safed<BaseException, void>> addWalk(Walk walk) =>
      safeCall(() => client.walk.addWalk(walk));
}
