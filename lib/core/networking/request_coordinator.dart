import 'dart:async';

import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/utils/clock.dart';

/// Relative scheduling importance (Vision.md §40).
enum RequestPriority {
  /// Visible, time-sensitive portfolio information.
  high,

  /// Quotes and research needed after the primary screen is useful.
  medium,

  /// Historical or currently invisible data.
  low,
}

/// Lifecycle state exposed to the Data Status screen.
enum RequestLifecycle {
  /// Waiting for concurrency or rate-limit capacity.
  queued,

  /// A provider action is active.
  running,

  /// A retry is waiting for exponential backoff.
  retrying,

  /// Completed with a value.
  succeeded,

  /// Completed with a typed failure.
  failed,

  /// No subscriber still needs the operation.
  cancelled,
}

/// Per-provider execution constraints.
final class ProviderRequestPolicy {
  /// Creates provider limits.
  ProviderRequestPolicy({
    this.maxConcurrent = 2,
    this.minimumSpacing = Duration.zero,
    this.timeout = const Duration(seconds: 15),
    this.maxAttempts = 3,
    this.initialBackoff = const Duration(milliseconds: 250),
    this.maxBackoff = const Duration(seconds: 8),
  }) {
    if (maxConcurrent <= 0) {
      throw ArgumentError.value(
        maxConcurrent,
        'maxConcurrent',
        'must be positive',
      );
    }
    if (minimumSpacing.isNegative) {
      throw ArgumentError.value(
        minimumSpacing,
        'minimumSpacing',
        'cannot be negative',
      );
    }
    if (timeout <= Duration.zero) {
      throw ArgumentError.value(timeout, 'timeout', 'must be positive');
    }
    if (maxAttempts <= 0) {
      throw ArgumentError.value(maxAttempts, 'maxAttempts', 'must be positive');
    }
    if (initialBackoff.isNegative) {
      throw ArgumentError.value(
        initialBackoff,
        'initialBackoff',
        'cannot be negative',
      );
    }
    if (maxBackoff < initialBackoff) {
      throw ArgumentError.value(
        maxBackoff,
        'maxBackoff',
        'must not be shorter than initialBackoff',
      );
    }
  }

  /// Simultaneous operations allowed for this provider.
  final int maxConcurrent;

  /// Minimum time between provider request starts.
  final Duration minimumSpacing;

  /// Deadline applied to each attempt.
  final Duration timeout;

  /// Total attempts, including the first.
  final int maxAttempts;

  /// Delay before the first retry.
  final Duration initialBackoff;

  /// Upper bound for exponential backoff.
  final Duration maxBackoff;
}

/// Cooperative cancellation signal passed into provider actions.
final class CancellationToken {
  final Completer<void> _cancelled = Completer<void>();

  /// Whether cancellation has been requested.
  bool get isCancelled => _cancelled.isCompleted;

  /// Completes once cancellation is requested.
  Future<void> get whenCancelled => _cancelled.future;

  /// Throws a typed failure when cancellation was requested.
  void throwIfCancelled() {
    if (isCancelled) {
      throw const CancelledFailure();
    }
  }

  void _cancel() {
    if (!_cancelled.isCompleted) {
      _cancelled.complete();
    }
  }
}

/// Provider action coordinated under limits and deadlines.
typedef CoordinatorAction<T> =
    Future<Result<T>> Function(CancellationToken cancellationToken);

/// One logical provider request.
final class CoordinatorRequest<T> {
  /// Creates a request.
  CoordinatorRequest({
    required this.key,
    required this.provider,
    required this.operation,
    required this.execute,
    this.priority = RequestPriority.medium,
  }) {
    if (key.trim().isEmpty) {
      throw ArgumentError.value(key, 'key', 'must not be empty');
    }
    if (provider.trim().isEmpty) {
      throw ArgumentError.value(provider, 'provider', 'must not be empty');
    }
    if (operation.trim().isEmpty) {
      throw ArgumentError.value(operation, 'operation', 'must not be empty');
    }
  }

  /// Deduplication identity. Equal keys share one provider action.
  final String key;

  /// Provider whose limits apply.
  final String provider;

  /// Diagnostic operation name.
  final String operation;

  /// Scheduling priority.
  final RequestPriority priority;

  /// Work to execute.
  final CoordinatorAction<T> execute;
}

/// A subscriber to a coordinated operation.
final class CoordinatedRequest<T> {
  CoordinatedRequest._(this.result, this._cancel);

  /// Typed eventual result.
  final Future<Result<T>> result;

  final void Function() _cancel;

  /// Stops this subscriber from waiting. Other deduplicated subscribers remain.
  void cancel() => _cancel();

  static CoordinatedRequest<T> _failed<T>(Failure failure) =>
      CoordinatedRequest<T>._(
        Future<Result<T>>.value(Failed<T>(failure)),
        () {},
      );
}

/// Snapshot emitted whenever an operation changes lifecycle state.
final class RequestStatus {
  /// Creates a status snapshot.
  const RequestStatus({
    required this.requestKey,
    required this.provider,
    required this.operation,
    required this.priority,
    required this.lifecycle,
    required this.queuedAt,
    required this.attempt,
    required this.subscriberCount,
    this.startedAt,
    this.finishedAt,
    this.failureCategory,
  });

  /// Logical request identity.
  final String requestKey;

  /// Selected provider.
  final String provider;

  /// Diagnostic operation name.
  final String operation;

  /// Scheduling priority.
  final RequestPriority priority;

  /// Current lifecycle state.
  final RequestLifecycle lifecycle;

  /// When the first subscriber queued the request.
  final DateTime queuedAt;

  /// When provider execution first started.
  final DateTime? startedAt;

  /// Terminal time.
  final DateTime? finishedAt;

  /// Current or final attempt number.
  final int attempt;

  /// Number of subscribers sharing the provider action.
  final int subscriberCount;

  /// Failure classification for failed operations.
  final FailureCategory? failureCategory;

  /// Elapsed time once execution has started.
  Duration? durationAt(DateTime now) {
    final DateTime? start = startedAt;
    if (start == null) {
      return null;
    }
    return (finishedAt ?? now).difference(start);
  }

  /// Returns a changed snapshot.
  RequestStatus copyWith({
    RequestLifecycle? lifecycle,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? attempt,
    int? subscriberCount,
    FailureCategory? failureCategory,
    bool clearFailure = false,
  }) => RequestStatus(
    requestKey: requestKey,
    provider: provider,
    operation: operation,
    priority: priority,
    lifecycle: lifecycle ?? this.lifecycle,
    queuedAt: queuedAt,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt ?? this.finishedAt,
    attempt: attempt ?? this.attempt,
    subscriberCount: subscriberCount ?? this.subscriberCount,
    failureCategory: clearFailure
        ? null
        : failureCategory ?? this.failureCategory,
  );
}

/// Central bounded, rate-limited and deduplicating request scheduler.
final class RequestCoordinator {
  /// Creates a coordinator.
  RequestCoordinator({
    this.globalMaxConcurrent = 6,
    Map<String, ProviderRequestPolicy> providerPolicies =
        const <String, ProviderRequestPolicy>{},
    ProviderRequestPolicy? defaultPolicy,
    this.clock = const SystemClock(),
  }) : providerPolicies = Map<String, ProviderRequestPolicy>.unmodifiable(
         providerPolicies,
       ),
       defaultPolicy = defaultPolicy ?? ProviderRequestPolicy() {
    if (globalMaxConcurrent <= 0) {
      throw ArgumentError.value(
        globalMaxConcurrent,
        'globalMaxConcurrent',
        'must be positive',
      );
    }
  }

  /// Maximum operations active across every provider.
  final int globalMaxConcurrent;

  /// Provider-specific policies keyed by provider id.
  final Map<String, ProviderRequestPolicy> providerPolicies;

  /// Policy used when a provider has no explicit entry.
  final ProviderRequestPolicy defaultPolicy;

  /// Time source used for status and rate-limit decisions.
  final Clock clock;

  final StreamController<RequestStatus> _statuses =
      StreamController<RequestStatus>.broadcast(sync: true);
  final List<_RequestJobBase> _queue = <_RequestJobBase>[];
  final Map<(String, Type), Object> _jobs = <(String, Type), Object>{};
  final Map<String, int> _runningByProvider = <String, int>{};
  final Map<String, DateTime> _lastStartedByProvider = <String, DateTime>{};
  final Map<(String, Type), RequestStatus> _active =
      <(String, Type), RequestStatus>{};

  Timer? _wakeTimer;
  DateTime? _wakeAt;
  int _runningGlobal = 0;
  int _nextSequence = 0;
  bool _pumpScheduled = false;
  bool _disposed = false;

  /// Lifecycle updates for queued and active work.
  Stream<RequestStatus> get statuses => _statuses.stream;

  /// Current queued, running and retrying operations.
  List<RequestStatus> get activeOperations =>
      List<RequestStatus>.unmodifiable(_active.values);

  /// Queues [request], sharing an existing action with the same key and type.
  CoordinatedRequest<T> submit<T>(CoordinatorRequest<T> request) {
    if (_disposed) {
      return CoordinatedRequest._failed<T>(
        const CancelledFailure(
          technicalDetail: 'RequestCoordinator is disposed',
        ),
      );
    }

    final (String, Type) identity = (request.key, T);
    final Object? existing = _jobs[identity];
    if (existing != null) {
      final _RequestJob<T> job = existing as _RequestJob<T>;
      final CoordinatedRequest<T> subscriber = job.addSubscriber();
      _emit(job, job.status.copyWith(subscriberCount: job.subscriberCount));
      return subscriber;
    }
    if (_jobs.keys.any(((String, Type) item) => item.$1 == request.key)) {
      return CoordinatedRequest._failed<T>(
        UnexpectedFailure(
          technicalDetail:
              'Request key "${request.key}" was reused with a different type',
        ),
      );
    }

    final _RequestJob<T> job = _RequestJob<T>(
      owner: this,
      request: request,
      policy: providerPolicies[request.provider] ?? defaultPolicy,
      sequence: _nextSequence++,
      queuedAt: clock.now(),
    );
    final CoordinatedRequest<T> subscriber = job.addSubscriber();
    _jobs[identity] = job;
    _queue.add(job);
    _emit(job, job.status);
    _requestPump();
    return subscriber;
  }

  void _requestPump() {
    if (_disposed || _pumpScheduled) {
      return;
    }
    _pumpScheduled = true;
    scheduleMicrotask(() {
      _pumpScheduled = false;
      _pump();
    });
  }

  void _pump() {
    if (_disposed || _queue.isEmpty) {
      return;
    }
    _queue.sort(_compareJobs);

    Duration? nextWake;
    while (_runningGlobal < globalMaxConcurrent) {
      final DateTime now = clock.now();
      int candidate = -1;
      nextWake = null;

      for (int index = 0; index < _queue.length; index++) {
        final _RequestJobBase job = _queue[index];
        final int providerRunning = _runningByProvider[job.provider] ?? 0;
        if (providerRunning >= job.policy.maxConcurrent) {
          continue;
        }
        final DateTime? lastStarted = _lastStartedByProvider[job.provider];
        if (lastStarted != null) {
          final DateTime readyAt = lastStarted.add(job.policy.minimumSpacing);
          if (readyAt.isAfter(now)) {
            final Duration wait = readyAt.difference(now);
            if (nextWake == null || wait < nextWake) {
              nextWake = wait;
            }
            continue;
          }
        }
        candidate = index;
        break;
      }

      if (candidate < 0) {
        break;
      }
      _start(_queue.removeAt(candidate));
      if (_queue.isEmpty) {
        return;
      }
    }

    if (nextWake != null) {
      _scheduleWake(nextWake);
    }
  }

  static int _compareJobs(_RequestJobBase left, _RequestJobBase right) {
    final int priority = left.priority.index.compareTo(right.priority.index);
    return priority != 0 ? priority : left.sequence.compareTo(right.sequence);
  }

  void _scheduleWake(Duration delay) {
    final DateTime wakeAt = clock.now().add(delay);
    final DateTime? existing = _wakeAt;
    if (existing != null && !wakeAt.isBefore(existing)) {
      return;
    }
    _wakeTimer?.cancel();
    _wakeAt = wakeAt;
    _wakeTimer = Timer(delay, () {
      _wakeAt = null;
      _wakeTimer = null;
      _requestPump();
    });
  }

  void _start(_RequestJobBase job) {
    final DateTime startedAt = clock.now();
    _runningGlobal++;
    _runningByProvider[job.provider] =
        (_runningByProvider[job.provider] ?? 0) + 1;
    _lastStartedByProvider[job.provider] = startedAt;
    job.startedAt ??= startedAt;
    _emit(
      job,
      job.status.copyWith(
        lifecycle: RequestLifecycle.running,
        startedAt: job.startedAt,
        attempt: job.nextAttempt,
        clearFailure: true,
      ),
    );
    unawaited(_runAttempt(job));
  }

  Future<void> _runAttempt(_RequestJobBase job) async {
    Duration? retryDelay;
    try {
      retryDelay = await job.runAttempt();
    } on Object catch (error, stackTrace) {
      job.failUnexpected(error, stackTrace);
    } finally {
      _runningGlobal--;
      final int remaining = (_runningByProvider[job.provider] ?? 1) - 1;
      if (remaining == 0) {
        _runningByProvider.remove(job.provider);
      } else {
        _runningByProvider[job.provider] = remaining;
      }
    }

    if (retryDelay != null && job.hasSubscribers && !_disposed) {
      unawaited(_requeueAfterDelay(job, retryDelay));
    } else {
      _jobs.remove(job.identity);
      _active.remove(job.identity);
    }
    _requestPump();
  }

  Future<void> _requeueAfterDelay(_RequestJobBase job, Duration delay) async {
    final bool completedDelay = delay <= Duration.zero
        ? true
        : await Future.any(<Future<bool>>[
            Future<void>.delayed(delay).then((_) => true),
            job.whenCancelled.then((_) => false),
          ]);
    if (!completedDelay || !job.hasSubscribers || _disposed) {
      _jobs.remove(job.identity);
      _active.remove(job.identity);
      return;
    }
    _queue.add(job);
    _requestPump();
  }

  void _onNoSubscribers(_RequestJobBase job) {
    job.cancelAttempt();
    if (_queue.remove(job)) {
      _jobs.remove(job.identity);
      _emitTerminalCancelled(job);
      _requestPump();
      return;
    }
    if (!job.terminalEmitted) {
      _emitTerminalCancelled(job);
    }
  }

  void _emitTerminalCancelled(_RequestJobBase job) {
    job.terminalEmitted = true;
    _emit(
      job,
      job.status.copyWith(
        lifecycle: RequestLifecycle.cancelled,
        finishedAt: clock.now(),
        failureCategory: FailureCategory.cancelled,
        subscriberCount: 0,
      ),
    );
  }

  void _emit(_RequestJobBase job, RequestStatus status) {
    job.status = status;
    final bool terminal = switch (status.lifecycle) {
      RequestLifecycle.succeeded ||
      RequestLifecycle.failed ||
      RequestLifecycle.cancelled => true,
      _ => false,
    };
    if (terminal) {
      _active.remove(job.identity);
    } else {
      _active[job.identity] = status;
    }
    if (!_statuses.isClosed) {
      _statuses.add(status);
    }
  }

  /// Cancels queued/running work and closes the status stream.
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _wakeTimer?.cancel();
    for (final Object object in _jobs.values.toList(growable: false)) {
      final _RequestJobBase job = object as _RequestJobBase;
      job.cancelAllSubscribers();
      job.cancelAttempt();
    }
    _queue.clear();
    _active.clear();
    await _statuses.close();
  }
}

abstract class _RequestJobBase {
  _RequestJobBase({
    required this.owner,
    required this.key,
    required this.resultType,
    required this.provider,
    required this.operation,
    required this.priority,
    required this.policy,
    required this.sequence,
    required DateTime queuedAt,
  }) : status = RequestStatus(
         requestKey: key,
         provider: provider,
         operation: operation,
         priority: priority,
         lifecycle: RequestLifecycle.queued,
         queuedAt: queuedAt,
         attempt: 0,
         subscriberCount: 0,
       );

  final RequestCoordinator owner;
  final String key;
  final Type resultType;
  final String provider;
  final String operation;
  final RequestPriority priority;
  final ProviderRequestPolicy policy;
  final int sequence;
  late RequestStatus status;
  DateTime? startedAt;
  bool terminalEmitted = false;

  (String, Type) get identity => (key, resultType);
  int get subscriberCount;
  bool get hasSubscribers => subscriberCount > 0;
  Future<void> get whenCancelled;
  int get nextAttempt;

  Future<Duration?> runAttempt();
  void failUnexpected(Object error, StackTrace stackTrace);
  void cancelAttempt();
  void cancelAllSubscribers();
}

final class _RequestJob<T> extends _RequestJobBase {
  _RequestJob({
    required super.owner,
    required this.request,
    required super.policy,
    required super.sequence,
    required super.queuedAt,
  }) : super(
         key: request.key,
         resultType: T,
         provider: request.provider,
         operation: request.operation,
         priority: request.priority,
       );

  final CoordinatorRequest<T> request;
  final List<_RequestSubscriber<T>> _subscribers = <_RequestSubscriber<T>>[];
  final Completer<void> _allCancelled = Completer<void>();
  CancellationToken? _attemptToken;
  int _attempts = 0;

  @override
  int get subscriberCount => _subscribers.length;

  @override
  Future<void> get whenCancelled => _allCancelled.future;

  @override
  int get nextAttempt => _attempts + 1;

  CoordinatedRequest<T> addSubscriber() {
    final _RequestSubscriber<T> subscriber = _RequestSubscriber<T>();
    _subscribers.add(subscriber);
    status = status.copyWith(subscriberCount: subscriberCount);
    return CoordinatedRequest<T>._(
      subscriber.completer.future,
      () => _cancelSubscriber(subscriber),
    );
  }

  void _cancelSubscriber(_RequestSubscriber<T> subscriber) {
    if (!_subscribers.remove(subscriber)) {
      return;
    }
    subscriber.completer.complete(Failed<T>(const CancelledFailure()));
    if (_subscribers.isEmpty) {
      if (!_allCancelled.isCompleted) {
        _allCancelled.complete();
      }
      owner._onNoSubscribers(this);
    } else {
      owner._emit(this, status.copyWith(subscriberCount: subscriberCount));
    }
  }

  @override
  void cancelAllSubscribers() {
    for (final _RequestSubscriber<T> subscriber in _subscribers.toList(
      growable: false,
    )) {
      if (!subscriber.completer.isCompleted) {
        subscriber.completer.complete(Failed<T>(const CancelledFailure()));
      }
    }
    _subscribers.clear();
    if (!_allCancelled.isCompleted) {
      _allCancelled.complete();
    }
  }

  @override
  void cancelAttempt() => _attemptToken?._cancel();

  @override
  Future<Duration?> runAttempt() async {
    if (!hasSubscribers) {
      if (!terminalEmitted) {
        owner._emitTerminalCancelled(this);
      }
      return null;
    }
    _attempts++;
    final Result<T> result = await _attempt();

    if (!hasSubscribers) {
      if (!terminalEmitted) {
        owner._emitTerminalCancelled(this);
      }
      return null;
    }

    final Failure? failure = result.failureOrNull;
    if (failure != null &&
        failure.isRetryable &&
        _attempts < policy.maxAttempts) {
      final Duration delay = _retryDelay(_attempts, failure);
      owner._emit(
        this,
        status.copyWith(
          lifecycle: RequestLifecycle.retrying,
          attempt: _attempts,
          failureCategory: failure.category,
          subscriberCount: subscriberCount,
        ),
      );
      return delay;
    }

    _complete(result);
    return null;
  }

  void _complete(Result<T> result) {
    for (final _RequestSubscriber<T> subscriber in _subscribers) {
      if (!subscriber.completer.isCompleted) {
        subscriber.completer.complete(result);
      }
    }
    _subscribers.clear();
    terminalEmitted = true;
    final Failure? failure = result.failureOrNull;
    owner._emit(
      this,
      status.copyWith(
        lifecycle: failure == null
            ? RequestLifecycle.succeeded
            : RequestLifecycle.failed,
        finishedAt: owner.clock.now(),
        failureCategory: failure?.category,
        subscriberCount: 0,
        clearFailure: failure == null,
      ),
    );
  }

  @override
  void failUnexpected(Object error, StackTrace stackTrace) {
    if (!hasSubscribers) {
      if (!terminalEmitted) {
        owner._emitTerminalCancelled(this);
      }
      return;
    }
    _complete(
      Failed<T>(
        UnexpectedFailure(technicalDetail: '$error\n$stackTrace', cause: error),
      ),
    );
  }

  Future<Result<T>> _attempt() async {
    final CancellationToken token = CancellationToken();
    _attemptToken = token;
    try {
      return await request.execute(token).timeout(policy.timeout);
    } on TimeoutException catch (error) {
      token._cancel();
      return Failed<T>(TimeoutFailure(timeout: policy.timeout, cause: error));
    } on Failure catch (failure) {
      return Failed<T>(failure);
    } on Object catch (error, stackTrace) {
      return Failed<T>(
        UnexpectedFailure(technicalDetail: '$error\n$stackTrace', cause: error),
      );
    } finally {
      _attemptToken = null;
    }
  }

  Duration _retryDelay(int failedAttempt, Failure failure) {
    final int maximumMicros = policy.maxBackoff.inMicroseconds;
    int micros = policy.initialBackoff.inMicroseconds;
    for (int retry = 1; retry < failedAttempt; retry++) {
      if (micros >= maximumMicros ~/ 2) {
        micros = maximumMicros;
        break;
      }
      micros *= 2;
    }
    Duration delay = Duration(microseconds: micros);
    if (failure case RateLimitFailure(:final DateTime? retryAt)) {
      final DateTime now = owner.clock.now();
      if (retryAt != null && retryAt.isAfter(now)) {
        final Duration providerDelay = retryAt.difference(now);
        if (providerDelay > delay) {
          delay = providerDelay;
        }
      }
    }
    return delay;
  }
}

final class _RequestSubscriber<T> {
  final Completer<Result<T>> completer = Completer<Result<T>>();
}
