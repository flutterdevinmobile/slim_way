import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class SensorSyncService {
  static const _boxName = 'sensor_steps_box';
  static const _keyBaseSteps = 'base_steps_'; // append date
  
  StreamSubscription<StepCount>? _subscription;
  final _stepController = StreamController<int>.broadcast();
  
  Stream<int> get stepStream => _stepController.stream;
  
  int _lastKnownTotal = 0;

  Future<void> initialize() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _subscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
    }
  }

  void _onStepCount(StepCount event) async {
    _lastKnownTotal = event.steps;
    final today = _getTodayKey();
    
    final box = await Hive.openBox(_boxName);
    int? baseSteps = box.get(_keyBaseSteps + today);
    
    if (baseSteps == null) {
      // First time today or first time ever
      await box.put(_keyBaseSteps + today, event.steps);
      baseSteps = event.steps;
    }
    
    final todaySteps = event.steps - baseSteps;
    if (todaySteps >= 0) {
      _stepController.add(todaySteps);
    }
  }

  void _onStepCountError(Object error) {
    if (kDebugMode) debugPrint('SensorSyncService: $error');
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<int> getTodaySteps() async {
    if (_lastKnownTotal == 0) return 0;
    
    final today = _getTodayKey();
    final box = await Hive.openBox(_boxName);
    int? baseSteps = box.get(_keyBaseSteps + today);
    
    if (baseSteps == null) return 0;
    return (_lastKnownTotal - baseSteps).clamp(0, double.infinity).toInt();
  }

  void dispose() {
    _subscription?.cancel();
    _stepController.close();
  }
}
