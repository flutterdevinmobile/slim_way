import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/stats/domain/repository/stats_repository.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/configs/di/injection_container.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final StatsRepository _statsRepository;
  final int _initialUserId;

  int get _userId => sl<AuthBloc>().state.whenOrNull<int>(authenticated: (user) => user.id ?? 0) ?? _initialUserId;

  StatsBloc({
    required StatsRepository statsRepository,
    required int userId,
  })  : _statsRepository = statsRepository,
        _initialUserId = userId,
        super(StatsInitial()) {
    on<StatsRequested>(_onFetchRequested);
  }

  Future<void> _onFetchRequested(StatsRequested event, Emitter<StatsState> emit) async {
    emit(StatsPrepare());
    final weeklyResult = await _statsRepository.getWeeklyStats(_userId);
    final weightResult = await _statsRepository.getWeightHistory(_userId);

    await weeklyResult.whenAsync(
      success: (weeklyStats) async {
        await weightResult.whenAsync(
          success: (weightHistory) async {
            emit(StatsSuccess(weeklyStats: weeklyStats, weightHistory: weightHistory));
          },
          failure: (error) async => emit(StatsFailure(error)),
        );
      },
      failure: (error) async => emit(StatsFailure(error)),
    );
  }
}
