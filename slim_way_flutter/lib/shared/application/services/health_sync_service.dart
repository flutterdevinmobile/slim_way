import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthSyncService {
  final Health _health = Health();

  Future<bool> requestPermissions() async {
    // Request activity recognition first
    await Permission.activityRecognition.request();

    final types = [HealthDataType.STEPS];
    final permissions = [HealthDataAccess.READ];

    bool? hasPermission = await _health.hasPermissions(types, permissions: permissions);
    if (hasPermission == false) {
      return await _health.requestAuthorization(types, permissions: permissions);
    }
    return true;
  }


  Future<int> getStepsForDay(DateTime date) async {
    bool authorized = await requestPermissions();
    if (!authorized) return 0;

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final steps = await _health.getTotalStepsInInterval(startOfDay, endOfDay);
      return steps ?? 0;
    } catch (e) {
      if (kDebugMode) debugPrint('HealthSyncService: $e');
      return 0;
    }
  }

  Future<int> getTodaySteps() async {
    return getStepsForDay(DateTime.now());
  }
}
