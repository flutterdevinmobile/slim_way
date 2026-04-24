part of 'food_bloc.dart';

abstract class FoodEvent extends Equatable {
  const FoodEvent();
  @override
  List<Object?> get props => [];
}

class FoodAnalyzeRequested extends FoodEvent {
  final Uint8List imageBytes;
  final String? prompt;
  const FoodAnalyzeRequested(this.imageBytes, {this.prompt});
  @override
  List<Object?> get props => [imageBytes, prompt];
}

class FoodAddRequested extends FoodEvent {
  final Food food;
  final Uint8List? imageBytes; // Optional image for storage
  const FoodAddRequested(this.food, {this.imageBytes});
  @override
  List<Object?> get props => [food, imageBytes];
}

class FoodHistoryRequested extends FoodEvent {
  final int userId;
  final DateTime start;
  final DateTime end;
  const FoodHistoryRequested({required this.userId, required this.start, required this.end});
  @override
  List<Object?> get props => [userId, start, end];
}

class FoodReset extends FoodEvent {}
