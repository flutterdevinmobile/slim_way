import 'package:equatable/equatable.dart';

abstract class BaseException extends Equatable implements Exception {
  final String message;
  final Object? origin;
  final StackTrace? stackTrace;

  const BaseException({
    required this.message,
    this.origin,
    required this.stackTrace,
  });

  String get userFriendlyMessage {
    final lowerCaseMessage = message.toLowerCase();
    
    if (lowerCaseMessage.contains('invalid verification code')) {
      return 'Tasdiqlash kodi noto\'g\'ri kiritildi.';
    }
    if (lowerCaseMessage.contains('socketexception') || lowerCaseMessage.contains('connection failed') || lowerCaseMessage.contains('host')) {
      return 'Internet bilan bog\'lanishda xatolik yuz berdi. Tarmoqni tekshiring.';
    }
    if (lowerCaseMessage.contains('invalid credentials') || lowerCaseMessage.contains('incorrect password')) {
      return 'Email yoki parol noto\'g\'ri.';
    }
    if (lowerCaseMessage.contains('user already exists') || lowerCaseMessage.contains('already registered')) {
      return 'Ushbu email bilan allaqachon ro\'yxatdan o\'tilgan.';
    }
    if (lowerCaseMessage.contains('timeout')) {
      return 'Server javob berish vaqti tugadi. Qayta urinib ko\'ring.';
    }

    return 'Kutilmagan xatolik yuz berdi. Iltimos, keyinroq urinib ko\'ring.';
  }

  @override
  List<Object?> get props => [
        'title: $message',
        'origin: $origin',
        'stackTrace: $stackTrace',
      ];
}

class AppUnknownException extends BaseException {
  const AppUnknownException({
    required super.message,
    super.origin,
    required super.stackTrace,
  });
}
