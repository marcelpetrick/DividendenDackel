import 'dart:collection';

import 'package:dividendendackel/domain/entities/entities.dart';

/// Freshness decision for a cache lookup.
final class CacheResolution {
  /// Creates a cache decision.
  const CacheResolution({required this.state, this.fetchedAt, this.expiresAt});

  /// Whether cached content is fresh, stale or absent.
  final CacheState state;

  /// Retrieval time, when a cached entry exists.
  final DateTime? fetchedAt;

  /// Expiry instant, when a cached entry exists.
  final DateTime? expiresAt;

  /// Whether a payload exists and can be displayed immediately.
  bool get canServeCached => state != CacheState.missing;

  /// Whether the coordinator should request an update.
  bool get shouldRevalidate => state != CacheState.fresh;
}

/// Configurable time-to-live policy for each cached data category.
///
/// Defaults sit inside the ranges in Vision.md §37. Callers may override any
/// duration for a provider or deployment without changing resolver logic.
final class CachePolicy {
  /// Creates a policy, replacing selected [overrides].
  CachePolicy({Map<CacheDataType, Duration> overrides = const {}})
    : _lifetimes = UnmodifiableMapView<CacheDataType, Duration>(
        <CacheDataType, Duration>{...defaultLifetimes, ...overrides},
      ) {
    for (final MapEntry<CacheDataType, Duration> entry in _lifetimes.entries) {
      if (entry.value <= Duration.zero) {
        throw ArgumentError.value(
          entry.value,
          entry.key.name,
          'cache lifetime must be positive',
        );
      }
    }
  }

  /// Initial lifetimes chosen from the specification's recommended ranges.
  static const Map<CacheDataType, Duration> defaultLifetimes =
      <CacheDataType, Duration>{
        CacheDataType.instrumentMetadata: Duration(days: 14),
        CacheDataType.historicalDividends: Duration(days: 14),
        CacheDataType.announcedDividends: Duration(hours: 12),
        CacheDataType.earningsCalendar: Duration(hours: 8),
        CacheDataType.fundamentals: Duration(hours: 18),
        CacheDataType.news: Duration(minutes: 10),
        CacheDataType.quotes: Duration(minutes: 5),
        CacheDataType.secFilings: Duration(minutes: 10),
      };

  final Map<CacheDataType, Duration> _lifetimes;

  /// Read-only configured lifetimes.
  Map<CacheDataType, Duration> get lifetimes => _lifetimes;

  /// Lifetime for [dataType].
  Duration lifetimeFor(CacheDataType dataType) => _lifetimes[dataType]!;

  /// Computes the expiry for a payload fetched at [fetchedAt].
  DateTime expiresAt(CacheDataType dataType, DateTime fetchedAt) =>
      fetchedAt.add(lifetimeFor(dataType));

  /// Resolves a lookup using an explicit persisted expiry when supplied.
  ///
  /// At the exact expiry instant the entry is stale. A missing [fetchedAt]
  /// always means missing, even if a stray expiry value exists.
  CacheResolution resolve({
    required CacheDataType dataType,
    required DateTime now,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  }) {
    if (fetchedAt == null) {
      return const CacheResolution(state: CacheState.missing);
    }
    final DateTime effectiveExpiry =
        expiresAt ?? this.expiresAt(dataType, fetchedAt);
    return CacheResolution(
      state: effectiveExpiry.isAfter(now) ? CacheState.fresh : CacheState.stale,
      fetchedAt: fetchedAt,
      expiresAt: effectiveExpiry,
    );
  }
}
