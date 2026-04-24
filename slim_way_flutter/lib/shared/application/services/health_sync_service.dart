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


  Future<int> getTodaySteps() async {
    bool authorized = await requestPermissions();
    if (!authorized) return 0;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final steps = await _health.getTotalStepsInInterval(startOfDay, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint('Error fetching steps from Health Connect: $e');
      return 0;
    }
  }
}
