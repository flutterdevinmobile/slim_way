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
