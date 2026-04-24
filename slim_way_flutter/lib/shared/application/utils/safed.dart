import 'dart:async';

extension SafedFuture<F, S> on Future<Safed<F, S>> {
  Future<T> when<T>({
    required FutureOr<T> Function(S value) success,
    required FutureOr<T> Function(F value) failure,
  }) async {
    return (await this).whenAsync(
      success: success,
      failure: failure,
    );
  }

  Future<Safed<F2, S2>> map<F2, S2>({
    FutureOr<S2> Function(S value)? success,
    FutureOr<F2> Function(F value)? failure,
  }) async {
    return (await this).mapAsync(
      success: success,
      failure: failure,
    );
  }
}

sealed class Safed<F, S> {
  const Safed();

  bool get isSuccess => this is Success<F, S>;
  bool get isFailure => this is Failure<F, S>;

  T when<T>({
    required T Function(S value) success,
    required T Function(F value) failure,
  }) {
    return switch (this) {
      Success<F, S>(:final _value) => success(_value),
      Failure<F, S>(:final _value) => failure(_value),
    };
  }

  FutureOr<T> whenAsync<T>({
    required FutureOr<T> Function(S value) success,
    required FutureOr<T> Function(F value) failure,
  }) async {
    return switch (this) {
      Success<F, S>(:final _value) => await success(_value),
      Failure<F, S>(:final _value) => await failure(_value),
    };
  }

  Safed<F2, S2> map<F2, S2>({
    S2 Function(S value)? success,
    F2 Function(F value)? failure,
  }) {
    return switch (this) {
      Success<F, S>(:final _value) => Success<F2, S2>(
          success?.call(_value) ?? _value as S2,
        ),
      Failure<F, S>(:final _value) => Failure<F2, S2>(
          failure?.call(_value) ?? _value as F2,
        ),
    };
  }

  FutureOr<Safed<F2, S2>> mapAsync<F2, S2>({
    FutureOr<S2> Function(S value)? success,
    FutureOr<F2> Function(F value)? failure,
  }) async {
    return switch (this) {
      Success<F, S>(:final _value) => Success<F2, S2>(
          await success?.call(_value) ?? _value as S2,
        ),
      Failure<F, S>(:final _value) => Failure<F2, S2>(
          await failure?.call(_value) ?? _value as F2,
        ),
    };
  }
}

final class Success<F, S> extends Safed<F, S> {
  final S _value;

  const Success(this._value);

  S get value => _value;

  @override
  String toString() {
    return "Success(value: $_value)";
  }
}

final class Failure<F, S> extends Safed<F, S> {
  final F _value;

  const Failure(this._value);

  F get value => _value;

  @override
  String toString() {
    return "Failure(value: $_value)";
  }
}
