import 'dart:async';

import 'package:dividend_tracker/core/errors/failure.dart';

/// The outcome of an operation that can fail in a typed way (Vision.md §55).
///
/// Domain and data layers return a [Result] instead of throwing, so callers are
/// forced by the type system to deal with the failure path. Use pattern
/// matching to unwrap it:
///
/// ```dart
/// switch (result) {
///   case Success(:final value):
///     render(value);
///   case Failed(:final failure):
///     showMessage(failure.message);
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Wraps a successful [value].
  const factory Result.success(T value) = Success<T>;

  /// Wraps a [failure].
  const factory Result.failure(Failure failure) = Failed<T>;

  /// Runs [action] and captures anything it throws as an [UnexpectedFailure].
  ///
  /// A [Failure] thrown directly is preserved as-is, so callers may throw a
  /// precise failure from deep inside a parser without losing its type.
  static Result<T> guard<T>(T Function() action) {
    try {
      return Success<T>(action());
    } on Failure catch (failure) {
      return Failed<T>(failure);
    } on Object catch (error, stackTrace) {
      return Failed<T>(
        UnexpectedFailure(technicalDetail: '$error\n$stackTrace', cause: error),
      );
    }
  }

  /// Asynchronous counterpart of [Result.guard].
  ///
  /// A [TimeoutException] is mapped to a [TimeoutFailure] so that deadlines set
  /// with `Future.timeout` surface as the right category.
  static Future<Result<T>> guardAsync<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } on Failure catch (failure) {
      return Failed<T>(failure);
    } on TimeoutException catch (error) {
      return Failed<T>(TimeoutFailure(timeout: error.duration, cause: error));
    } on Object catch (error, stackTrace) {
      return Failed<T>(
        UnexpectedFailure(technicalDetail: '$error\n$stackTrace', cause: error),
      );
    }
  }

  /// Whether this result holds a value.
  bool get isSuccess => this is Success<T>;

  /// Whether this result holds a [Failure].
  bool get isFailure => this is Failed<T>;

  /// The value, or `null` when this result is a failure.
  T? get valueOrNull => switch (this) {
    Success<T>(:final T value) => value,
    Failed<T>() => null,
  };

  /// The failure, or `null` when this result is a success.
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failed<T>(:final Failure failure) => failure,
  };

  /// The value, or [fallback] when this result is a failure.
  T getOrElse(T fallback) => valueOrNull ?? fallback;

  /// Collapses both branches into a single value.
  R fold<R>(
    R Function(T value) onSuccess,
    R Function(Failure failure) onFailure,
  ) => switch (this) {
    Success<T>(:final T value) => onSuccess(value),
    Failed<T>(:final Failure failure) => onFailure(failure),
  };

  /// Applies [transform] to a successful value, passing failures through.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success<T>(:final T value) => Success<R>(transform(value)),
    Failed<T>(:final Failure failure) => Failed<R>(failure),
  };

  /// Chains another fallible operation onto a successful value.
  Result<R> flatMap<R>(Result<R> Function(T value) transform) => switch (this) {
    Success<T>(:final T value) => transform(value),
    Failed<T>(:final Failure failure) => Failed<R>(failure),
  };

  /// Applies [transform] to a failure, passing successes through.
  ///
  /// Useful when a repository turns a provider-level failure into a
  /// domain-level one before it reaches the UI.
  Result<T> mapFailure(Failure Function(Failure failure) transform) =>
      switch (this) {
        Success<T>() => this,
        Failed<T>(:final Failure failure) => Failed<T>(transform(failure)),
      };

  /// Replaces a failure with a fallback result, e.g. cached data.
  Result<T> recover(Result<T> Function(Failure failure) transform) =>
      switch (this) {
        Success<T>() => this,
        Failed<T>(:final Failure failure) => transform(failure),
      };
}

/// A [Result] holding a value.
final class Success<T> extends Result<T> {
  const Success(this.value);

  /// The produced value.
  final T value;

  @override
  String toString() => 'Success($value)';

  @override
  bool operator ==(Object other) => other is Success<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Success<T>, value);
}

/// A [Result] holding a [Failure].
final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  /// The reason the operation did not produce a value.
  final Failure failure;

  @override
  String toString() => 'Failed($failure)';

  @override
  bool operator ==(Object other) =>
      other is Failed<T> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Failed<T>, failure);
}
