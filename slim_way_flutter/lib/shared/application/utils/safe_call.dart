import 'dart:async';
import 'package:slim_way_flutter/shared/application/exceptions/base_exception.dart';
import 'package:slim_way_flutter/shared/application/utils/safed.dart';

Future<Safed<BaseException, T>> safeCall<T>(Future<T> Function() call) async {
  try {
    final result = await call();
    return Success(result);
  } catch (e, stackTrace) {
    return Failure(
      AppUnknownException(
        message: e.toString(),
        origin: e,
        stackTrace: stackTrace,
      ),
    );
  }
}
