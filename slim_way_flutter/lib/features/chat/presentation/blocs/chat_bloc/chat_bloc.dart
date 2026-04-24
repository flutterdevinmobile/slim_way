import 'package:slim_way_client/slim_way_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:slim_way_flutter/features/chat/domain/repository/chat_repository.dart';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/configs/di/injection_container.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final int _initialUserId;

  int get _userId => sl<AuthBloc>().state.whenOrNull<int>(authenticated: (user) => user.id ?? 0) ?? _initialUserId;

  ChatBloc({
    required ChatRepository chatRepository,
    required int userId,
  })  : _chatRepository = chatRepository,
        _initialUserId = userId,
        super(const ChatInitial([])) {
    on<ChatMessageSent>(_onMessageSent);
    on<ChatResetRequested>((event, emit) => emit(const ChatInitial([])));
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    final updatedMessages = List<ChatMessage>.from(state.chatMessages)
      ..add(ChatMessage(text: event.text, isUser: true, timestamp: DateTime.now()));

    emit(ChatPrepare(updatedMessages));

    final result = await _chatRepository.sendMessage(_userId, event.text,
        dailyLog: event.dailyLog, languageCode: event.languageCode);
    result.when(
      success: (response) {
        final messagesWithResponse = List<ChatMessage>.from(updatedMessages)
          ..add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
        emit(ChatSuccess(messagesWithResponse));
      },
      failure: (error) => emit(ChatFailure(updatedMessages, error)),
    );
  }
}
