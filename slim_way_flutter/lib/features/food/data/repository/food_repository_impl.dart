import 'dart:typed_data';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/food/domain/repository/food_repository.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/utils/safe_call.dart';

class FoodRepositoryImpl implements FoodRepository {
  final Client client;

  FoodRepositoryImpl({required this.client});

  @override
  Future<Safed<BaseException, AiAnalysisResult>> analyzeFoodImage(Uint8List imageBytes, {String? prompt}) =>
      safeCall(() {
        final byteData = ByteData.view(imageBytes.buffer);
        return client.ai.analyzeFoodImage(byteData, customPrompt: prompt);
      });

  @override
  Future<Safed<BaseException, void>> addFood(Food food) =>
      safeCall(() => client.food.addFood(food));

  @override
  Future<Safed<BaseException, List<Food>>> getFoodHistory(int userId, DateTime startDate, DateTime endDate) =>
      safeCall(() => client.food.getFoodHistory(userId, startDate, endDate));
}
