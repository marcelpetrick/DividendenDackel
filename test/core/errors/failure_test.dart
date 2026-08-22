import 'package:dividend_tracker/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('every category is represented by exactly one failure type', () {
      const List<Failure> failures = <Failure>[
        NetworkFailure(),
        TimeoutFailure(),
        RateLimitFailure(),
        AuthenticationFailure(),
        ProviderUnavailableFailure(),
        ParsingFailure(),
        InvalidInstrumentFailure(),
        NoDataFailure(),
        StaleDataFailure(),
        UnexpectedFailure(),
      ];

      expect(
        failures.map((Failure failure) => failure.category).toSet(),
        FailureCategory.values.toSet(),
      );
      expect(failures.length, FailureCategory.values.length);
    });

    test('carries a non-empty user-facing message by default', () {
      for (final Failure failure in <Failure>[
        const NetworkFailure(),
        const TimeoutFailure(),
        const RateLimitFailure(),
        const AuthenticationFailure(),
        const ProviderUnavailableFailure(),
        const ParsingFailure(),
        const InvalidInstrumentFailure(),
        const NoDataFailure(),
        const StaleDataFailure(),
        const UnexpectedFailure(),
      ]) {
        expect(failure.message, isNotEmpty, reason: '${failure.runtimeType}');
      }
    });

    test('classifies which failures are worth retrying', () {
      expect(const NetworkFailure().isRetryable, isTrue);
      expect(const TimeoutFailure().isRetryable, isTrue);
      expect(const RateLimitFailure().isRetryable, isTrue);
      expect(const ProviderUnavailableFailure().isRetryable, isTrue);
      expect(const StaleDataFailure().isRetryable, isTrue);

      expect(const AuthenticationFailure().isRetryable, isFalse);
      expect(const ParsingFailure().isRetryable, isFalse);
      expect(const InvalidInstrumentFailure().isRetryable, isFalse);
      expect(const NoDataFailure().isRetryable, isFalse);
      expect(const UnexpectedFailure().isRetryable, isFalse);
    });

    test('keeps diagnostics out of the user-facing message', () {
      const Failure failure = ParsingFailure(
        technicalDetail: 'Unexpected token at offset 42',
      );

      expect(failure.message, isNot(contains('offset')));
      expect(failure.technicalDetail, 'Unexpected token at offset 42');
      expect(failure.toString(), contains('offset 42'));
    });

    test('is an Exception so it can cross a throwing boundary', () {
      expect(const NoDataFailure(), isA<Exception>());
      expect(() => throw const NoDataFailure(), throwsA(isA<NoDataFailure>()));
    });

    group('equality', () {
      test('compares by type, message and diagnostics', () {
        expect(const NetworkFailure(), const NetworkFailure());
        expect(
          const NetworkFailure().hashCode,
          const NetworkFailure().hashCode,
        );
        expect(
          const NetworkFailure(message: 'Offline.'),
          isNot(const NetworkFailure()),
        );
      });

      test('different failure types are never equal', () {
        expect(
          const NoDataFailure(message: 'same'),
          isNot(const ParsingFailure(message: 'same')),
        );
      });

      test('takes subtype-specific fields into account', () {
        final DateTime retryAt = DateTime.utc(2026, 8, 22, 18, 4);

        expect(
          RateLimitFailure(retryAt: retryAt),
          RateLimitFailure(retryAt: retryAt),
        );
        expect(
          RateLimitFailure(retryAt: retryAt),
          isNot(const RateLimitFailure()),
        );
        expect(
          const ProviderUnavailableFailure(statusCode: 503),
          isNot(const ProviderUnavailableFailure(statusCode: 500)),
        );
        expect(
          const InvalidInstrumentFailure(symbol: 'AAPL'),
          isNot(const InvalidInstrumentFailure(symbol: 'AAPL.US')),
        );
      });
    });

    test(
      'rate limit failure can report when the provider is available again',
      () {
        final DateTime retryAt = DateTime.utc(2026, 8, 22, 18, 4);

        expect(RateLimitFailure(retryAt: retryAt).retryAt, retryAt);
        expect(const RateLimitFailure().retryAt, isNull);
      },
    );

    test('stale data failure can report the age of the cached payload', () {
      final DateTime updatedAt = DateTime.utc(2026, 8, 22, 17, 22);

      expect(
        StaleDataFailure(lastUpdatedAt: updatedAt).lastUpdatedAt,
        updatedAt,
      );
    });
  });
}
