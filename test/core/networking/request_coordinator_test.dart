import 'dart:async';

import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderRequestPolicy singleAttemptPolicy({
    int maxConcurrent = 4,
    Duration minimumSpacing = Duration.zero,
    Duration timeout = const Duration(seconds: 1),
  }) => ProviderRequestPolicy(
    maxConcurrent: maxConcurrent,
    minimumSpacing: minimumSpacing,
    timeout: timeout,
    maxAttempts: 1,
    initialBackoff: Duration.zero,
    maxBackoff: Duration.zero,
  );

  group('RequestCoordinator', () {
    test('deduplicates in-flight requests and fans out one result', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: singleAttemptPolicy(),
      );
      addTearDown(coordinator.dispose);
      final Completer<Result<int>> providerResult = Completer<Result<int>>();
      int calls = 0;
      final CoordinatorRequest<int> request = CoordinatorRequest<int>(
        key: 'dividends:aapl',
        provider: 'provider-a',
        operation: 'getDividends',
        execute: (CancellationToken token) {
          calls++;
          return providerResult.future;
        },
      );

      final CoordinatedRequest<int> first = coordinator.submit(request);
      final CoordinatedRequest<int> second = coordinator.submit(request);
      providerResult.complete(const Success<int>(42));

      expect((await first.result).valueOrNull, 42);
      expect((await second.result).valueOrNull, 42);
      expect(calls, 1);
    });

    test('rejects reuse of a key with a different result type', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: singleAttemptPolicy(),
      );
      addTearDown(coordinator.dispose);
      final Completer<Result<int>> providerResult = Completer<Result<int>>();
      final CoordinatedRequest<int> first = coordinator.submit<int>(
        CoordinatorRequest<int>(
          key: 'same-key',
          provider: 'provider',
          operation: 'integer',
          execute: (_) => providerResult.future,
        ),
      );

      final Result<String> collision = await coordinator
          .submit<String>(
            CoordinatorRequest<String>(
              key: 'same-key',
              provider: 'provider',
              operation: 'string',
              execute: (_) async => const Success<String>('wrong'),
            ),
          )
          .result;
      providerResult.complete(const Success<int>(1));

      expect(collision.failureOrNull, isA<UnexpectedFailure>());
      expect((await first.result).valueOrNull, 1);
    });

    test('enforces the global concurrency limit', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        globalMaxConcurrent: 2,
        defaultPolicy: singleAttemptPolicy(maxConcurrent: 5),
      );
      addTearDown(coordinator.dispose);
      final Completer<void> release = Completer<void>();
      int running = 0;
      int maximum = 0;
      final List<CoordinatedRequest<int>> requests = <CoordinatedRequest<int>>[
        for (int index = 0; index < 5; index++)
          coordinator.submit<int>(
            CoordinatorRequest<int>(
              key: 'global-$index',
              provider: 'provider-$index',
              operation: 'load',
              execute: (_) async {
                running++;
                maximum = running > maximum ? running : maximum;
                await release.future;
                running--;
                return Success<int>(index);
              },
            ),
          ),
      ];

      await _waitUntil(() => running >= 2);
      expect(maximum, 2);
      release.complete();
      await Future.wait(requests.map((CoordinatedRequest<int> r) => r.result));
      expect(maximum, 2);
    });

    test('enforces per-provider concurrency independently', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        globalMaxConcurrent: 4,
        providerPolicies: <String, ProviderRequestPolicy>{
          'limited': singleAttemptPolicy(maxConcurrent: 1),
        },
        defaultPolicy: singleAttemptPolicy(),
      );
      addTearDown(coordinator.dispose);
      final Completer<void> release = Completer<void>();
      int running = 0;
      int maximum = 0;
      final List<CoordinatedRequest<int>> requests = <CoordinatedRequest<int>>[
        for (int index = 0; index < 3; index++)
          coordinator.submit<int>(
            CoordinatorRequest<int>(
              key: 'provider-$index',
              provider: 'limited',
              operation: 'load',
              execute: (_) async {
                running++;
                maximum = running > maximum ? running : maximum;
                await release.future;
                running--;
                return Success<int>(index);
              },
            ),
          ),
      ];

      await _waitUntil(() => running >= 1);
      release.complete();
      await Future.wait(requests.map((CoordinatedRequest<int> r) => r.result));
      expect(maximum, 1);
    });

    test('runs higher-priority queued work first with FIFO ties', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        globalMaxConcurrent: 1,
        defaultPolicy: singleAttemptPolicy(maxConcurrent: 1),
      );
      addTearDown(coordinator.dispose);
      final Completer<void> blockerStarted = Completer<void>();
      final Completer<void> releaseBlocker = Completer<void>();
      final List<String> order = <String>[];
      final CoordinatedRequest<int> blocker = coordinator.submit<int>(
        CoordinatorRequest<int>(
          key: 'blocker',
          provider: 'provider',
          operation: 'block',
          priority: RequestPriority.high,
          execute: (_) async {
            blockerStarted.complete();
            await releaseBlocker.future;
            return const Success<int>(0);
          },
        ),
      );
      await blockerStarted.future;

      final CoordinatedRequest<int> low = _recordingRequest(
        coordinator,
        key: 'low',
        priority: RequestPriority.low,
        order: order,
      );
      final CoordinatedRequest<int> highFirst = _recordingRequest(
        coordinator,
        key: 'high-first',
        priority: RequestPriority.high,
        order: order,
      );
      final CoordinatedRequest<int> highSecond = _recordingRequest(
        coordinator,
        key: 'high-second',
        priority: RequestPriority.high,
        order: order,
      );
      releaseBlocker.complete();

      await Future.wait(<Future<Result<int>>>[
        blocker.result,
        low.result,
        highFirst.result,
        highSecond.result,
      ]);
      expect(order, <String>['high-first', 'high-second', 'low']);
    });

    test('spaces starts according to the provider rate limit', () async {
      const Duration spacing = Duration(milliseconds: 35);
      final RequestCoordinator coordinator = RequestCoordinator(
        globalMaxConcurrent: 3,
        providerPolicies: <String, ProviderRequestPolicy>{
          'paced': singleAttemptPolicy(
            maxConcurrent: 3,
            minimumSpacing: spacing,
          ),
        },
      );
      addTearDown(coordinator.dispose);
      final List<DateTime> starts = <DateTime>[];
      final List<CoordinatedRequest<int>> requests = <CoordinatedRequest<int>>[
        for (int index = 0; index < 3; index++)
          coordinator.submit<int>(
            CoordinatorRequest<int>(
              key: 'paced-$index',
              provider: 'paced',
              operation: 'load',
              execute: (_) async {
                starts.add(DateTime.now());
                return Success<int>(index);
              },
            ),
          ),
      ];

      await Future.wait(requests.map((CoordinatedRequest<int> r) => r.result));

      expect(starts, hasLength(3));
      for (int index = 1; index < starts.length; index++) {
        expect(
          starts[index].difference(starts[index - 1]),
          greaterThanOrEqualTo(const Duration(milliseconds: 30)),
        );
      }
    });

    test(
      'maps a deadline to TimeoutFailure and signals cancellation',
      () async {
        final RequestCoordinator coordinator = RequestCoordinator(
          defaultPolicy: singleAttemptPolicy(
            timeout: const Duration(milliseconds: 20),
          ),
        );
        addTearDown(coordinator.dispose);
        CancellationToken? receivedToken;

        final Result<int> result = await coordinator
            .submit<int>(
              CoordinatorRequest<int>(
                key: 'timeout',
                provider: 'slow',
                operation: 'load',
                execute: (CancellationToken token) {
                  receivedToken = token;
                  return Completer<Result<int>>().future;
                },
              ),
            )
            .result;

        expect(result.failureOrNull, isA<TimeoutFailure>());
        expect(receivedToken?.isCancelled, isTrue);
      },
    );

    test('retries retryable failures with exponential backoff', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: ProviderRequestPolicy(
          maxConcurrent: 1,
          timeout: const Duration(seconds: 1),
          maxAttempts: 3,
          initialBackoff: const Duration(milliseconds: 15),
          maxBackoff: const Duration(milliseconds: 50),
        ),
      );
      addTearDown(coordinator.dispose);
      int attempts = 0;
      final List<RequestLifecycle> lifecycles = <RequestLifecycle>[];
      final StreamSubscription<RequestStatus> subscription = coordinator
          .statuses
          .listen((RequestStatus status) => lifecycles.add(status.lifecycle));
      addTearDown(subscription.cancel);
      final List<DateTime> attemptTimes = <DateTime>[];

      final Result<int> result = await coordinator
          .submit<int>(
            CoordinatorRequest<int>(
              key: 'retry',
              provider: 'flaky',
              operation: 'load',
              execute: (_) async {
                attempts++;
                attemptTimes.add(DateTime.now());
                return attempts < 3
                    ? const Failed<int>(NetworkFailure())
                    : const Success<int>(7);
              },
            ),
          )
          .result;

      expect(result.valueOrNull, 7);
      expect(attempts, 3);
      expect(
        attemptTimes[1].difference(attemptTimes[0]),
        greaterThanOrEqualTo(const Duration(milliseconds: 10)),
      );
      expect(
        attemptTimes[2].difference(attemptTimes[1]),
        greaterThanOrEqualTo(const Duration(milliseconds: 25)),
      );
      expect(
        lifecycles.where(
          (RequestLifecycle state) => state == RequestLifecycle.retrying,
        ),
        hasLength(2),
      );
    });

    test('does not retry a non-retryable failure', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: ProviderRequestPolicy(
          maxAttempts: 3,
          initialBackoff: Duration.zero,
          maxBackoff: Duration.zero,
        ),
      );
      addTearDown(coordinator.dispose);
      int attempts = 0;

      final Result<int> result = await coordinator
          .submit<int>(
            CoordinatorRequest<int>(
              key: 'bad-payload',
              provider: 'provider',
              operation: 'parse',
              execute: (_) async {
                attempts++;
                return const Failed<int>(ParsingFailure());
              },
            ),
          )
          .result;

      expect(result.failureOrNull, isA<ParsingFailure>());
      expect(attempts, 1);
    });

    test('honours a provider rate-limit retry time', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: ProviderRequestPolicy(
          maxAttempts: 2,
          initialBackoff: const Duration(milliseconds: 1),
          maxBackoff: const Duration(milliseconds: 5),
        ),
      );
      addTearDown(coordinator.dispose);
      final List<DateTime> attempts = <DateTime>[];

      final Result<int> result = await coordinator
          .submit<int>(
            CoordinatorRequest<int>(
              key: 'provider-rate-limit',
              provider: 'provider',
              operation: 'load',
              execute: (_) async {
                attempts.add(DateTime.now());
                return attempts.length == 1
                    ? Failed<int>(
                        RateLimitFailure(
                          retryAt: DateTime.now().add(
                            const Duration(milliseconds: 35),
                          ),
                        ),
                      )
                    : const Success<int>(1);
              },
            ),
          )
          .result;

      expect(result.valueOrNull, 1);
      expect(
        attempts[1].difference(attempts[0]),
        greaterThanOrEqualTo(const Duration(milliseconds: 30)),
      );
    });

    test('cancellation interrupts retry backoff', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: ProviderRequestPolicy(
          maxAttempts: 3,
          initialBackoff: const Duration(seconds: 1),
          maxBackoff: const Duration(seconds: 2),
        ),
      );
      addTearDown(coordinator.dispose);
      final Completer<void> retrying = Completer<void>();
      int attempts = 0;
      final StreamSubscription<RequestStatus> subscription = coordinator
          .statuses
          .listen((RequestStatus status) {
            if (status.lifecycle == RequestLifecycle.retrying &&
                !retrying.isCompleted) {
              retrying.complete();
            }
          });
      addTearDown(subscription.cancel);
      final CoordinatedRequest<int> request = coordinator.submit<int>(
        CoordinatorRequest<int>(
          key: 'cancel-backoff',
          provider: 'provider',
          operation: 'load',
          execute: (_) async {
            attempts++;
            return const Failed<int>(NetworkFailure());
          },
        ),
      );
      await retrying.future;

      request.cancel();

      expect((await request.result).failureOrNull, isA<CancelledFailure>());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(attempts, 1);
    });

    test('retry backoff releases capacity for higher-priority work', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        globalMaxConcurrent: 1,
        defaultPolicy: ProviderRequestPolicy(
          maxConcurrent: 1,
          maxAttempts: 2,
          initialBackoff: const Duration(milliseconds: 40),
          maxBackoff: const Duration(milliseconds: 40),
        ),
      );
      addTearDown(coordinator.dispose);
      final Completer<void> retrying = Completer<void>();
      final List<String> order = <String>[];
      final StreamSubscription<RequestStatus> subscription = coordinator
          .statuses
          .listen((RequestStatus status) {
            if (status.requestKey == 'low-retry' &&
                status.lifecycle == RequestLifecycle.retrying &&
                !retrying.isCompleted) {
              retrying.complete();
            }
          });
      addTearDown(subscription.cancel);
      int lowAttempts = 0;
      final CoordinatedRequest<int> low = coordinator.submit<int>(
        CoordinatorRequest<int>(
          key: 'low-retry',
          provider: 'provider',
          operation: 'load',
          priority: RequestPriority.low,
          execute: (_) async {
            lowAttempts++;
            order.add('low-$lowAttempts');
            return lowAttempts == 1
                ? const Failed<int>(NetworkFailure())
                : const Success<int>(1);
          },
        ),
      );
      await retrying.future;

      final CoordinatedRequest<int> high = coordinator.submit<int>(
        CoordinatorRequest<int>(
          key: 'high-during-backoff',
          provider: 'provider',
          operation: 'load',
          priority: RequestPriority.high,
          execute: (_) async {
            order.add('high');
            return const Success<int>(2);
          },
        ),
      );

      expect((await high.result).valueOrNull, 2);
      expect((await low.result).valueOrNull, 1);
      expect(order, <String>['low-1', 'high', 'low-2']);
    });

    test('retry attempts also obey provider start spacing', () async {
      const Duration spacing = Duration(milliseconds: 35);
      final RequestCoordinator coordinator = RequestCoordinator(
        providerPolicies: <String, ProviderRequestPolicy>{
          'paced-retry': ProviderRequestPolicy(
            minimumSpacing: spacing,
            maxAttempts: 2,
            initialBackoff: Duration.zero,
            maxBackoff: Duration.zero,
          ),
        },
      );
      addTearDown(coordinator.dispose);
      final List<DateTime> starts = <DateTime>[];

      final Result<int> result = await coordinator
          .submit<int>(
            CoordinatorRequest<int>(
              key: 'paced-retry',
              provider: 'paced-retry',
              operation: 'load',
              execute: (_) async {
                starts.add(DateTime.now());
                return starts.length == 1
                    ? const Failed<int>(NetworkFailure())
                    : const Success<int>(1);
              },
            ),
          )
          .result;

      expect(result.valueOrNull, 1);
      expect(
        starts[1].difference(starts[0]),
        greaterThanOrEqualTo(const Duration(milliseconds: 30)),
      );
    });

    test('cancels queued work before its provider action starts', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        globalMaxConcurrent: 1,
        defaultPolicy: singleAttemptPolicy(maxConcurrent: 1),
      );
      addTearDown(coordinator.dispose);
      final Completer<void> blockerStarted = Completer<void>();
      final Completer<void> release = Completer<void>();
      final CoordinatedRequest<int> blocker = coordinator.submit<int>(
        CoordinatorRequest<int>(
          key: 'cancel-blocker',
          provider: 'provider',
          operation: 'block',
          execute: (_) async {
            blockerStarted.complete();
            await release.future;
            return const Success<int>(0);
          },
        ),
      );
      await blockerStarted.future;
      bool called = false;
      final CoordinatedRequest<int> queued = coordinator.submit<int>(
        CoordinatorRequest<int>(
          key: 'cancel-queued',
          provider: 'provider',
          operation: 'load',
          execute: (_) async {
            called = true;
            return const Success<int>(1);
          },
        ),
      );

      queued.cancel();
      expect((await queued.result).failureOrNull, isA<CancelledFailure>());
      release.complete();
      await blocker.result;
      await Future<void>.delayed(Duration.zero);
      expect(called, isFalse);
    });

    test('one deduplicated subscriber can cancel independently', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: singleAttemptPolicy(),
      );
      addTearDown(coordinator.dispose);
      final Completer<Result<int>> providerResult = Completer<Result<int>>();
      int calls = 0;
      final CoordinatorRequest<int> request = CoordinatorRequest<int>(
        key: 'shared-cancel',
        provider: 'provider',
        operation: 'load',
        execute: (_) {
          calls++;
          return providerResult.future;
        },
      );
      final CoordinatedRequest<int> first = coordinator.submit(request);
      final CoordinatedRequest<int> second = coordinator.submit(request);

      first.cancel();
      providerResult.complete(const Success<int>(9));

      expect((await first.result).failureOrNull, isA<CancelledFailure>());
      expect((await second.result).valueOrNull, 9);
      expect(calls, 1);
    });

    test(
      'cancelling the final subscriber signals the running action',
      () async {
        final RequestCoordinator coordinator = RequestCoordinator(
          defaultPolicy: singleAttemptPolicy(),
        );
        addTearDown(coordinator.dispose);
        final Completer<CancellationToken> actionStarted =
            Completer<CancellationToken>();
        final CoordinatedRequest<int> request = coordinator.submit<int>(
          CoordinatorRequest<int>(
            key: 'running-cancel',
            provider: 'provider',
            operation: 'load',
            execute: (CancellationToken token) async {
              actionStarted.complete(token);
              await token.whenCancelled;
              return const Failed<int>(CancelledFailure());
            },
          ),
        );
        final CancellationToken token = await actionStarted.future;

        request.cancel();

        expect((await request.result).failureOrNull, isA<CancelledFailure>());
        expect(token.isCancelled, isTrue);
        await _waitUntil(() => coordinator.activeOperations.isEmpty);
      },
    );

    test('broadcasts queued, running and terminal status', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: singleAttemptPolicy(),
      );
      addTearDown(coordinator.dispose);
      final List<RequestStatus> statuses = <RequestStatus>[];
      final StreamSubscription<RequestStatus> subscription = coordinator
          .statuses
          .listen(statuses.add);
      addTearDown(subscription.cancel);

      final Result<int> result = await coordinator
          .submit<int>(
            CoordinatorRequest<int>(
              key: 'status',
              provider: 'provider',
              operation: 'load',
              priority: RequestPriority.high,
              execute: (_) async => const Success<int>(1),
            ),
          )
          .result;

      expect(result.valueOrNull, 1, reason: result.failureOrNull?.toString());
      expect(
        statuses.map((RequestStatus status) => status.lifecycle),
        containsAllInOrder(<RequestLifecycle>[
          RequestLifecycle.queued,
          RequestLifecycle.running,
          RequestLifecycle.succeeded,
        ]),
      );
      expect(statuses.last.attempt, 1);
      expect(statuses.last.durationAt(DateTime.now()), isNotNull);
      expect(coordinator.activeOperations, isEmpty);
    });

    test('turns thrown failures and errors into typed results', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: singleAttemptPolicy(),
      );
      addTearDown(coordinator.dispose);

      final Result<int> typed = await coordinator
          .submit<int>(
            CoordinatorRequest<int>(
              key: 'throw-failure',
              provider: 'provider',
              operation: 'load',
              execute: (_) => throw const AuthenticationFailure(),
            ),
          )
          .result;
      final Result<int> unexpected = await coordinator
          .submit<int>(
            CoordinatorRequest<int>(
              key: 'throw-error',
              provider: 'provider',
              operation: 'load',
              execute: (_) => throw StateError('boom'),
            ),
          )
          .result;

      expect(typed.failureOrNull, isA<AuthenticationFailure>());
      expect(unexpected.failureOrNull, isA<UnexpectedFailure>());
    });

    test('dispose rejects new work and cancels existing subscribers', () async {
      final RequestCoordinator coordinator = RequestCoordinator(
        defaultPolicy: singleAttemptPolicy(),
      );
      final Completer<Result<int>> providerResult = Completer<Result<int>>();
      final CoordinatedRequest<int> existing = coordinator.submit<int>(
        CoordinatorRequest<int>(
          key: 'during-dispose',
          provider: 'provider',
          operation: 'load',
          execute: (_) => providerResult.future,
        ),
      );

      await coordinator.dispose();
      final Result<int> rejected = await coordinator
          .submit<int>(
            CoordinatorRequest<int>(
              key: 'after-dispose',
              provider: 'provider',
              operation: 'load',
              execute: (_) async => const Success<int>(1),
            ),
          )
          .result;

      expect((await existing.result).failureOrNull, isA<CancelledFailure>());
      expect(rejected.failureOrNull, isA<CancelledFailure>());
    });
  });

  group('validation', () {
    test('request identity fields must not be blank', () {
      Future<Result<int>> action(CancellationToken _) async =>
          const Success<int>(1);

      expect(
        () => CoordinatorRequest<int>(
          key: '',
          provider: 'provider',
          operation: 'load',
          execute: action,
        ),
        throwsArgumentError,
      );
      expect(
        () => CoordinatorRequest<int>(
          key: 'key',
          provider: ' ',
          operation: 'load',
          execute: action,
        ),
        throwsArgumentError,
      );
      expect(
        () => CoordinatorRequest<int>(
          key: 'key',
          provider: 'provider',
          operation: '',
          execute: action,
        ),
        throwsArgumentError,
      );
    });

    test('global concurrency must be positive', () {
      expect(
        () => RequestCoordinator(globalMaxConcurrent: 0),
        throwsArgumentError,
      );
    });

    test('provider policy rejects invalid limits and durations', () {
      expect(
        () => ProviderRequestPolicy(maxConcurrent: 0),
        throwsArgumentError,
      );
      expect(
        () => ProviderRequestPolicy(
          minimumSpacing: const Duration(milliseconds: -1),
        ),
        throwsArgumentError,
      );
      expect(
        () => ProviderRequestPolicy(timeout: Duration.zero),
        throwsArgumentError,
      );
      expect(() => ProviderRequestPolicy(maxAttempts: 0), throwsArgumentError);
      expect(
        () => ProviderRequestPolicy(
          initialBackoff: const Duration(seconds: 2),
          maxBackoff: const Duration(seconds: 1),
        ),
        throwsArgumentError,
      );
    });
  });
}

CoordinatedRequest<int> _recordingRequest(
  RequestCoordinator coordinator, {
  required String key,
  required RequestPriority priority,
  required List<String> order,
}) => coordinator.submit<int>(
  CoordinatorRequest<int>(
    key: key,
    provider: 'provider',
    operation: 'load',
    priority: priority,
    execute: (_) async {
      order.add(key);
      return const Success<int>(1);
    },
  ),
);

Future<void> _waitUntil(bool Function() condition) async {
  final DateTime deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition was not reached');
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
