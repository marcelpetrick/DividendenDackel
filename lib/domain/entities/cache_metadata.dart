import 'package:dividendendackel/domain/entities/provenance.dart';

/// Cached payload categories with independently configurable lifetimes.
enum CacheDataType {
  /// Name, exchange, identifier and currency metadata.
  instrumentMetadata,

  /// Historical dividend payments.
  historicalDividends,

  /// Future dividends announced by an issuer.
  announcedDividends,

  /// Upcoming earnings dates.
  earningsCalendar,

  /// Scheduled issuer events other than dividends and earnings.
  companyEvents,

  /// Statements, ratios and other company fundamentals.
  fundamentals,

  /// News metadata and links.
  news,

  /// Latest market quotes.
  quotes,

  /// SEC filing metadata for followed instruments.
  secFilings,

  /// Daily foreign-exchange reference rates.
  fxRates,
}

/// Bookkeeping for one cached request payload.
final class CacheMetadataEntry {
  /// Creates cache metadata.
  CacheMetadataEntry({
    required this.cacheKey,
    required this.dataType,
    required this.source,
    required this.fetchedAt,
    required this.expiresAt,
    this.etag,
  }) {
    if (cacheKey.trim().isEmpty) {
      throw ArgumentError.value(cacheKey, 'cacheKey', 'must not be empty');
    }
    if (source.trim().isEmpty) {
      throw ArgumentError.value(source, 'source', 'must not be empty');
    }
    if (expiresAt.isBefore(fetchedAt)) {
      throw ArgumentError.value(
        expiresAt,
        'expiresAt',
        'must not be before fetchedAt',
      );
    }
  }

  /// Stable request identity, e.g. `dividends:isin:DE0008404005`.
  final String cacheKey;

  /// Category used to select a cache lifetime.
  final CacheDataType dataType;

  /// Provider that supplied the payload.
  final String source;

  /// When the payload was retrieved.
  final DateTime fetchedAt;

  /// First instant at which the payload is stale.
  final DateTime expiresAt;

  /// HTTP entity validator for a conditional refresh.
  final String? etag;

  /// Resolves freshness at [now]. An existing entry is never missing.
  CacheState stateAt(DateTime now) =>
      expiresAt.isAfter(now) ? CacheState.fresh : CacheState.stale;

  @override
  bool operator ==(Object other) =>
      other is CacheMetadataEntry &&
      other.cacheKey == cacheKey &&
      other.dataType == dataType &&
      other.source == source &&
      other.fetchedAt == fetchedAt &&
      other.expiresAt == expiresAt &&
      other.etag == etag;

  @override
  int get hashCode =>
      Object.hash(cacheKey, dataType, source, fetchedAt, expiresAt, etag);
}
