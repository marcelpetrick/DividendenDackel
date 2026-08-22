import 'package:dividendendackel/core/logging/logging.dart';
import 'package:flutter_test/flutter_test.dart';

LogRecord _record(String message) => LogRecord(
  timestamp: DateTime.utc(2026, 8, 22, 18, 4),
  level: LogLevel.info,
  component: 'test',
  message: message,
);

final class _ThrowingSink implements LogSink {
  @override
  void write(LogRecord record) => throw StateError('sink is broken');
}

void main() {
  group('InMemoryLogSink', () {
    test('retains records oldest first', () {
      final InMemoryLogSink sink = InMemoryLogSink()
        ..write(_record('a'))
        ..write(_record('b'));

      expect(sink.records.map((LogRecord r) => r.message), <String>['a', 'b']);
      addTearDown(sink.dispose);
    });

    test('drops the oldest record beyond its capacity', () {
      final InMemoryLogSink sink = InMemoryLogSink(capacity: 2)
        ..write(_record('a'))
        ..write(_record('b'))
        ..write(_record('c'));

      expect(sink.records.map((LogRecord r) => r.message), <String>['b', 'c']);
      addTearDown(sink.dispose);
    });

    test('exposes records as a broadcast stream', () async {
      final InMemoryLogSink sink = InMemoryLogSink();
      addTearDown(sink.dispose);

      final Future<List<String>> collected = sink.stream
          .take(2)
          .map((LogRecord r) => r.message)
          .toList();

      sink
        ..write(_record('a'))
        ..write(_record('b'));

      expect(await collected, <String>['a', 'b']);
    });

    test('clear drops retained records', () {
      final InMemoryLogSink sink = InMemoryLogSink()
        ..write(_record('a'))
        ..clear();

      expect(sink.records, isEmpty);
      addTearDown(sink.dispose);
    });

    test('writing after dispose does not throw', () async {
      final InMemoryLogSink sink = InMemoryLogSink();
      await sink.dispose();

      expect(() => sink.write(_record('a')), returnsNormally);
      expect(sink.records, hasLength(1));
    });

    test('rejects a non-positive capacity', () {
      expect(
        () => InMemoryLogSink(capacity: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('MultiLogSink', () {
    test('fans records out to every delegate', () {
      final InMemoryLogSink first = InMemoryLogSink();
      final InMemoryLogSink second = InMemoryLogSink();
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      MultiLogSink(<LogSink>[first, second]).write(_record('a'));

      expect(first.records, hasLength(1));
      expect(second.records, hasLength(1));
    });

    test('a broken sink does not prevent the others from receiving', () {
      final InMemoryLogSink healthy = InMemoryLogSink();
      addTearDown(healthy.dispose);

      final MultiLogSink sink = MultiLogSink(<LogSink>[
        _ThrowingSink(),
        healthy,
      ]);

      expect(() => sink.write(_record('a')), returnsNormally);
      expect(healthy.records, hasLength(1));
    });
  });

  group('ConsoleLogSink', () {
    test('stays silent when disabled', () {
      expect(
        () => ConsoleLogSink(enabled: false).write(_record('a')),
        returnsNormally,
      );
    });
  });
}
