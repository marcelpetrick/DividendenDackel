import 'package:dividend_tracker/core/errors/failure.dart';
import 'package:dividend_tracker/core/logging/log_level.dart';

/// A single structured log entry (Vision.md §56).
///
/// Records carry the fields the vision asks for — component, provider,
/// operation, duration and error category — as separate values rather than
/// baked into a message string, so the Data Status screen can filter and group
/// them.
final class LogRecord {
  /// Creates a record. Prefer emitting records through an `AppLogger`.
  const LogRecord({
    required this.timestamp,
    required this.level,
    required this.component,
    required this.message,
    this.operation,
    this.provider,
    this.duration,
    this.errorCategory,
    this.error,
    this.stackTrace,
    this.fields = const <String, Object?>{},
  });

  /// When the record was emitted.
  final DateTime timestamp;

  /// Severity of the record.
  final LogLevel level;

  /// The subsystem that emitted it, e.g. `coordinator` or `calendar`.
  final String component;

  /// Short human-readable description of what happened.
  final String message;

  /// The logical operation, e.g. `getDividends`.
  final String? operation;

  /// The data provider involved, when the record concerns one.
  final String? provider;

  /// How long the operation took, when it was measured.
  final Duration? duration;

  /// Classification of the failure, when the record describes one.
  final FailureCategory? errorCategory;

  /// The originating error, for diagnostics only.
  final Object? error;

  /// Stack trace of [error], captured in debug builds.
  final StackTrace? stackTrace;

  /// Additional structured values. Already redacted when emitted through a
  /// logger — see `LogRedactor`.
  final Map<String, Object?> fields;

  /// Renders the record as a single structured line.
  String format() {
    final StringBuffer buffer = StringBuffer()
      ..write(timestamp.toIso8601String())
      ..write('  ')
      ..write(level.label)
      ..write('  [')
      ..write(component)
      ..write(']');

    if (operation != null) {
      buffer
        ..write(' ')
        ..write(operation);
    }
    buffer
      ..write(' ')
      ..write(message);

    if (provider != null) {
      buffer
        ..write(' provider=')
        ..write(provider);
    }
    if (duration != null) {
      buffer
        ..write(' duration=')
        ..write(duration!.inMilliseconds)
        ..write('ms');
    }
    if (errorCategory != null) {
      buffer
        ..write(' errorCategory=')
        ..write(errorCategory!.name);
    }
    for (final MapEntry<String, Object?> entry in fields.entries) {
      buffer
        ..write(' ')
        ..write(entry.key)
        ..write('=')
        ..write(entry.value);
    }
    if (error != null) {
      buffer
        ..write(' error=')
        ..write(error);
    }
    return buffer.toString();
  }

  @override
  String toString() => format();
}
