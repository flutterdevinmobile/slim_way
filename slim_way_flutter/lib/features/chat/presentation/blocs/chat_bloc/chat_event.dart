part of 'chat_bloc.dart';


abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatMessageSent extends ChatEvent {
  final String text;
  final DailyLog? dailyLog;
  final String languageCode;
  const ChatMessageSent(this.text, {this.dailyLog, this.languageCode = 'en'});
  @override
  List<Object?> get props => [text, dailyLog, languageCode];
}


class ChatResetRequested extends ChatEvent {}
