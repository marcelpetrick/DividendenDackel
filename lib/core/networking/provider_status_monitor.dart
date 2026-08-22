import 'dart:async';

import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';

/// Persists coordinator outcomes for runtime and offline diagnostics.
final class ProviderStatusMonitor {
  /// Starts monitoring [coordinator] immediately.
  ProviderStatusMonitor({
    required RequestCoordinator coordinator,
    required this.repository,
  }) : _subscription = coordinator.statuses.listen(null) {
    _subscription.onData(_record);
  }

  /// Telemetry destination.
  final ProviderStatusRepository repository;
  late final StreamSubscription<RequestStatus> _subscription;
  Future<void> _pendingWrite = Future<void>.value();

  void _record(RequestStatus status) {
    _pendingWrite = _pendingWrite.then((_) async {
      switch (status.lifecycle) {
        case RequestLifecycle.queued:
        case RequestLifecycle.cancelled:
          return;
        case RequestLifecycle.running:
          await repository.recordRequestStarted(
            status.provider,
            status.startedAt ?? status.queuedAt,
          );
        case RequestLifecycle.succeeded:
          await repository.recordSuccess(
            status.provider,
            status.finishedAt ?? status.startedAt ?? status.queuedAt,
          );
        case RequestLifecycle.retrying:
        case RequestLifecycle.failed:
          await repository.recordFailure(
            status.provider,
            status.finishedAt ?? status.startedAt ?? status.queuedAt,
            _failureFrom(status),
          );
      }
    });
  }

  static Failure _failureFrom(RequestStatus status) {
    final String message = status.failureMessage ?? 'The request failed.';
    return switch (status.failureCategory ?? FailureCategory.unexpected) {
      FailureCategory.network => NetworkFailure(message: message),
      FailureCategory.timeout => TimeoutFailure(message: message),
      FailureCategory.rateLimited => RateLimitFailure(
        message: message,
        retryAt: status.rateLimitResetAt,
      ),
      FailureCategory.authentication => AuthenticationFailure(message: message),
      FailureCategory.providerUnavailable => ProviderUnavailableFailure(
        message: message,
      ),
      FailureCategory.parsing => ParsingFailure(message: message),
      FailureCategory.invalidInstrument => InvalidInstrumentFailure(
        message: message,
      ),
      FailureCategory.noData => NoDataFailure(message: message),
      FailureCategory.stale => StaleDataFailure(message: message),
      FailureCategory.cancelled => CancelledFailure(message: message),
      FailureCategory.unexpected => UnexpectedFailure(message: message),
    };
  }

  /// Stops observing after all already queued telemetry writes finish.
  Future<void> dispose() async {
    await _subscription.cancel();
    await _pendingWrite;
  }
}
