import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/logging/logging.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  late InMemoryLogSink sink;
  late FakeClock clock;
  late AppLogger logger;

  setUp(() {
    sink = InMemoryLogSink();
    clock = FakeClock(DateTime.utc(2026, 8, 22, 18, 4));
    logger = AppLogger(
      sink: sink,
      clock: clock,
      minimumLevel: LogLevel.trace,
      component: 'coordinator',
      captureStackTraces: true,
    );
  });

  tearDown(() async {
    await sink.dispose();
  });

  group('AppLogger', () {
    test('emits the structured fields the vision requires', () {
      logger.info(
        'request finished',
        operation: 'getDividends',
        provider: 'fmp',
        duration: const Duration(milliseconds: 124),
        fields: <String, Object?>{'symbol': 'ALV', 'cacheHit': false},
      );

      final LogRecord record = sink.records.single;
      expect(record.component, 'coordinator');
      expect(record.operation, 'getDividends');
      expect(record.provider, 'fmp');
      expect(record.duration, const Duration(milliseconds: 124));
      expect(record.level, LogLevel.info);
      expect(record.timestamp, DateTime.utc(2026, 8, 22, 18, 4));
      expect(record.fields['symbol'], 'ALV');
    });

    test('drops records below the minimum level', () {
      final AppLogger quiet = AppLogger(
        sink: sink,
        clock: clock,
        minimumLevel: LogLevel.warning,
      );

      quiet
        ..trace('t')
        ..debug('d')
        ..info('i')
        ..warning('w')
        ..error('e');

      expect(sink.records.map((LogRecord r) => r.level), <LogLevel>[
        LogLevel.warning,
        LogLevel.error,
      ]);
      expect(quiet.isEnabled(LogLevel.info), isFalse);
      expect(quiet.isEnabled(LogLevel.error), isTrue);
    });

    test('redacts sensitive fields before they reach the sink', () {
      logger.info(
        'holding added',
        fields: <String, Object?>{
          'symbol': 'ALV',
          'quantity': 1337,
          'apiKey': 'abc123',
        },
      );

      final LogRecord record = sink.records.single;
      expect(record.fields['symbol'], 'ALV');
      expect(record.fields['quantity'], LogRedactor.placeholder);
      expect(record.fields['apiKey'], LogRedactor.placeholder);
      expect(record.format(), isNot(contains('abc123')));
      expect(record.format(), isNot(contains('1337')));
    });

    test('derives the error category from a Failure', () {
      logger.error(
        'provider rejected the request',
        operation: 'getNews',
        error: const RateLimitFailure(),
      );

      expect(sink.records.single.errorCategory, FailureCategory.rateLimited);
    });

    test('leaves the error category unset for untyped errors', () {
      logger.error('boom', error: StateError('unexpected'));

      expect(sink.records.single.errorCategory, isNull);
      expect(sink.records.single.error, isA<StateError>());
    });

    test('scoped loggers inherit configuration and override their tags', () {
      final AppLogger scoped = logger.scoped(
        component: 'provider',
        provider: 'finnhub',
      );

      scoped.info('hello');

      final LogRecord record = sink.records.single;
      expect(record.component, 'provider');
      expect(record.provider, 'finnhub');
      expect(scoped.minimumLevel, logger.minimumLevel);
      expect(scoped.clock, same(clock));
    });

    test('scoped loggers keep the parent tags when not overridden', () {
      final AppLogger scoped = logger.scoped(provider: 'sec');

      expect(scoped.component, 'coordinator');
      expect(scoped.provider, 'sec');
    });

    test('a per-call provider overrides the logger tag', () {
      logger.scoped(provider: 'fmp').info('hello', provider: 'sec');

      expect(sink.records.single.provider, 'sec');
    });

    test('omits stack traces when capturing is disabled', () {
      final AppLogger release = AppLogger(
        sink: sink,
        clock: clock,
        minimumLevel: LogLevel.trace,
        captureStackTraces: false,
      );

      release.error('boom', error: 'e', stackTrace: StackTrace.current);

      expect(sink.records.single.stackTrace, isNull);
    });

    test('a silent logger emits nothing', () {
      expect(() => AppLogger.silent().error('boom'), returnsNormally);
    });

    group('timed', () {
      test('logs the measured duration of a successful operation', () async {
        final int value = await logger.timed<int>('getQuotes', () async {
          clock.advance(const Duration(milliseconds: 250));
          return 7;
        }, provider: 'fmp');

        expect(value, 7);
        final LogRecord record = sink.records.single;
        expect(record.operation, 'getQuotes');
        expect(record.provider, 'fmp');
        expect(record.duration, const Duration(milliseconds: 250));
        expect(record.level, LogLevel.debug);
      });

      test('logs and rethrows a failure with its category', () async {
        await expectLater(
          logger.timed<int>('getQuotes', () async {
            clock.advance(const Duration(milliseconds: 40));
            throw const ProviderUnavailableFailure();
          }),
          throwsA(isA<ProviderUnavailableFailure>()),
        );

        final LogRecord record = sink.records.single;
        expect(record.level, LogLevel.warning);
        expect(record.duration, const Duration(milliseconds: 40));
        expect(record.errorCategory, FailureCategory.providerUnavailable);
      });
    });
  });
}
