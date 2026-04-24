import 'dart:typed_data';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';

abstract class FoodRepository {
  Future<Safed<BaseException, AiAnalysisResult>> analyzeFoodImage(Uint8List imageBytes, {String? prompt});
  Future<Safed<BaseException, void>> addFood(Food food);
  Future<Safed<BaseException, List<Food>>> getFoodHistory(int userId, DateTime startDate, DateTime endDate);
}
