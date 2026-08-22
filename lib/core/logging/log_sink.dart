import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:dividendendackel/core/logging/log_level.dart';
import 'package:dividendendackel/core/logging/log_record.dart';
import 'package:flutter/foundation.dart';

/// Destination for emitted [LogRecord]s.
abstract interface class LogSink {
  /// Writes a record. Implementations must not throw.
  void write(LogRecord record);
}

/// Writes records to the developer console.
///
/// Uses `dart:developer` so records show up with their severity in Flutter
/// tooling, and stays silent in release builds unless explicitly enabled — the
/// vision asks for controlled logging in release (Vision.md §56).
final class ConsoleLogSink implements LogSink {
  /// Creates a console sink. [enabled] defaults to debug builds only.
  ConsoleLogSink({bool? enabled}) : _enabled = enabled ?? kDebugMode;

  final bool _enabled;

  @override
  void write(LogRecord record) {
    if (!_enabled) {
      return;
    }
    developer.log(
      record.format(),
      time: record.timestamp,
      name: record.component,
      level: _developerLevel(record.level),
      error: record.error,
      stackTrace: record.stackTrace,
    );
  }

  /// Maps our levels onto the `dart:developer` severity scale, which follows
  /// the `package:logging` convention.
  static int _developerLevel(LogLevel level) => switch (level) {
    LogLevel.trace => 300,
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}

/// Keeps the most recent records in memory for the Data Status screen.
///
/// Bounded by [capacity] so a long-running session cannot grow without limit
/// (Vision.md §41, §42).
final class InMemoryLogSink implements LogSink {
  /// Creates a sink retaining at most [capacity] records.
  InMemoryLogSink({this.capacity = 500})
    : assert(capacity > 0, 'capacity must be positive');

  /// Maximum number of retained records.
  final int capacity;

  final Queue<LogRecord> _records = Queue<LogRecord>();
  final StreamController<LogRecord> _controller =
      StreamController<LogRecord>.broadcast();

  /// The retained records, oldest first.
  List<LogRecord> get records => List<LogRecord>.unmodifiable(_records);

  /// Records as they are written, for live status views.
  Stream<LogRecord> get stream => _controller.stream;

  @override
  void write(LogRecord record) {
    _records.addLast(record);
    while (_records.length > capacity) {
      _records.removeFirst();
    }
    if (!_controller.isClosed) {
      _controller.add(record);
    }
  }

  /// Drops all retained records.
  void clear() => _records.clear();

  /// Releases the broadcast stream.
  Future<void> dispose() => _controller.close();
}

/// Fans a record out to several sinks, isolating failures.
///
/// A sink that throws must not take down the operation being logged, so each
/// write is guarded.
final class MultiLogSink implements LogSink {
  /// Creates a sink writing to each of [sinks] in order.
  const MultiLogSink(this.sinks);

  /// The delegates.
  final List<LogSink> sinks;

  @override
  void write(LogRecord record) {
    for (final LogSink sink in sinks) {
      try {
        sink.write(record);
      } on Object {
        // A broken sink must never break the caller.
      }
    }
  }
}
