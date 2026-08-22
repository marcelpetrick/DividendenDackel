import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/logging/log_level.dart';
import 'package:dividendendackel/core/logging/log_record.dart';
import 'package:dividendendackel/core/logging/log_redactor.dart';
import 'package:dividendendackel/core/logging/log_sink.dart';
import 'package:dividendendackel/core/utils/clock.dart';
import 'package:flutter/foundation.dart';

/// Structured application logger (Vision.md §56).
///
/// Create one root logger for the app and derive scoped children with
/// [AppLogger.scoped] so every record automatically carries its component and
/// provider:
///
/// ```dart
/// final AppLogger log = rootLogger.scoped(component: 'coordinator');
/// log.info('request finished', operation: 'getDividends', provider: 'fmp');
/// ```
///
/// Structured [LogRecord.fields] are redacted before they reach a sink, so a
/// call site cannot accidentally log an API key or a position size.
final class AppLogger {
  /// Creates a logger writing to [sink].
  ///
  /// [minimumLevel] defaults to verbose in debug builds and warnings-only in
  /// release builds, as the vision requires.
  AppLogger({
    required this.sink,
    LogLevel? minimumLevel,
    this.clock = const SystemClock(),
    LogRedactor? redactor,
    this.component = 'app',
    this.provider,
    bool? captureStackTraces,
  }) : minimumLevel =
           minimumLevel ?? (kDebugMode ? LogLevel.debug : LogLevel.warning),
       _redactor = redactor ?? LogRedactor(),
       _captureStackTraces = captureStackTraces ?? kDebugMode;

  /// A logger that discards everything, for tests and for disabled logging.
  factory AppLogger.silent() =>
      AppLogger(sink: const MultiLogSink(<LogSink>[]));

  /// Where emitted records are written.
  final LogSink sink;

  /// The lowest level this logger emits.
  final LogLevel minimumLevel;

  /// Time source used for record timestamps and [timed] durations.
  final Clock clock;

  /// The component this logger tags its records with.
  final String component;

  /// The provider this logger tags its records with, if any.
  final String? provider;

  final LogRedactor _redactor;
  final bool _captureStackTraces;

  /// Derives a logger with a different [component] and/or [provider].
  ///
  /// Omitted arguments are inherited from this logger.
  AppLogger scoped({String? component, String? provider}) => AppLogger(
    sink: sink,
    minimumLevel: minimumLevel,
    clock: clock,
    redactor: _redactor,
    component: component ?? this.component,
    provider: provider ?? this.provider,
    captureStackTraces: _captureStackTraces,
  );

  /// Whether a record at [level] would be emitted.
  bool isEnabled(LogLevel level) => level >= minimumLevel;

  /// Emits a record at [level].
  void log(
    LogLevel level,
    String message, {
    String? operation,
    String? provider,
    Duration? duration,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    if (!isEnabled(level)) {
      return;
    }
    sink.write(
      LogRecord(
        timestamp: clock.now(),
        level: level,
        component: component,
        message: message,
        operation: operation,
        provider: provider ?? this.provider,
        duration: duration,
        errorCategory: error is Failure ? error.category : null,
        error: error,
        stackTrace: _captureStackTraces ? stackTrace : null,
        fields: _redactor.redact(fields),
      ),
    );
  }

  /// Emits a [LogLevel.trace] record.
  void trace(
    String message, {
    String? operation,
    String? provider,
    Duration? duration,
    Map<String, Object?> fields = const <String, Object?>{},
  }) => log(
    LogLevel.trace,
    message,
    operation: operation,
    provider: provider,
    duration: duration,
    fields: fields,
  );

  /// Emits a [LogLevel.debug] record.
  void debug(
    String message, {
    String? operation,
    String? provider,
    Duration? duration,
    Map<String, Object?> fields = const <String, Object?>{},
  }) => log(
    LogLevel.debug,
    message,
    operation: operation,
    provider: provider,
    duration: duration,
    fields: fields,
  );

  /// Emits a [LogLevel.info] record.
  void info(
    String message, {
    String? operation,
    String? provider,
    Duration? duration,
    Map<String, Object?> fields = const <String, Object?>{},
  }) => log(
    LogLevel.info,
    message,
    operation: operation,
    provider: provider,
    duration: duration,
    fields: fields,
  );

  /// Emits a [LogLevel.warning] record.
  void warning(
    String message, {
    String? operation,
    String? provider,
    Duration? duration,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const <String, Object?>{},
  }) => log(
    LogLevel.warning,
    message,
    operation: operation,
    provider: provider,
    duration: duration,
    error: error,
    stackTrace: stackTrace,
    fields: fields,
  );

  /// Emits a [LogLevel.error] record.
  void error(
    String message, {
    String? operation,
    String? provider,
    Duration? duration,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> fields = const <String, Object?>{},
  }) => log(
    LogLevel.error,
    message,
    operation: operation,
    provider: provider,
    duration: duration,
    error: error,
    stackTrace: stackTrace,
    fields: fields,
  );

  /// Runs [action], logging its duration on success and its failure otherwise.
  ///
  /// This is how the request coordinator and the repositories report the
  /// `operation` + `duration` pair the vision asks for, without every call site
  /// repeating the timing boilerplate. The original error is rethrown.
  Future<T> timed<T>(
    String operation,
    Future<T> Function() action, {
    String? provider,
    LogLevel level = LogLevel.debug,
    Map<String, Object?> fields = const <String, Object?>{},
  }) async {
    final DateTime start = clock.now();
    try {
      final T value = await action();
      log(
        level,
        'completed',
        operation: operation,
        provider: provider,
        duration: clock.now().difference(start),
        fields: fields,
      );
      return value;
    } on Object catch (thrown, stackTrace) {
      log(
        LogLevel.warning,
        'failed',
        operation: operation,
        provider: provider,
        duration: clock.now().difference(start),
        error: thrown,
        stackTrace: stackTrace,
        fields: fields,
      );
      rethrow;
    }
  }
}
