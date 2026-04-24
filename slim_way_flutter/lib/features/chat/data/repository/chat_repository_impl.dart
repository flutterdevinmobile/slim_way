import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/chat/domain/repository/chat_repository.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/utils/safe_call.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Client client;

  ChatRepositoryImpl({required this.client});

  @override
  Future<Safed<BaseException, String>> sendMessage(int userId, String message,
      {DailyLog? dailyLog, String? languageCode}) {
    final langName = languageCode == 'uz'
        ? 'Uzbek'
        : languageCode == 'ru'
            ? 'Russian'
            : 'English';
    final promptedMessage =
        "[System instruction: Respond only in $langName. User question follows] $message";
    return safeCall(
        () => client.ai.chatWithAi([], promptedMessage, dailyLog: dailyLog));
  }


  @override
  Safed<BaseException, List<String>> getChatHistory(int userId) {
    // This is currently just an in-memory list in the original implementation
    // or handled by the bloc. For now return empty list or implement local storage.
    return const Success([]);
  }
}
