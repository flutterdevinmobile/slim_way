import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/food/domain/repository/food_repository.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';

part 'food_event.dart';
part 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final FoodRepository _repository;

  FoodBloc({required FoodRepository repository})
      : _repository = repository,
        super(FoodInitial()) {
    on<FoodAnalyzeRequested>(_onAnalyze);
    on<FoodAddRequested>(_onAdd);
    on<FoodHistoryRequested>(_onFetchHistory);
    on<FoodReset>((event, emit) => emit(FoodInitial()));
  }

  Future<void> _onAnalyze(FoodAnalyzeRequested event, Emitter<FoodState> emit) async {
    emit(FoodPrepare());
    final result = await _repository.analyzeFoodImage(event.imageBytes, prompt: event.prompt);
    result.when(
      success: (analysis) => emit(FoodSuccess(const [], analysisResult: analysis)),
      failure: (error) => emit(FoodFailure(error)),
    );
  }

  Future<void> _onAdd(FoodAddRequested event, Emitter<FoodState> emit) async {
    emit(FoodPrepare());
    
    final food = event.food;
    if (event.imageBytes != null) {
      food.photoUrl = 'data:image/jpeg;base64,${base64Encode(event.imageBytes!)}';
    }

    final result = await _repository.addFood(food);
    result.when(
      success: (_) => emit(FoodAdded()),
      failure: (error) => emit(FoodFailure(error)),
    );
  }

  Future<void> _onFetchHistory(FoodHistoryRequested event, Emitter<FoodState> emit) async {
    emit(FoodPrepare());
    final result = await _repository.getFoodHistory(event.userId, event.start, event.end);
    result.when(
      success: (foods) => emit(FoodSuccess(foods)),
      failure: (error) => emit(FoodFailure(error)),
    );
  }
}
