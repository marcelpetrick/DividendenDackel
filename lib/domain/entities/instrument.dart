import 'package:dividendendackel/domain/value_objects/currency.dart';

/// How one provider refers to an instrument.
///
/// Providers disagree about symbols — Allianz is `ALV.DE` at one and `ALV.XETRA`
/// at another — so the mapping from the app's instrument to each provider's
/// identifier is stored explicitly rather than guessed at request time.
final class ProviderMapping {
  /// Creates a mapping for [providerId].
  const ProviderMapping({
    required this.providerId,
    required this.symbol,
    this.providerInstrumentId,
  });

  /// Identifier of the provider, e.g. `fmp`.
  final String providerId;

  /// The symbol this provider expects.
  final String symbol;

  /// The provider's own opaque identifier, when it has one.
  final String? providerInstrumentId;

  @override
  String toString() => '$providerId:$symbol';

  @override
  bool operator ==(Object other) =>
      other is ProviderMapping &&
      other.providerId == providerId &&
      other.symbol == symbol &&
      other.providerInstrumentId == providerInstrumentId;

  @override
  int get hashCode => Object.hash(providerId, symbol, providerInstrumentId);
}

/// A tradable instrument, identified independently of any single provider.
///
/// Vision.md §36 is explicit that a ticker alone is not an identity: `ALV` is
/// Allianz in Frankfurt and something else elsewhere. Every instrument
/// therefore has an app-internal [internalId], and the symbol is only one
/// attribute among several.
final class Instrument {
  /// Creates an instrument.
  const Instrument({
    required this.internalId,
    required this.symbol,
    required this.name,
    required this.currency,
    this.exchange,
    this.mic,
    this.isin,
    this.country,
    this.sector,
    this.providerMappings = const <ProviderMapping>[],
  });

  /// Stable app-internal identifier. Never a bare ticker.
  final String internalId;

  /// Primary ticker symbol, e.g. `ALV`.
  final String symbol;

  /// Company or fund name, e.g. `Allianz SE`.
  final String name;

  /// Currency the instrument trades in.
  final Currency currency;

  /// Human-readable exchange name or code, e.g. `XETRA`.
  final String? exchange;

  /// ISO 10383 Market Identifier Code, e.g. `XETR`.
  final String? mic;

  /// ISO 6166 identifier, e.g. `DE0008404005`.
  final String? isin;

  /// ISO 3166-1 alpha-2 country of domicile, e.g. `DE`.
  final String? country;

  /// Sector classification, used for portfolio concentration (Vision.md §20).
  final String? sector;

  /// How each provider refers to this instrument.
  final List<ProviderMapping> providerMappings;

  /// Builds an internal id from the parts that actually disambiguate a ticker.
  ///
  /// Prefers the ISIN, which is globally unique, and otherwise falls back to
  /// the symbol qualified by its market — never the bare symbol.
  static String buildInternalId({
    required String symbol,
    String? isin,
    String? mic,
    String? exchange,
  }) {
    final String? normalizedIsin = _normalize(isin);
    if (normalizedIsin != null) {
      return 'isin:$normalizedIsin';
    }
    final String? market = _normalize(mic) ?? _normalize(exchange);
    final String normalizedSymbol = symbol.trim().toUpperCase();
    if (normalizedSymbol.isEmpty) {
      throw ArgumentError.value(
        symbol,
        'symbol',
        'An instrument needs at least a symbol',
      );
    }
    return market == null
        ? 'sym:$normalizedSymbol'
        : 'sym:$normalizedSymbol@$market';
  }

  static String? _normalize(String? value) {
    final String? trimmed = value?.trim().toUpperCase();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// The symbol [providerId] expects, or `null` when no mapping is known.
  String? symbolFor(String providerId) {
    for (final ProviderMapping mapping in providerMappings) {
      if (mapping.providerId == providerId) {
        return mapping.symbol;
      }
    }
    return null;
  }

  /// Whether a mapping for [providerId] exists.
  bool hasMappingFor(String providerId) => symbolFor(providerId) != null;

  /// The market this instrument trades on, preferring the MIC.
  String? get market => mic ?? exchange;

  /// A short label for lists, e.g. `ALV · XETR`.
  String get displaySymbol => market == null ? symbol : '$symbol · $market';

  /// Returns a copy with the given fields replaced.
  Instrument copyWith({
    String? internalId,
    String? symbol,
    String? name,
    Currency? currency,
    String? exchange,
    String? mic,
    String? isin,
    String? country,
    String? sector,
    List<ProviderMapping>? providerMappings,
  }) => Instrument(
    internalId: internalId ?? this.internalId,
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
    currency: currency ?? this.currency,
    exchange: exchange ?? this.exchange,
    mic: mic ?? this.mic,
    isin: isin ?? this.isin,
    country: country ?? this.country,
    sector: sector ?? this.sector,
    providerMappings: providerMappings ?? this.providerMappings,
  );

  @override
  String toString() => 'Instrument($internalId, $name)';

  /// Identity is the [internalId]; two records describing the same instrument
  /// are the same instrument even if a provider filled in more fields.
  @override
  bool operator ==(Object other) =>
      other is Instrument && other.internalId == internalId;

  @override
  int get hashCode => internalId.hashCode;
}
