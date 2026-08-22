import 'package:dividendendackel/core/errors/failure.dart';

/// Runtime health classifications shown by the Data Status screen.
enum ProviderHealth {
  /// No request outcome has been observed yet.
  unknown,

  /// The provider most recently completed a request successfully.
  healthy,

  /// The provider answered, but its latest outcome indicates a problem.
  degraded,

  /// The network was unavailable for the latest request.
  offline,

  /// The provider rejected the configured credential.
  authenticationError,

  /// The provider asked the client to wait before retrying.
  rateLimited,
}

/// Persisted, privacy-safe operational state for one data provider.
final class ProviderStatus {
  /// Creates a provider status snapshot.
  ProviderStatus({
    required this.providerId,
    this.health = ProviderHealth.unknown,
    this.lastRequestAt,
    this.rateLimitResetAt,
    this.lastErrorCategory,
    this.lastErrorMessage,
    this.cacheHits = 0,
    this.cacheMisses = 0,
  }) {
    if (providerId.trim().isEmpty) {
      throw ArgumentError.value(providerId, 'providerId', 'must not be empty');
    }
    if (cacheHits < 0 || cacheMisses < 0) {
      throw ArgumentError('Cache counters cannot be negative.');
    }
  }

  /// Stable provider identifier.
  final String providerId;

  /// Most recently observed health.
  final ProviderHealth health;

  /// Start time of the most recent live request.
  final DateTime? lastRequestAt;

  /// Time at which a reported provider limit should clear.
  final DateTime? rateLimitResetAt;

  /// Classification of the last request error.
  final FailureCategory? lastErrorCategory;

  /// Safe, user-facing text for the last request error.
  final String? lastErrorMessage;

  /// Requests satisfied without contacting the provider.
  final int cacheHits;

  /// Requests that required provider access.
  final int cacheMisses;

  /// Fraction of cache lookups that were hits, or `null` before any lookup.
  double? get cacheHitRate {
    final int total = cacheHits + cacheMisses;
    return total == 0 ? null : cacheHits / total;
  }
}
