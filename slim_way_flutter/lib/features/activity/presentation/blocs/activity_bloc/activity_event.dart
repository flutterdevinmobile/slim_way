part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
  @override
  List<Object?> get props => [];
}

class ActivityHistoryRefreshRequested extends ActivityEvent {
  final DateTime? start;
  final DateTime? end;
  const ActivityHistoryRefreshRequested({this.start, this.end});
  @override
  List<Object?> get props => [start, end];
}

class ActivityStepsSynced extends ActivityEvent {
  final int steps;
  final DateTime date;
  const ActivityStepsSynced(this.steps, this.date);
  @override
  List<Object?> get props => [steps, date];
}

class ActivityWalkAdded extends ActivityEvent {
  final Walk walk;
  const ActivityWalkAdded(this.walk);
  @override
  List<Object?> get props => [walk];
}
