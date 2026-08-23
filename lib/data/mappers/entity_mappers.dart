import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:drift/drift.dart';

/// Translates between persistence rows and domain entities.
///
/// This is the only place that knows amounts are stored as decimal strings and
/// that timestamps come back needing normalization to UTC. A malformed row
/// raises a [ParsingFailure] rather than silently yielding a wrong number —
/// Vision.md §79 forbids fabricating values, and a corrupt cache row is exactly
/// the case where a plausible-looking default would do damage.
abstract final class EntityMappers {
  /// Parses an exact decimal, failing loudly on malformed input.
  static Decimal parseDecimal(String raw, String field) {
    try {
      return Decimal.parse(raw);
    } on FormatException catch (error) {
      throw ParsingFailure(
        technicalDetail: 'Malformed decimal in "$field": "$raw"',
        cause: error,
      );
    }
  }

  /// Parses a stored money amount.
  static Money parseMoney(String amount, String currencyCode, String field) =>
      Money(parseDecimal(amount, field), Currency.parse(currencyCode));

  /// Parses an optional money amount, requiring a currency when present.
  static Money? parseOptionalMoney(
    String? amount,
    String? currencyCode,
    String field,
  ) {
    if (amount == null) {
      return null;
    }
    if (currencyCode == null) {
      throw ParsingFailure(technicalDetail: 'Amount "$field" has no currency');
    }
    return parseMoney(amount, currencyCode, field);
  }

  /// Normalizes a stored timestamp to UTC so comparisons are unambiguous.
  static DateTime utc(DateTime value) => value.toUtc();

  /// Normalizes an optional stored timestamp.
  static DateTime? utcOrNull(DateTime? value) => value?.toUtc();
}

/// Maps provenance columns onto the domain value object.
extension ProvenanceRowMapper on Provenance {
  /// Builds provenance from the columns shared by every cached record.
  static Provenance fromColumns({
    required String source,
    required DateTime fetchedAt,
    required CacheState cacheState,
    required Confidence confidence,
    DateTime? updatedAt,
    String? reportedCurrency,
    String? originalSymbol,
    String? providerExchange,
  }) => Provenance(
    source: source,
    fetchedAt: EntityMappers.utc(fetchedAt),
    updatedAt: EntityMappers.utcOrNull(updatedAt),
    cacheState: cacheState,
    confidence: confidence,
    reportedCurrency: reportedCurrency == null
        ? null
        : Currency.parse(reportedCurrency),
    originalSymbol: originalSymbol,
    exchange: providerExchange,
  );
}

/// Maps instrument rows.
extension InstrumentRowMapper on DbInstrument {
  /// Builds the domain instrument, attaching its [mappings].
  Instrument toDomain(List<DbProviderMapping> mappings) => Instrument(
    internalId: internalId,
    symbol: symbol,
    name: name,
    currency: Currency.parse(currencyCode),
    exchange: exchange,
    mic: mic,
    isin: isin,
    country: country,
    sector: sector,
    providerMappings: mappings
        .map(
          (DbProviderMapping m) => ProviderMapping(
            providerId: m.providerId,
            symbol: m.symbol,
            providerInstrumentId: m.providerInstrumentId,
          ),
        )
        .toList(growable: false),
  );
}

/// Maps holding rows.
extension HoldingRowMapper on DbHolding {
  /// Builds the domain holding.
  Holding toDomain() => Holding(
    instrumentId: instrumentId,
    quantity: EntityMappers.parseDecimal(quantity, 'holding.quantity'),
    averagePurchasePrice: EntityMappers.parseOptionalMoney(
      averagePriceAmount,
      averagePriceCurrency,
      'holding.averagePrice',
    ),
    purchaseDate: EntityMappers.utcOrNull(purchaseDate),
    notes: notes,
    provenance: ProvenanceRowMapper.fromColumns(
      source: source,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
      cacheState: cacheState,
      confidence: confidence,
      reportedCurrency: reportedCurrency,
      originalSymbol: originalSymbol,
      providerExchange: providerExchange,
    ),
  );
}

/// Maps watchlist rows.
extension WatchlistRowMapper on DbWatchlistEntry {
  /// Builds the domain watchlist entry.
  WatchlistEntry toDomain() => WatchlistEntry(
    instrumentId: instrumentId,
    addedAt: EntityMappers.utc(addedAt),
    notes: notes,
    provenance: ProvenanceRowMapper.fromColumns(
      source: source,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
      cacheState: cacheState,
      confidence: confidence,
      reportedCurrency: reportedCurrency,
      originalSymbol: originalSymbol,
      providerExchange: providerExchange,
    ),
  );
}

/// Maps quote rows.
extension QuoteRowMapper on DbQuote {
  /// Builds the domain quote.
  Quote toDomain() => Quote(
    instrumentId: instrumentId,
    price: EntityMappers.parseMoney(priceAmount, priceCurrency, 'quote.price'),
    previousClose: EntityMappers.parseOptionalMoney(
      previousCloseAmount,
      priceCurrency,
      'quote.previousClose',
    ),
    asOf: EntityMappers.utc(asOf),
    provenance: ProvenanceRowMapper.fromColumns(
      source: source,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
      cacheState: cacheState,
      confidence: confidence,
      reportedCurrency: reportedCurrency,
      originalSymbol: originalSymbol,
      providerExchange: providerExchange,
    ),
  );
}

/// Maps a stored daily FX reference rate.
extension FxRateRowMapper on DbFxRate {
  /// Builds the domain rate.
  FxRate toDomain() => FxRate(
    base: Currency.parse(baseCurrency),
    quote: Currency.parse(quoteCurrency),
    rate: EntityMappers.parseDecimal(rate, 'fxRate.rate'),
    observedAt: EntityMappers.utc(observedAt),
    provenance: ProvenanceRowMapper.fromColumns(
      source: source,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
      cacheState: cacheState,
      confidence: confidence,
      reportedCurrency: reportedCurrency,
      originalSymbol: originalSymbol,
      providerExchange: providerExchange,
    ),
  );
}

/// Maps dividend rows.
extension DividendRowMapper on DbDividendEvent {
  /// Builds the domain dividend event.
  DividendEvent toDomain() => DividendEvent(
    instrumentId: instrumentId,
    amountPerShare: EntityMappers.parseMoney(
      amountPerShare,
      amountCurrency,
      'dividend.amountPerShare',
    ),
    status: status,
    frequency: frequency,
    exDate: EntityMappers.utcOrNull(exDate),
    paymentDate: EntityMappers.utcOrNull(paymentDate),
    declarationDate: EntityMappers.utcOrNull(declarationDate),
    recordDate: EntityMappers.utcOrNull(recordDate),
    reportedPeriodStart: EntityMappers.utcOrNull(reportedPeriodStart),
    reportedPeriodEnd: EntityMappers.utcOrNull(reportedPeriodEnd),
    provenance: ProvenanceRowMapper.fromColumns(
      source: source,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
      cacheState: cacheState,
      confidence: confidence,
      reportedCurrency: reportedCurrency,
      originalSymbol: originalSymbol,
      providerExchange: providerExchange,
    ),
  );
}

/// Maps earnings rows.
extension EarningsRowMapper on DbEarningsEvent {
  /// Builds the domain earnings event.
  EarningsEvent toDomain() => EarningsEvent(
    instrumentId: instrumentId,
    scheduledFor: EntityMappers.utc(scheduledFor),
    status: status,
    timing: timing,
    fiscalPeriod: fiscalPeriod,
    epsEstimate: EntityMappers.parseOptionalMoney(
      epsEstimate,
      figuresCurrency,
      'earnings.epsEstimate',
    ),
    epsActual: EntityMappers.parseOptionalMoney(
      epsActual,
      figuresCurrency,
      'earnings.epsActual',
    ),
    revenueEstimate: EntityMappers.parseOptionalMoney(
      revenueEstimate,
      figuresCurrency,
      'earnings.revenueEstimate',
    ),
    revenueActual: EntityMappers.parseOptionalMoney(
      revenueActual,
      figuresCurrency,
      'earnings.revenueActual',
    ),
    provenance: ProvenanceRowMapper.fromColumns(
      source: source,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
      cacheState: cacheState,
      confidence: confidence,
      reportedCurrency: reportedCurrency,
      originalSymbol: originalSymbol,
      providerExchange: providerExchange,
    ),
  );
}

/// Maps corporate-event rows.
extension CorporateEventRowMapper on DbCorporateEvent {
  /// Builds the domain corporate event.
  CorporateEvent toDomain() => CorporateEvent(
    id: id,
    instrumentId: instrumentId,
    scheduledFor: EntityMappers.utc(scheduledFor),
    type: type,
    status: status,
    title: title,
    url: url == null ? null : Uri.parse(url!),
    provenance: ProvenanceRowMapper.fromColumns(
      source: source,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
      cacheState: cacheState,
      confidence: confidence,
      reportedCurrency: reportedCurrency,
      originalSymbol: originalSymbol,
      providerExchange: providerExchange,
    ),
  );
}

/// Maps news rows.
extension NewsRowMapper on DbNewsItem {
  /// Builds the domain news item, attaching [instrumentIds].
  NewsItem toDomain(List<String> instrumentIds) => NewsItem(
    id: id,
    headline: headline,
    sourceName: sourceName,
    publishedAt: EntityMappers.utc(publishedAt),
    url: Uri.parse(url),
    category: category,
    summary: summary,
    relatedInstrumentIds: instrumentIds,
    relevance: relevance,
    provenance: ProvenanceRowMapper.fromColumns(
      source: source,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
      cacheState: cacheState,
      confidence: confidence,
      reportedCurrency: reportedCurrency,
      originalSymbol: originalSymbol,
      providerExchange: providerExchange,
    ),
  );
}

/// Maps filing rows.
extension FilingRowMapper on DbFiling {
  /// Builds the domain filing.
  Filing toDomain() => Filing(
    id: id,
    instrumentId: instrumentId,
    formType: formType,
    filedAt: EntityMappers.utc(filedAt),
    url: Uri.parse(url),
    title: title,
    periodOfReport: EntityMappers.utcOrNull(periodOfReport),
    provenance: ProvenanceRowMapper.fromColumns(
      source: source,
      fetchedAt: fetchedAt,
      updatedAt: updatedAt,
      cacheState: cacheState,
      confidence: confidence,
      reportedCurrency: reportedCurrency,
      originalSymbol: originalSymbol,
      providerExchange: providerExchange,
    ),
  );
}

/// Maps domain entities onto insert/update companions.
///
/// Kept separate from the read direction because writes must be explicit about
/// which columns they touch: a provider refresh writes market data, never the
/// user's own rows (Vision.md §76).
abstract final class CompanionMappers {
  /// Columns describing where a record came from.
  static _ProvenanceValues _provenanceValues(Provenance p) => (
    source: p.source,
    fetchedAt: p.fetchedAt.toUtc(),
    updatedAt: Value<DateTime?>(p.updatedAt?.toUtc()),
    cacheState: Value<CacheState>(p.cacheState),
    confidence: Value<Confidence>(p.confidence),
    reportedCurrency: Value<String?>(p.reportedCurrency?.code),
    originalSymbol: Value<String?>(p.originalSymbol),
    providerExchange: Value<String?>(p.exchange),
  );

  /// Builds an instrument row.
  static InstrumentsCompanion instrument(Instrument instrument) =>
      InstrumentsCompanion.insert(
        internalId: instrument.internalId,
        symbol: instrument.symbol,
        name: instrument.name,
        currencyCode: instrument.currency.code,
        exchange: Value<String?>(instrument.exchange),
        mic: Value<String?>(instrument.mic),
        isin: Value<String?>(instrument.isin),
        country: Value<String?>(instrument.country),
        sector: Value<String?>(instrument.sector),
      );

  /// Builds the provider-mapping rows for [instrument].
  static List<ProviderMappingsCompanion> providerMappings(
    Instrument instrument,
  ) => instrument.providerMappings
      .map(
        (ProviderMapping m) => ProviderMappingsCompanion.insert(
          instrumentId: instrument.internalId,
          providerId: m.providerId,
          symbol: m.symbol,
          providerInstrumentId: Value<String?>(m.providerInstrumentId),
        ),
      )
      .toList(growable: false);

  /// Builds a holding row. [id] is supplied when updating an existing row.
  static HoldingsCompanion holding(Holding holding, {int? id}) {
    final _ProvenanceValues p = _provenanceValues(holding.provenance);
    return HoldingsCompanion.insert(
      id: id == null ? const Value<int>.absent() : Value<int>(id),
      instrumentId: holding.instrumentId,
      quantity: holding.quantity.toString(),
      averagePriceAmount: Value<String?>(
        holding.averagePurchasePrice?.amount.toString(),
      ),
      averagePriceCurrency: Value<String?>(
        holding.averagePurchasePrice?.currency.code,
      ),
      purchaseDate: Value<DateTime?>(holding.purchaseDate?.toUtc()),
      notes: Value<String?>(holding.notes),
      source: p.source,
      fetchedAt: p.fetchedAt,
      updatedAt: p.updatedAt,
      cacheState: p.cacheState,
      confidence: p.confidence,
      reportedCurrency: p.reportedCurrency,
      originalSymbol: p.originalSymbol,
      providerExchange: p.providerExchange,
    );
  }

  /// Builds a watchlist row.
  static WatchlistEntriesCompanion watchlistEntry(WatchlistEntry entry) {
    final _ProvenanceValues p = _provenanceValues(entry.provenance);
    return WatchlistEntriesCompanion.insert(
      instrumentId: entry.instrumentId,
      addedAt: entry.addedAt.toUtc(),
      notes: Value<String?>(entry.notes),
      source: p.source,
      fetchedAt: p.fetchedAt,
      updatedAt: p.updatedAt,
      cacheState: p.cacheState,
      confidence: p.confidence,
      reportedCurrency: p.reportedCurrency,
      originalSymbol: p.originalSymbol,
      providerExchange: p.providerExchange,
    );
  }

  /// Builds a quote row.
  static QuotesCompanion quote(Quote quote) {
    final _ProvenanceValues p = _provenanceValues(quote.provenance);
    return QuotesCompanion.insert(
      instrumentId: quote.instrumentId,
      priceAmount: quote.price.amount.toString(),
      priceCurrency: quote.price.currency.code,
      previousCloseAmount: Value<String?>(
        quote.previousClose?.amount.toString(),
      ),
      asOf: quote.asOf.toUtc(),
      source: p.source,
      fetchedAt: p.fetchedAt,
      updatedAt: p.updatedAt,
      cacheState: p.cacheState,
      confidence: p.confidence,
      reportedCurrency: p.reportedCurrency,
      originalSymbol: p.originalSymbol,
      providerExchange: p.providerExchange,
    );
  }

  /// Builds a daily FX reference-rate row.
  static FxRatesCompanion fxRate(FxRate rate) {
    final _ProvenanceValues p = _provenanceValues(rate.provenance);
    return FxRatesCompanion.insert(
      baseCurrency: rate.base.code,
      quoteCurrency: rate.quote.code,
      rate: rate.rate.toString(),
      observedAt: rate.observedAt.toUtc(),
      source: p.source,
      fetchedAt: p.fetchedAt,
      updatedAt: p.updatedAt,
      cacheState: p.cacheState,
      confidence: p.confidence,
      reportedCurrency: p.reportedCurrency,
      originalSymbol: p.originalSymbol,
      providerExchange: p.providerExchange,
    );
  }

  /// Builds a dividend row.
  ///
  /// [id] must be deterministic so that re-fetching the same payment updates
  /// the existing row instead of duplicating the calendar entry.
  static DividendEventsCompanion dividendEvent(
    DividendEvent event, {
    required String id,
  }) {
    final _ProvenanceValues p = _provenanceValues(event.provenance);
    return DividendEventsCompanion.insert(
      id: id,
      instrumentId: event.instrumentId,
      amountPerShare: event.amountPerShare.amount.toString(),
      amountCurrency: event.amountPerShare.currency.code,
      status: event.status,
      frequency: Value<DividendFrequency>(event.frequency),
      exDate: Value<DateTime?>(event.exDate?.toUtc()),
      paymentDate: Value<DateTime?>(event.paymentDate?.toUtc()),
      declarationDate: Value<DateTime?>(event.declarationDate?.toUtc()),
      recordDate: Value<DateTime?>(event.recordDate?.toUtc()),
      reportedPeriodStart: Value<DateTime?>(event.reportedPeriodStart?.toUtc()),
      reportedPeriodEnd: Value<DateTime?>(event.reportedPeriodEnd?.toUtc()),
      source: p.source,
      fetchedAt: p.fetchedAt,
      updatedAt: p.updatedAt,
      cacheState: p.cacheState,
      confidence: p.confidence,
      reportedCurrency: p.reportedCurrency,
      originalSymbol: p.originalSymbol,
      providerExchange: p.providerExchange,
    );
  }

  /// Builds an earnings row with a caller-supplied deterministic [id].
  static EarningsEventsCompanion earningsEvent(
    EarningsEvent event, {
    required String id,
  }) {
    final _ProvenanceValues p = _provenanceValues(event.provenance);
    final Set<Currency> currencies = <Currency>{
      if (event.epsEstimate case final Money value) value.currency,
      if (event.epsActual case final Money value) value.currency,
      if (event.revenueEstimate case final Money value) value.currency,
      if (event.revenueActual case final Money value) value.currency,
    };
    if (currencies.length > 1) {
      throw ParsingFailure(
        technicalDetail:
            'Earnings figures for ${event.instrumentId} use multiple '
            'currencies: ${currencies.map((Currency c) => c.code).join(', ')}',
      );
    }
    final Currency? currency = currencies.firstOrNull;
    return EarningsEventsCompanion.insert(
      id: id,
      instrumentId: event.instrumentId,
      scheduledFor: event.scheduledFor.toUtc(),
      status: event.status,
      timing: Value<EarningsTiming>(event.timing),
      fiscalPeriod: Value<String?>(event.fiscalPeriod),
      epsEstimate: Value<String?>(event.epsEstimate?.amount.toString()),
      epsActual: Value<String?>(event.epsActual?.amount.toString()),
      revenueEstimate: Value<String?>(event.revenueEstimate?.amount.toString()),
      revenueActual: Value<String?>(event.revenueActual?.amount.toString()),
      figuresCurrency: Value<String?>(currency?.code),
      source: p.source,
      fetchedAt: p.fetchedAt,
      updatedAt: p.updatedAt,
      cacheState: p.cacheState,
      confidence: p.confidence,
      reportedCurrency: p.reportedCurrency,
      originalSymbol: p.originalSymbol,
      providerExchange: p.providerExchange,
    );
  }

  /// Builds a normalized corporate-event row.
  static CorporateEventsCompanion corporateEvent(CorporateEvent event) {
    final _ProvenanceValues p = _provenanceValues(event.provenance);
    return CorporateEventsCompanion.insert(
      id: event.id,
      instrumentId: event.instrumentId,
      scheduledFor: event.scheduledFor.toUtc(),
      type: event.type,
      status: event.status,
      title: event.title,
      url: Value<String?>(event.url?.toString()),
      source: p.source,
      fetchedAt: p.fetchedAt,
      updatedAt: p.updatedAt,
      cacheState: p.cacheState,
      confidence: p.confidence,
      reportedCurrency: p.reportedCurrency,
      originalSymbol: p.originalSymbol,
      providerExchange: p.providerExchange,
    );
  }

  /// Builds headline metadata only; article bodies are never persisted.
  static NewsItemsCompanion newsItem(NewsItem item) {
    if (item.headline.trim().isEmpty || item.sourceName.trim().isEmpty) {
      throw const ParsingFailure(
        technicalDetail: 'News headline and source must not be empty.',
      );
    }
    if (!item.url.hasScheme ||
        (item.url.scheme != 'https' && item.url.scheme != 'http')) {
      throw ParsingFailure(
        technicalDetail: 'Unsupported news URL scheme: ${item.url.scheme}',
      );
    }
    final _ProvenanceValues p = _provenanceValues(item.provenance);
    return NewsItemsCompanion.insert(
      id: item.id,
      headline: item.headline,
      sourceName: item.sourceName,
      publishedAt: item.publishedAt.toUtc(),
      url: item.url.toString(),
      category: Value<NewsCategory>(item.category),
      summary: Value<String?>(item.summary),
      relevance: Value<double?>(item.relevance),
      source: p.source,
      fetchedAt: p.fetchedAt,
      updatedAt: p.updatedAt,
      cacheState: p.cacheState,
      confidence: p.confidence,
      reportedCurrency: p.reportedCurrency,
      originalSymbol: p.originalSymbol,
      providerExchange: p.providerExchange,
    );
  }

  /// Builds regulatory filing metadata. Filing bodies are never persisted.
  static FilingsCompanion filing(Filing filing) {
    if (!filing.url.hasScheme ||
        (filing.url.scheme != 'https' && filing.url.scheme != 'http')) {
      throw ParsingFailure(
        technicalDetail: 'Unsupported filing URL scheme: ${filing.url.scheme}',
      );
    }
    final _ProvenanceValues p = _provenanceValues(filing.provenance);
    return FilingsCompanion.insert(
      id: filing.id,
      instrumentId: filing.instrumentId,
      formType: filing.formType,
      filedAt: filing.filedAt.toUtc(),
      url: filing.url.toString(),
      title: Value<String?>(filing.title),
      periodOfReport: Value<DateTime?>(filing.periodOfReport?.toUtc()),
      source: p.source,
      fetchedAt: p.fetchedAt,
      updatedAt: p.updatedAt,
      cacheState: p.cacheState,
      confidence: p.confidence,
      reportedCurrency: p.reportedCurrency,
      originalSymbol: p.originalSymbol,
      providerExchange: p.providerExchange,
    );
  }
}

/// The provenance columns every cached record shares, ready for a companion.
typedef _ProvenanceValues = ({
  String source,
  DateTime fetchedAt,
  Value<DateTime?> updatedAt,
  Value<CacheState> cacheState,
  Value<Confidence> confidence,
  Value<String?> reportedCurrency,
  Value<String?> originalSymbol,
  Value<String?> providerExchange,
});
