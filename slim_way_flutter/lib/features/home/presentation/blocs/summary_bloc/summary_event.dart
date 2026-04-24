part of 'summary_bloc.dart';

abstract class SummaryEvent extends Equatable {
  const SummaryEvent();
  @override
  List<Object?> get props => [];
}

class SummaryRefreshRequested extends SummaryEvent {}

class WaterAdded extends SummaryEvent {
  final int amount;
  const WaterAdded(this.amount);
  @override
  List<Object?> get props => [amount];
}

class FoodDeleted extends SummaryEvent {
  final int foodId;
  const FoodDeleted(this.foodId);
  @override
  List<Object?> get props => [foodId];
}
