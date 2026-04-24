part of 'stats_bloc.dart';

sealed class StatsState extends Equatable {
  const StatsState();

  T when<T>({
    required T Function() initial,
    required T Function() prepare,
    required T Function(List<DailyLog> weeklyStats, List<WeeklyWeight> weightHistory) success,
    required T Function(BaseException error) failure,
  }) {
    return switch (this) {
      StatsInitial() => initial(),
      StatsPrepare() => prepare(),
      StatsSuccess(:final weeklyStats, :final weightHistory) => success(weeklyStats, weightHistory),
      StatsFailure(:final error) => failure(error),
    };
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? prepare,
    T Function(List<DailyLog> weeklyStats, List<WeeklyWeight> weightHistory)? success,
    T Function(BaseException error)? failure,
    required T Function() orElse,
  }) {
    return when(
      initial: initial ?? orElse,
      prepare: prepare ?? orElse,
      success: success ?? (_, _) => orElse(),
      failure: failure ?? (_) => orElse(),
    );
  }

  @override
  List<Object?> get props => [];
}

final class StatsInitial extends StatsState {}

final class StatsPrepare extends StatsState {}

final class StatsSuccess extends StatsState {
  final List<DailyLog> weeklyStats;
  final List<WeeklyWeight> weightHistory;
  const StatsSuccess({required this.weeklyStats, required this.weightHistory});
  @override
  List<Object?> get props => [weeklyStats, weightHistory];
}

final class StatsFailure extends StatsState {
  final BaseException error;
  const StatsFailure(this.error);
  @override
  List<Object?> get props => [error];
}
