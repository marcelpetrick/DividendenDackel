// Row classes are prefixed with `Db` so a persistence row never shadows the
// domain entity of the same name. The repository layer maps between the two,
// and keeping both readable in one file matters there.
import 'package:dividendendackel/domain/entities/dividend_event.dart';
import 'package:dividendendackel/domain/entities/earnings_event.dart';
import 'package:dividendendackel/domain/entities/news_item.dart';
import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:drift/drift.dart';

/// Columns recording where a row came from and how fresh it is.
///
/// Mirrors the `Provenance` value object so every cached record can answer the
/// transparency questions in Vision.md §45 without a join.
mixin ProvenanceColumns on Table {
  /// Provider that supplied the row, e.g. `fmp`, `user`, `sample`.
  TextColumn get source => text().withLength(min: 1, max: 64)();

  /// When the row was retrieved.
  DateTimeColumn get fetchedAt => dateTime()();

  /// When the content last changed, if the provider reports it.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  /// Freshness relative to the configured cache lifetime.
  TextColumn get cacheState =>
      textEnum<CacheState>().withDefault(const Constant('fresh'))();

  /// How much trust the value deserves.
  TextColumn get confidence =>
      textEnum<Confidence>().withDefault(const Constant('high'))();

  /// Currency the provider reported, before normalization.
  TextColumn get reportedCurrency => text().nullable()();

  /// Symbol the provider used.
  TextColumn get originalSymbol => text().nullable()();

  /// Exchange the provider attributed the row to.
  TextColumn get providerExchange => text().nullable()();
}

/// Instruments known to the app (Vision.md §36).
@DataClassName('DbInstrument')
class Instruments extends Table {
  /// Stable app-internal identifier, never a bare ticker.
  TextColumn get internalId => text()();

  /// Primary ticker symbol.
  TextColumn get symbol => text()();

  /// Company or fund name.
  TextColumn get name => text()();

  /// ISO 4217 code the instrument trades in.
  TextColumn get currencyCode => text().withLength(min: 3, max: 8)();

  /// Exchange name or code.
  TextColumn get exchange => text().nullable()();

  /// ISO 10383 Market Identifier Code.
  TextColumn get mic => text().nullable()();

  /// ISO 6166 identifier.
  TextColumn get isin => text().nullable()();

  /// ISO 3166-1 alpha-2 country of domicile.
  TextColumn get country => text().nullable()();

  /// Sector classification, for concentration analysis.
  TextColumn get sector => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{internalId};
}

/// How each provider spells an instrument (Vision.md §36).
@DataClassName('DbProviderMapping')
class ProviderMappings extends Table {
  /// The instrument this mapping belongs to.
  TextColumn get instrumentId => text().references(
    Instruments,
    #internalId,
    onDelete: KeyAction.cascade,
  )();

  /// Provider identifier, e.g. `fmp`.
  TextColumn get providerId => text()();

  /// The symbol that provider expects.
  TextColumn get symbol => text()();

  /// The provider's own opaque identifier.
  TextColumn get providerInstrumentId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    instrumentId,
    providerId,
  };
}

/// Positions the user owns (Vision.md §8).
///
/// User-owned rows: a provider refresh must never delete or overwrite these
/// (Vision.md §76).
@DataClassName('DbHolding')
class Holdings extends Table with ProvenanceColumns {
  /// Surrogate key, so the same instrument could later hold several lots.
  IntColumn get id => integer().autoIncrement()();

  /// The instrument held.
  TextColumn get instrumentId => text().references(Instruments, #internalId)();

  /// Share count as an exact decimal string. Never a floating-point number.
  TextColumn get quantity => text()();

  /// Average price paid per share, as an exact decimal string.
  TextColumn get averagePriceAmount => text().nullable()();

  /// Currency of [averagePriceAmount].
  TextColumn get averagePriceCurrency => text().nullable()();

  /// When the position was opened.
  DateTimeColumn get purchaseDate => dateTime().nullable()();

  /// Free-form user note.
  TextColumn get notes => text().nullable()();
}

/// Instruments the user follows without owning (Vision.md §8.1).
@DataClassName('DbWatchlistEntry')
class WatchlistEntries extends Table with ProvenanceColumns {
  /// The instrument followed.
  TextColumn get instrumentId => text().references(Instruments, #internalId)();

  /// When the user added it.
  DateTimeColumn get addedAt => dateTime()();

  /// Free-form user note.
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{instrumentId};
}

/// Most recent price per instrument (Vision.md §37).
@DataClassName('DbQuote')
class Quotes extends Table with ProvenanceColumns {
  /// The quoted instrument.
  TextColumn get instrumentId => text().references(
    Instruments,
    #internalId,
    onDelete: KeyAction.cascade,
  )();

  /// Last known price as an exact decimal string.
  TextColumn get priceAmount => text()();

  /// Currency of the price.
  TextColumn get priceCurrency => text()();

  /// Previous session close, when reported.
  TextColumn get previousCloseAmount => text().nullable()();

  /// When the price was observed.
  DateTimeColumn get asOf => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{instrumentId};
}

/// Daily reference exchange rates (Vision.md §20, §45).
@TableIndex(name: 'idx_fx_rate_observed_at', columns: <Symbol>{#observedAt})
@DataClassName('DbFxRate')
class FxRates extends Table with ProvenanceColumns {
  /// Currency one unit is converted from.
  TextColumn get baseCurrency => text().withLength(min: 3, max: 8)();

  /// Currency the quoted amount is denominated in.
  TextColumn get quoteCurrency => text().withLength(min: 3, max: 8)();

  /// Exact decimal units of quote currency for one base unit.
  TextColumn get rate => text()();

  /// Reference-rate date.
  DateTimeColumn get observedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    baseCurrency,
    quoteCurrency,
    observedAt,
  };
}

/// Dividend payments, past, announced and estimated (Vision.md §9).
@TableIndex(name: 'idx_dividend_ex_date', columns: <Symbol>{#exDate})
@TableIndex(name: 'idx_dividend_payment_date', columns: <Symbol>{#paymentDate})
@TableIndex(name: 'idx_dividend_instrument', columns: <Symbol>{#instrumentId})
@DataClassName('DbDividendEvent')
class DividendEvents extends Table with ProvenanceColumns {
  /// Deterministic identifier, so re-fetching updates rather than duplicates.
  TextColumn get id => text()();

  /// The paying instrument.
  TextColumn get instrumentId => text().references(
    Instruments,
    #internalId,
    onDelete: KeyAction.cascade,
  )();

  /// Gross dividend per share as an exact decimal string.
  TextColumn get amountPerShare => text()();

  /// Currency of the dividend.
  TextColumn get amountCurrency => text()();

  /// How certain this payment is (Vision.md §9.4).
  TextColumn get status => textEnum<DividendStatus>()();

  /// The payment schedule this event belongs to.
  TextColumn get frequency =>
      textEnum<DividendFrequency>().withDefault(const Constant('unknown'))();

  /// Entitlement date. Nullable: not every provider reports it.
  DateTimeColumn get exDate => dateTime().nullable()();

  /// Expected or confirmed payout date. Nullable by design, so
  /// "Payment date not yet confirmed" is representable (Vision.md §79).
  DateTimeColumn get paymentDate => dateTime().nullable()();

  /// When the company announced the dividend.
  DateTimeColumn get declarationDate => dateTime().nullable()();

  /// Shareholder-of-record date.
  DateTimeColumn get recordDate => dateTime().nullable()();

  /// Provider reporting-period start; not an event date.
  DateTimeColumn get reportedPeriodStart => dateTime().nullable()();

  /// Provider reporting-period end; not an event date.
  DateTimeColumn get reportedPeriodEnd => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Scheduled and reported earnings releases (Vision.md §7).
@TableIndex(name: 'idx_earnings_scheduled', columns: <Symbol>{#scheduledFor})
@DataClassName('DbEarningsEvent')
class EarningsEvents extends Table with ProvenanceColumns {
  /// Deterministic identifier.
  TextColumn get id => text()();

  /// The reporting instrument.
  TextColumn get instrumentId => text().references(
    Instruments,
    #internalId,
    onDelete: KeyAction.cascade,
  )();

  /// Date of the release.
  DateTimeColumn get scheduledFor => dateTime()();

  /// How firm the date is.
  TextColumn get status => textEnum<EarningsStatus>()();

  /// When during the day the release happens.
  TextColumn get timing =>
      textEnum<EarningsTiming>().withDefault(const Constant('unspecified'))();

  /// Fiscal period label, e.g. `Q2 2026`.
  TextColumn get fiscalPeriod => text().nullable()();

  /// Consensus earnings per share.
  TextColumn get epsEstimate => text().nullable()();

  /// Reported earnings per share.
  TextColumn get epsActual => text().nullable()();

  /// Consensus revenue.
  TextColumn get revenueEstimate => text().nullable()();

  /// Reported revenue.
  TextColumn get revenueActual => text().nullable()();

  /// Currency of the EPS and revenue figures.
  TextColumn get figuresCurrency => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Headlines, stored as metadata with a link to the source (Vision.md §18).
@TableIndex(name: 'idx_news_published', columns: <Symbol>{#publishedAt})
@DataClassName('DbNewsItem')
class NewsItems extends Table with ProvenanceColumns {
  /// Deterministic identifier, used to deduplicate across providers.
  TextColumn get id => text()();

  /// The headline as published.
  TextColumn get headline => text()();

  /// Publication name.
  TextColumn get sourceName => text()();

  /// When it was published.
  DateTimeColumn get publishedAt => dateTime()();

  /// Link to the original article. The app never stores article bodies.
  TextColumn get url => text()();

  /// What the item is about.
  TextColumn get category =>
      textEnum<NewsCategory>().withDefault(const Constant('general'))();

  /// Short provider-supplied summary.
  TextColumn get summary => text().nullable()();

  /// Relevance to the portfolio, assigned by ranking (Vision.md §17).
  RealColumn get relevance => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Which instruments a news item concerns.
@DataClassName('DbNewsInstrumentLink')
class NewsInstrumentLinks extends Table {
  /// The news item.
  TextColumn get newsId =>
      text().references(NewsItems, #id, onDelete: KeyAction.cascade)();

  /// The instrument it concerns.
  TextColumn get instrumentId => text().references(
    Instruments,
    #internalId,
    onDelete: KeyAction.cascade,
  )();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{newsId, instrumentId};
}

/// Regulatory filings (Vision.md §46).
@TableIndex(name: 'idx_filing_filed_at', columns: <Symbol>{#filedAt})
@DataClassName('DbFiling')
class Filings extends Table with ProvenanceColumns {
  /// Accession number or equivalent.
  TextColumn get id => text()();

  /// The filing company's instrument.
  TextColumn get instrumentId => text().references(
    Instruments,
    #internalId,
    onDelete: KeyAction.cascade,
  )();

  /// Form type as published, e.g. `10-K`.
  TextColumn get formType => text()();

  /// When it was filed.
  DateTimeColumn get filedAt => dateTime()();

  /// Link to the filing at its source.
  TextColumn get url => text()();

  /// Human-readable description.
  TextColumn get title => text().nullable()();

  /// The period the filing reports on.
  DateTimeColumn get periodOfReport => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// Point-in-time research assessments (Vision.md §15, §16).
///
/// Retained as a history so the app can report what changed since the last
/// refresh.
@TableIndex(name: 'idx_research_taken_at', columns: <Symbol>{#takenAt})
@DataClassName('DbResearchSnapshot')
class ResearchSnapshots extends Table with ProvenanceColumns {
  /// Surrogate key; snapshots accumulate over time.
  IntColumn get id => integer().autoIncrement()();

  /// The assessed instrument.
  TextColumn get instrumentId => text().references(
    Instruments,
    #internalId,
    onDelete: KeyAction.cascade,
  )();

  /// When the assessment was computed.
  DateTimeColumn get takenAt => dateTime()();

  /// Combined score, 0 to 100.
  IntColumn get overallScore => integer()();

  /// One-line explanation shown to the user.
  TextColumn get overallSummary => text()();

  /// Factors behind the overall score, as JSON.
  TextColumn get overallFactorsJson => text()();

  /// Per-dimension assessments, as JSON. Absent dimensions are omitted rather
  /// than stored as zero.
  TextColumn get dimensionsJson => text().withDefault(const Constant('{}'))();
}

/// User-configured notification rules (Vision.md §22).
@DataClassName('DbAlertRule')
class AlertRules extends Table {
  /// Surrogate key.
  IntColumn get id => integer().autoIncrement()();

  /// The instrument this rule applies to, or null for all holdings.
  TextColumn get instrumentId => text().nullable().references(
    Instruments,
    #internalId,
    onDelete: KeyAction.cascade,
  )();

  /// Rule discriminator, e.g. `exDividendTomorrow`.
  TextColumn get kind => text()();

  /// Whether the rule is active.
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// Rule-specific configuration, as JSON.
  TextColumn get configJson => text().withDefault(const Constant('{}'))();
}

/// Runtime health of each data provider (Vision.md §41, §43).
@DataClassName('DbProviderState')
class ProviderStates extends Table {
  /// Provider identifier.
  TextColumn get providerId => text()();

  /// Current health, e.g. `healthy`, `rateLimited`, `offline`.
  TextColumn get health => text()();

  /// When the provider was last called.
  DateTimeColumn get lastRequestAt => dateTime().nullable()();

  /// When the provider accepts requests again.
  DateTimeColumn get rateLimitResetAt => dateTime().nullable()();

  /// Category of the most recent failure.
  TextColumn get lastErrorCategory => text().nullable()();

  /// Diagnostic detail of the most recent failure. Never user-facing.
  TextColumn get lastErrorDetail => text().nullable()();

  /// Requests served from cache, for the hit-rate display.
  IntColumn get cacheHits => integer().withDefault(const Constant(0))();

  /// Requests that reached the provider.
  IntColumn get cacheMisses => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{providerId};
}

/// Queued and running refresh work (Vision.md §40, §42).
@DataClassName('DbSyncJob')
class SyncJobs extends Table {
  /// Surrogate key.
  IntColumn get id => integer().autoIncrement()();

  /// What is being fetched, e.g. `dividends`.
  TextColumn get kind => text()();

  /// The instrument the job concerns, when it concerns one.
  TextColumn get instrumentId => text().nullable()();

  /// Scheduling priority: high, medium or low.
  TextColumn get priority => text()();

  /// Lifecycle state, e.g. `queued`, `running`, `succeeded`, `failed`.
  TextColumn get state => text()();

  /// Provider selected for the job.
  TextColumn get providerId => text().nullable()();

  /// When the job started.
  DateTimeColumn get startedAt => dateTime().nullable()();

  /// When the job finished.
  DateTimeColumn get finishedAt => dateTime().nullable()();

  /// How many attempts have been made.
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// Category of the last failure.
  TextColumn get lastErrorCategory => text().nullable()();
}

/// Structured operational log, surfaced by the Data Status screen
/// (Vision.md §42, §56).
@TableIndex(name: 'idx_sync_log_time', columns: <Symbol>{#timestamp})
@DataClassName('DbSyncLog')
class SyncLogs extends Table {
  /// Surrogate key.
  IntColumn get id => integer().autoIncrement()();

  /// When the entry was written.
  DateTimeColumn get timestamp => dateTime()();

  /// Severity label.
  TextColumn get level => text()();

  /// Emitting subsystem.
  TextColumn get component => text()();

  /// Provider involved, when any.
  TextColumn get provider => text().nullable()();

  /// Logical operation.
  TextColumn get operation => text().nullable()();

  /// Human-readable message. Must never contain portfolio content.
  TextColumn get message => text()();

  /// Measured duration in milliseconds.
  IntColumn get durationMs => integer().nullable()();

  /// Category of the failure, when the entry describes one.
  TextColumn get errorCategory => text().nullable()();
}

/// Cache bookkeeping per request key (Vision.md §37, §38).
@DataClassName('DbCacheMetadata')
class CacheMetadata extends Table {
  /// Request key, e.g. `dividends:isin:DE0008404005`.
  TextColumn get cacheKey => text()();

  /// Data type, which determines the cache lifetime.
  TextColumn get dataType => text()();

  /// Provider that supplied the cached payload.
  TextColumn get source => text()();

  /// When it was fetched.
  DateTimeColumn get fetchedAt => dateTime()();

  /// When it becomes stale.
  DateTimeColumn get expiresAt => dateTime()();

  /// Provider validator for conditional requests, when supplied.
  TextColumn get etag => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{cacheKey};
}
