import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';

abstract class ActivityRepository {
  Future<Safed<BaseException, List<Walk>>> getWalkHistory(int userId, DateTime start, DateTime end);
  Future<Safed<BaseException, void>> syncSteps(int userId, int steps, DateTime date);
  Future<Safed<BaseException, void>> addWalk(Walk walk);
}
