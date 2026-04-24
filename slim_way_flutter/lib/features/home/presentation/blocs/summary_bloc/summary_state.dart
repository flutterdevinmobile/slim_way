part of 'summary_bloc.dart';

sealed class SummaryState extends Equatable {
  const SummaryState();

  T when<T>({
    required T Function() initial,
    required T Function() prepare,
    required T Function(DailyLog? summary, List<Food> foods) success,
    required T Function(BaseException error) failure,
  }) {
    return switch (this) {
      SummaryInitial() => initial(),
      SummaryPrepare() => prepare(),
      SummarySuccess(:final summary, :final foods) => success(summary, foods),
      SummaryFailure(:final error) => failure(error),
    };
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? prepare,
    T Function(DailyLog? summary, List<Food> foods)? success,
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

final class SummaryInitial extends SummaryState {}

final class SummaryPrepare extends SummaryState {}

final class SummarySuccess extends SummaryState {
  final DailyLog? summary;
  final List<Food> foods;
  const SummarySuccess({this.summary, required this.foods});
  @override
  List<Object?> get props => [summary, foods];
}

final class SummaryFailure extends SummaryState {
  final BaseException error;
  const SummaryFailure(this.error);
  @override
  List<Object?> get props => [error];
}
