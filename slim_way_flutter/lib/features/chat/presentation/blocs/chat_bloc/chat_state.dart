part of 'chat_bloc.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  T when<T>({
    required T Function(List<ChatMessage> messages) initial,
    required T Function(List<ChatMessage> messages) prepare,
    required T Function(List<ChatMessage> messages) success,
    required T Function(List<ChatMessage> messages, BaseException error) failure,
  }) {
    return switch (this) {
      ChatInitial(:final messages) => initial(messages),
      ChatPrepare(:final messages) => prepare(messages),
      ChatSuccess(:final messages) => success(messages),
      ChatFailure(:final messages, :final error) => failure(messages, error),
    };
  }

  T maybeWhen<T>({
    T Function(List<ChatMessage> messages)? initial,
    T Function(List<ChatMessage> messages)? prepare,
    T Function(List<ChatMessage> messages)? success,
    T Function(List<ChatMessage> messages, BaseException error)? failure,
    required T Function() orElse,
  }) {
    return when(
      initial: initial ?? (_) => orElse(),
      prepare: prepare ?? (_) => orElse(),
      success: success ?? (_) => orElse(),
      failure: failure ?? (_, _) => orElse(),
    );
  }

  List<ChatMessage> get chatMessages => switch (this) {
        ChatInitial(:final messages) => messages,
        ChatPrepare(:final messages) => messages,
        ChatSuccess(:final messages) => messages,
        ChatFailure(:final messages) => messages,
      };

  @override
  List<Object?> get props => [chatMessages];
}

final class ChatInitial extends ChatState {
  final List<ChatMessage> messages;
  const ChatInitial(this.messages);
  @override
  List<Object?> get props => [messages];
}

final class ChatPrepare extends ChatState {
  final List<ChatMessage> messages;
  const ChatPrepare(this.messages);
  @override
  List<Object?> get props => [messages];
}

final class ChatSuccess extends ChatState {
  final List<ChatMessage> messages;
  const ChatSuccess(this.messages);
  @override
  List<Object?> get props => [messages];
}

final class ChatFailure extends ChatState {
  final List<ChatMessage> messages;
  final BaseException error;
  const ChatFailure(this.messages, this.error);
  @override
  List<Object?> get props => [messages, error];
}

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [text, isUser, timestamp];
}
