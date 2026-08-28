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
/// How often the configured quote source can actually produce a new price.
enum QuoteCadence {
  /// A new price may arrive at any time, so a short lifetime is right.
  intraday,

  /// One price per trading session, so a close holds until the next one.
  endOfDay,
}

final class CachePolicy {
  /// Creates a policy, replacing selected [overrides].
  CachePolicy({
    Map<CacheDataType, Duration> overrides = const {},
    this.quoteCadence = QuoteCadence.endOfDay,
  }) : _lifetimes = UnmodifiableMapView<CacheDataType, Duration>(
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
        CacheDataType.companyEvents: Duration(hours: 8),
        CacheDataType.fundamentals: Duration(hours: 18),
        CacheDataType.news: Duration(minutes: 10),
        CacheDataType.quotes: Duration(minutes: 5),
        CacheDataType.secFilings: Duration(minutes: 10),
        CacheDataType.fxRates: Duration(hours: 12),
      };

  /// Cadence of the configured quote source.
  ///
  /// Defaults to [QuoteCadence.endOfDay] because the only quote adapter is
  /// Alpha Vantage's free tier, which publishes one closing price per session.
  /// Switch this when a source that ticks intraday is configured.
  final QuoteCadence quoteCadence;

  final Map<CacheDataType, Duration> _lifetimes;

  /// Read-only configured lifetimes.
  Map<CacheDataType, Duration> get lifetimes => _lifetimes;

  /// Lifetime for [dataType].
  Duration lifetimeFor(CacheDataType dataType) => _lifetimes[dataType]!;

  /// Computes the expiry for a payload fetched at [fetchedAt].
  ///
  /// End-of-day quotes expire at the next session close rather than after a
  /// fixed interval. A close cannot change until the next one, so a short
  /// lifetime would spend a request on an identical answer -- and with Alpha
  /// Vantage's 25 requests per day, the five-minute default emptied a user's
  /// quota within one screen's worth of refreshes.
  DateTime expiresAt(CacheDataType dataType, DateTime fetchedAt) =>
      dataType == CacheDataType.quotes && quoteCadence == QuoteCadence.endOfDay
      ? nextSessionClose(fetchedAt)
      : fetchedAt.add(lifetimeFor(dataType));

  /// The first session close strictly after [moment].
  ///
  /// Weekends carry Friday's close forward, which is where a fixed lifetime
  /// wastes the most: a Saturday refresh cannot produce a new price.
  ///
  /// The close is held at 16:30 UTC, Xetra's 17:30 in winter. Through summer
  /// time that is an hour after the real close, which costs at most one extra
  /// hour of staleness and never an extra request. Modelling the exchange
  /// calendar properly would need holiday data the app does not carry, and
  /// holidays only ever delay a new price, so a quote simply stays fresh.
  static DateTime nextSessionClose(DateTime moment) {
    final DateTime utc = moment.toUtc();
    DateTime candidate = DateTime.utc(
      utc.year,
      utc.month,
      utc.day,
    ).add(_sessionClose);
    while (!candidate.isAfter(utc) || _isWeekend(candidate)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  static const Duration _sessionClose = Duration(hours: 16, minutes: 30);

  static bool _isWeekend(DateTime value) =>
      value.weekday == DateTime.saturday || value.weekday == DateTime.sunday;

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
