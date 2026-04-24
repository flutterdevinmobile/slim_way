part of 'activity_bloc.dart';

sealed class ActivityState extends Equatable {
  const ActivityState();

  T when<T>({
    required T Function() initial,
    required T Function() prepare,
    required T Function(List<Walk> history) success,
    required T Function(BaseException error) failure,
  }) {
    return switch (this) {
      ActivityInitial() => initial(),
      ActivityPrepare() => prepare(),
      ActivitySuccess(:final history) => success(history),
      ActivityFailure(:final error) => failure(error),
    };
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? prepare,
    T Function(List<Walk> history)? success,
    T Function(BaseException error)? failure,
    required T Function() orElse,
  }) {
    return when(
      initial: initial ?? orElse,
      prepare: prepare ?? orElse,
      success: success ?? (_) => orElse(),
      failure: failure ?? (_) => orElse(),
    );
  }

  @override
  List<Object?> get props => [];
}

final class ActivityInitial extends ActivityState {}

final class ActivityPrepare extends ActivityState {}

final class ActivitySuccess extends ActivityState {
  final List<Walk> history;
  const ActivitySuccess(this.history);
  @override
  List<Object?> get props => [history];
}

final class ActivityFailure extends ActivityState {
  final BaseException error;
  const ActivityFailure(this.error);
  @override
  List<Object?> get props => [error];
}
