import 'package:dividendendackel/domain/value_objects/currency.dart';

/// Freshness of a cached record relative to its configured lifetime
/// (Vision.md §37, §38).
enum CacheState {
  /// Within its cache lifetime; safe to show without a refresh.
  fresh,

  /// Past its lifetime but still usable. Show it immediately, mark it as
  /// stale, and refresh in the background.
  stale,

  /// Nothing cached; the value must be fetched before it can be shown.
  missing,
}

/// How much trust a value deserves (Vision.md §48).
///
/// Applies to forecasts and derived values. A confirmed dividend that a
/// provider reported is [Confidence.high]; one inferred from a historical
/// payment pattern is [Confidence.low].
enum Confidence {
  /// Reported or confirmed by a provider.
  high,

  /// Derived from recent, consistent data.
  medium,

  /// Inferred from history, with meaningful uncertainty.
  low,
}

/// Where a value came from and how fresh it is (Vision.md §45).
///
/// The vision treats data uncertainty as part of the product: important values
/// expose their source, age, cache state and confirmation status rather than
/// appearing as bare numbers. Every record that can originate from a provider
/// carries one of these.
final class Provenance {
  /// Creates provenance metadata.
  const Provenance({
    required this.source,
    required this.fetchedAt,
    this.updatedAt,
    this.cacheState = CacheState.fresh,
    this.confidence = Confidence.high,
    this.reportedCurrency,
    this.originalSymbol,
    this.exchange,
  });

  /// Provenance for data the user entered themselves, which needs no refresh.
  factory Provenance.user(DateTime at) =>
      Provenance(source: userSource, fetchedAt: at);

  /// Provenance for the bundled sample dataset.
  factory Provenance.sample(DateTime at) =>
      Provenance(source: sampleSource, fetchedAt: at);

  /// Source identifier for values the user entered.
  static const String userSource = 'user';

  /// Source identifier for the bundled offline dataset.
  static const String sampleSource = 'sample';

  /// Identifier of the provider that supplied the value, e.g. `fmp`, `sec`,
  /// [userSource] or [sampleSource].
  final String source;

  /// When the value was retrieved from [source].
  final DateTime fetchedAt;

  /// When the value last changed, if the provider reports it.
  ///
  /// This is the *content* timestamp, whereas [fetchedAt] is the *retrieval*
  /// timestamp; a record can be fetched repeatedly without changing.
  final DateTime? updatedAt;

  /// Freshness relative to the configured cache lifetime.
  final CacheState cacheState;

  /// How much trust the value deserves.
  final Confidence confidence;

  /// The currency the provider reported, before any normalization.
  ///
  /// Kept for traceability: the amount on the record itself already carries the
  /// currency it is denominated in.
  final Currency? reportedCurrency;

  /// The symbol the provider used, which may differ from the app's symbol.
  final String? originalSymbol;

  /// The exchange the provider attributed the value to.
  final String? exchange;

  /// Whether the value came from the user rather than a provider.
  bool get isUserProvided => source == userSource;

  /// Whether the value should be refreshed before being trusted as current.
  bool get isStale => cacheState == CacheState.stale;

  /// How old the value is at [now].
  ///
  /// Drives the "Last updated 42 minutes ago" copy required by Vision.md §38.
  Duration ageAt(DateTime now) => now.difference(fetchedAt);

  /// Returns a copy with the given fields replaced.
  Provenance copyWith({
    String? source,
    DateTime? fetchedAt,
    DateTime? updatedAt,
    CacheState? cacheState,
    Confidence? confidence,
    Currency? reportedCurrency,
    String? originalSymbol,
    String? exchange,
  }) => Provenance(
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    cacheState: cacheState ?? this.cacheState,
    confidence: confidence ?? this.confidence,
    reportedCurrency: reportedCurrency ?? this.reportedCurrency,
    originalSymbol: originalSymbol ?? this.originalSymbol,
    exchange: exchange ?? this.exchange,
  );

  @override
  String toString() =>
      'Provenance($source, fetched $fetchedAt, ${cacheState.name}, '
      '${confidence.name})';

  @override
  bool operator ==(Object other) =>
      other is Provenance &&
      other.source == source &&
      other.fetchedAt == fetchedAt &&
      other.updatedAt == updatedAt &&
      other.cacheState == cacheState &&
      other.confidence == confidence &&
      other.reportedCurrency == reportedCurrency &&
      other.originalSymbol == originalSymbol &&
      other.exchange == exchange;

  @override
  int get hashCode => Object.hash(
    source,
    fetchedAt,
    updatedAt,
    cacheState,
    confidence,
    reportedCurrency,
    originalSymbol,
    exchange,
  );
}

/// Implemented by domain records that carry [Provenance].
abstract interface class HasProvenance {
  /// Where this record came from and how fresh it is.
  Provenance get provenance;
}
