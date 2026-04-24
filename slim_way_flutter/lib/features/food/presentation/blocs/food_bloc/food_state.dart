part of 'food_bloc.dart';

abstract class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object?> get props => [];

  R when<R>({
    required R Function() initial,
    required R Function() prepare,
    required R Function(List<Food> foods, AiAnalysisResult? analysisResult) success,
    required R Function() added,
    required R Function(BaseException error) failure,
  }) {
    if (this is FoodInitial) return initial();
    if (this is FoodPrepare) return prepare();
    if (this is FoodSuccess) {
      final s = this as FoodSuccess;
      return success(s.foods, s.analysisResult);
    }
    if (this is FoodAdded) return added();
    if (this is FoodFailure) {
      final s = this as FoodFailure;
      return failure(s.error);
    }
    throw Exception('Unknown state: $this');
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function()? prepare,
    R Function(List<Food> foods, AiAnalysisResult? analysisResult)? success,
    R Function()? added,
    R Function(BaseException error)? failure,
    required R Function() orElse,
  }) {
    if (this is FoodInitial && initial != null) return initial();
    if (this is FoodPrepare && prepare != null) return prepare();
    if (this is FoodSuccess && success != null) {
      final s = this as FoodSuccess;
      return success(s.foods, s.analysisResult);
    }
    if (this is FoodAdded && added != null) return added();
    if (this is FoodFailure && failure != null) {
      final s = this as FoodFailure;
      return failure(s.error);
    }
    return orElse();
  }

  R? whenOrNull<R>({
    R Function()? initial,
    R Function()? prepare,
    R Function(List<Food> foods, AiAnalysisResult? analysisResult)? success,
    R Function()? added,
    R Function(BaseException error)? failure,
  }) => maybeWhen(
    initial: initial,
    prepare: prepare,
    success: success,
    added: added,
    failure: failure,
    orElse: () => null,
  );
}

class FoodInitial extends FoodState {}

class FoodPrepare extends FoodState {}

class FoodSuccess extends FoodState {
  final List<Food> foods;
  final AiAnalysisResult? analysisResult;
  const FoodSuccess(this.foods, {this.analysisResult});
  @override
  List<Object?> get props => [foods, analysisResult];
}

class FoodAdded extends FoodState {}

class FoodFailure extends FoodState {
  final BaseException error;
  const FoodFailure(this.error);
  @override
  List<Object?> get props => [error];
}
