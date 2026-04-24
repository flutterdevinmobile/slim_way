import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/home/domain/repository/summary_repository.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/utils/notification_service.dart';
import 'package:slim_way_flutter/shared/application/configs/di/injection_container.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';

part 'summary_event.dart';
part 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final SummaryRepository _repository;
  final int _initialUserId;

  int get _userId => sl<AuthBloc>().state.whenOrNull<int>(authenticated: (user) => user.id ?? 0) ?? _initialUserId;

  SummaryBloc({required SummaryRepository repository, required int userId})
      : _repository = repository,
        _initialUserId = userId,
        super(SummaryInitial()) {
    on<SummaryRefreshRequested>(_onRefreshRequested);
    on<WaterAdded>(_onWaterAdded);
    on<FoodDeleted>(_onFoodDeleted);
  }

  Future<void> _onRefreshRequested(SummaryRefreshRequested event, Emitter<SummaryState> emit) async {
    emit(SummaryPrepare());
    final now = DateTime.now();
    final localStartOfDay = DateTime.utc(now.year, now.month, now.day);

    final summaryResult = await _repository.getDailySummary(_userId, localStartOfDay);
    final foodsResult = await _repository.getFoodLogs(_userId, localStartOfDay);

    await summaryResult.when<Future<void>>(
      success: (summary) async {
        await foodsResult.when<Future<void>>(
          success: (foods) async {
            emit(SummarySuccess(summary: summary, foods: foods));
            if (summary != null) {
              NotificationService.scheduleWaterReminders((summary.waterMl ?? 0).toInt());
            }
          },
          failure: (error) async => emit(SummaryFailure(error)),
        );
      },
      failure: (error) async => emit(SummaryFailure(error)),
    );
  }

  Future<void> _onWaterAdded(WaterAdded event, Emitter<SummaryState> emit) async {
    final now = DateTime.now();
    final result = await _repository.addWater(_userId, event.amount, DateTime.utc(now.year, now.month, now.day));
    result.when(
      success: (_) => add(SummaryRefreshRequested()),
      failure: (error) => emit(SummaryFailure(error)),
    );
  }

  Future<void> _onFoodDeleted(FoodDeleted event, Emitter<SummaryState> emit) async {
    final result = await _repository.deleteFood(event.foodId, _userId);
    result.when(
      success: (_) => add(SummaryRefreshRequested()),
      failure: (error) => emit(SummaryFailure(error)),
    );
  }
}
