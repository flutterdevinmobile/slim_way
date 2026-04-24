import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';

abstract class ChatRepository {
  Future<Safed<BaseException, String>> sendMessage(int userId, String message, {DailyLog? dailyLog, String? languageCode});
  Safed<BaseException, List<String>> getChatHistory(int userId);
}

