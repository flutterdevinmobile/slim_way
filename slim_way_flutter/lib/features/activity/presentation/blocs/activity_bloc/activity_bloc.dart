import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/activity/domain/repository/activity_repository.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/configs/di/injection_container.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/shared/application/services/health_sync_service.dart';
import 'package:slim_way_flutter/shared/application/services/sensor_sync_service.dart';

part 'activity_event.dart';
part 'activity_state.dart';


class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final ActivityRepository _activityRepository;
  final HealthSyncService _healthSyncService;
  final SensorSyncService _sensorSyncService;
  final int _initialUserId;

  int get _userId => sl<AuthBloc>().state.whenOrNull<int>(authenticated: (user) => user.id ?? 0) ?? _initialUserId;

  ActivityBloc({
    required ActivityRepository activityRepository,
    required HealthSyncService healthSyncService,
    required SensorSyncService sensorSyncService,
    required int userId,
  })  : _activityRepository = activityRepository,
        _healthSyncService = healthSyncService,
        _sensorSyncService = sensorSyncService,
        _initialUserId = userId,
        super(ActivityInitial()) {
    on<ActivityHistoryRefreshRequested>(_onRefreshRequested);

    on<ActivityStepsSynced>(_onStepsSynced);
    on<ActivityWalkAdded>(_onWalkAdded);
  }

  Future<void> _onRefreshRequested(ActivityHistoryRefreshRequested event, Emitter<ActivityState> emit) async {
    emit(ActivityPrepare());
    
    // Auto-sync steps from Health Connect & Sensor
    final now = DateTime.now();
    final healthSteps = await _healthSyncService.getTodaySteps();
    final sensorSteps = await _sensorSyncService.getTodaySteps();
    
    // Use the maximum value from both sources for best coverage
    final totalSteps = healthSteps > sensorSteps ? healthSteps : sensorSteps;

    if (totalSteps > 0) {
      await _activityRepository.syncSteps(_userId, totalSteps, now);
    }

    final end = event.end ?? now;
    final start = event.start ?? end.subtract(const Duration(days: 7));

    final result = await _activityRepository.getWalkHistory(_userId, start, end);
    result.when(
      success: (history) => emit(ActivitySuccess(history)),
      failure: (error) => emit(ActivityFailure(error)),
    );
  }

  Future<void> _onStepsSynced(ActivityStepsSynced event, Emitter<ActivityState> emit) async {
    final result = await _activityRepository.syncSteps(_userId, event.steps, event.date);
    result.when(
      success: (_) => add(const ActivityHistoryRefreshRequested()),
      failure: (error) => emit(ActivityFailure(error)),
    );
  }

  Future<void> _onWalkAdded(ActivityWalkAdded event, Emitter<ActivityState> emit) async {
    final result = await _activityRepository.addWalk(event.walk);
    result.when(
      success: (_) => add(const ActivityHistoryRefreshRequested()),
      failure: (error) => emit(ActivityFailure(error)),
    );
  }
}
