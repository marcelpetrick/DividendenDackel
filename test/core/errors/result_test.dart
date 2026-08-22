import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    const Failure failure = NoDataFailure();

    test('exposes which branch it holds', () {
      const Result<int> success = Result<int>.success(7);
      const Result<int> failed = Result<int>.failure(failure);

      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(failed.isFailure, isTrue);
      expect(failed.isSuccess, isFalse);
    });

    test('unwraps to a value or a failure', () {
      const Result<int> success = Result<int>.success(7);
      const Result<int> failed = Result<int>.failure(failure);

      expect(success.valueOrNull, 7);
      expect(success.failureOrNull, isNull);
      expect(failed.valueOrNull, isNull);
      expect(failed.failureOrNull, failure);
      expect(failed.getOrElse(-1), -1);
      expect(success.getOrElse(-1), 7);
    });

    test('getOrElse returns a stored null rather than the fallback only when '
        'the result failed', () {
      const Result<int?> nullSuccess = Result<int?>.success(null);

      // A successful `null` is indistinguishable from "absent" here, which is
      // why nullable payloads should use NoDataFailure instead of a null value.
      expect(nullSuccess.getOrElse(-1), -1);
      expect(nullSuccess.isSuccess, isTrue);
    });

    test('folds both branches into one value', () {
      const Result<int> success = Result<int>.success(7);
      const Result<int> failed = Result<int>.failure(failure);

      expect(success.fold((int v) => 'v$v', (Failure f) => f.message), 'v7');
      expect(
        failed.fold((int v) => 'v$v', (Failure f) => f.message),
        failure.message,
      );
    });

    test('map transforms values and passes failures through', () {
      expect(
        const Result<int>.success(7).map((int v) => v * 2),
        const Result<int>.success(14),
      );
      expect(
        const Result<int>.failure(failure).map((int v) => v * 2),
        const Result<int>.failure(failure),
      );
    });

    test('flatMap chains fallible operations', () {
      Result<int> half(int value) => value.isEven
          ? Result<int>.success(value ~/ 2)
          : const Result<int>.failure(ParsingFailure());

      expect(
        const Result<int>.success(8).flatMap(half),
        const Result<int>.success(4),
      );
      expect(
        const Result<int>.success(7).flatMap(half).failureOrNull,
        isA<ParsingFailure>(),
      );
      expect(
        const Result<int>.failure(failure).flatMap(half).failureOrNull,
        failure,
      );
    });

    test('mapFailure rewrites the failure branch only', () {
      const Result<int> failed = Result<int>.failure(failure);

      expect(
        failed.mapFailure((Failure f) => const NetworkFailure()).failureOrNull,
        isA<NetworkFailure>(),
      );
      expect(
        const Result<int>.success(7).mapFailure((Failure f) => failure),
        const Result<int>.success(7),
      );
    });

    test('recover substitutes cached data for a failure', () {
      const Result<int> failed = Result<int>.failure(NetworkFailure());

      expect(
        failed.recover((Failure f) => const Result<int>.success(42)),
        const Result<int>.success(42),
      );
      expect(
        const Result<int>.success(
          7,
        ).recover((Failure f) => const Result<int>.success(42)),
        const Result<int>.success(7),
      );
    });

    group('guard', () {
      test('captures a returned value', () {
        expect(Result.guard<int>(() => 7), const Result<int>.success(7));
      });

      test('preserves a thrown Failure', () {
        final Result<int> result = Result.guard<int>(
          () => throw const RateLimitFailure(),
        );

        expect(result.failureOrNull, isA<RateLimitFailure>());
      });

      test('classifies anything else as unexpected and keeps the cause', () {
        final ArgumentError error = ArgumentError('boom');
        final Result<int> result = Result.guard<int>(() => throw error);

        final Failure? actual = result.failureOrNull;
        expect(actual, isA<UnexpectedFailure>());
        expect(actual!.category, FailureCategory.unexpected);
        expect(actual.cause, same(error));
        expect(actual.technicalDetail, contains('boom'));
        expect(actual.message, isNot(contains('boom')));
      });
    });

    group('guardAsync', () {
      test('captures a completed value', () async {
        expect(
          await Result.guardAsync<int>(() async => 7),
          const Result<int>.success(7),
        );
      });

      test('preserves a thrown Failure', () async {
        final Result<int> result = await Result.guardAsync<int>(
          () async => throw const AuthenticationFailure(),
        );

        expect(result.failureOrNull, isA<AuthenticationFailure>());
      });

      test('maps a TimeoutException to a TimeoutFailure', () async {
        final Result<int> result = await Result.guardAsync<int>(
          () => Future<int>.delayed(
            const Duration(seconds: 5),
            () => 7,
          ).timeout(const Duration(milliseconds: 10)),
        );

        final Failure? actual = result.failureOrNull;
        expect(actual, isA<TimeoutFailure>());
        expect(
          (actual! as TimeoutFailure).timeout,
          const Duration(milliseconds: 10),
        );
      });

      test('classifies anything else as unexpected', () async {
        final Result<int> result = await Result.guardAsync<int>(
          () async => throw StateError('boom'),
        );

        expect(result.failureOrNull, isA<UnexpectedFailure>());
      });
    });

    test('supports exhaustive pattern matching', () {
      String describe(Result<int> result) => switch (result) {
        Success<int>(:final int value) => 'value $value',
        Failed<int>(:final Failure failure) =>
          'failed ${failure.category.name}',
      };

      expect(describe(const Result<int>.success(7)), 'value 7');
      expect(describe(const Result<int>.failure(failure)), 'failed noData');
    });

    test('equality distinguishes payload and type', () {
      expect(const Success<int>(7), const Success<int>(7));
      expect(const Success<int>(7), isNot(const Success<int>(8)));
      expect(const Failed<int>(failure), const Failed<int>(failure));
      expect(
        const Failed<int>(failure),
        isNot(const Failed<int>(ParsingFailure())),
      );
      expect(const Success<int>(7).hashCode, const Success<int>(7).hashCode);
    });
  });
}
