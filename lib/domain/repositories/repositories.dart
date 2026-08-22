import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// A half-open date range, used for calendar and forecast queries.
final class DateRange {
  /// Creates a range covering [start] inclusive to [end] exclusive.
  DateRange(this.start, this.end) {
    if (!end.isAfter(start)) {
      throw ArgumentError.value(end, 'end', 'end must be after start');
    }
  }

  /// A range of [days] starting at [from].
  factory DateRange.days(DateTime from, int days) =>
      DateRange(from, from.add(Duration(days: days)));

  /// The inclusive lower bound.
  final DateTime start;

  /// The exclusive upper bound.
  final DateTime end;

  /// Whether [moment] falls inside the range.
  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);

  @override
  String toString() => 'DateRange($start .. $end)';

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// Reads and writes the instruments the app knows about.
///
/// Repositories expose streams because the UI observes the local database
/// rather than provider responses (Vision.md §35): a background refresh writes
/// here and the screens update themselves.
abstract interface class InstrumentRepository {
  /// Emits the instrument with [internalId], or `null` while it is unknown.
  Stream<Instrument?> watchInstrument(String internalId);

  /// Emits every known instrument, ordered by name.
  Stream<List<Instrument>> watchAll();

  /// Reads a single instrument.
  Future<Result<Instrument?>> findById(String internalId);

  /// Searches the local database by name, symbol or ISIN.
  ///
  /// Local-first: this answers from cached data and never performs a network
  /// request (Vision.md §2.4).
  Future<Result<List<Instrument>>> search(String query, {int limit = 20});

  /// Inserts or updates [instrument] together with its provider mappings.
  Future<Result<void>> save(Instrument instrument);
}

/// Reads and writes the user's portfolio and watchlist.
///
/// These rows belong to the user. A provider refresh must never modify or
/// delete them (Vision.md §76).
abstract interface class PortfolioRepository {
  /// Emits the current holdings.
  Stream<List<Holding>> watchHoldings();

  /// Emits the holding for [instrumentId], or `null` when none exists.
  Stream<Holding?> watchHolding(String instrumentId);

  /// Emits the watchlist, most recently added first.
  Stream<List<WatchlistEntry>> watchWatchlist();

  /// Adds or replaces the holding for its instrument.
  Future<Result<void>> saveHolding(Holding holding);

  /// Changes the quantity of an existing holding.
  Future<Result<void>> updateQuantity(String instrumentId, Decimal quantity);

  /// Removes the holding for [instrumentId], leaving the instrument itself.
  Future<Result<void>> removeHolding(String instrumentId);

  /// Adds [entry] to the watchlist, replacing any existing entry.
  Future<Result<void>> addToWatchlist(WatchlistEntry entry);

  /// Removes [instrumentId] from the watchlist.
  Future<Result<void>> removeFromWatchlist(String instrumentId);

  /// Instrument ids the user holds or watches, which drive refresh priority
  /// and news relevance (Vision.md §17, §40).
  Stream<Set<String>> watchFollowedInstrumentIds();
}

/// Reads and writes dividend events.
abstract interface class DividendRepository {
  /// Emits every dividend known for [instrumentId], newest first.
  Stream<List<DividendEvent>> watchForInstrument(String instrumentId);

  /// Emits dividends falling inside [range], organised by [mode].
  ///
  /// Events whose date for that mode is unknown are excluded: the calendar
  /// cannot place them, and inventing a date would violate Vision.md §79.
  Stream<List<DividendEvent>> watchInRange(
    DateRange range,
    DividendDateMode mode, {
    Set<String>? instrumentIds,
  });

  /// Inserts or updates [events]. [idOf] must be deterministic so re-fetching
  /// updates rather than duplicates.
  Future<Result<void>> saveAll(
    List<DividendEvent> events, {
    required String Function(DividendEvent event) idOf,
  });
}

/// Reads and writes cached market data other than dividends.
abstract interface class MarketDataRepository {
  /// Emits the latest quote for [instrumentId], or `null` when none is cached.
  Stream<Quote?> watchQuote(String instrumentId);

  /// Emits the latest quotes for [instrumentIds].
  Stream<Map<String, Quote>> watchQuotes(Set<String> instrumentIds);

  /// Emits earnings events inside [range].
  Stream<List<EarningsEvent>> watchEarningsInRange(
    DateRange range, {
    Set<String>? instrumentIds,
  });

  /// Emits recent news, newest first.
  Stream<List<NewsItem>> watchRecentNews({
    Set<String>? instrumentIds,
    int limit = 50,
  });

  /// Emits recent filings, newest first.
  Stream<List<Filing>> watchRecentFilings({
    Set<String>? instrumentIds,
    int limit = 50,
  });

  /// Inserts or updates a quote.
  Future<Result<void>> saveQuote(Quote quote);
}

/// Reads and writes daily foreign-exchange reference rates.
abstract interface class FxRateRepository {
  /// Emits rates inside [range], oldest first.
  Stream<List<FxRate>> watchInRange(
    Currency base,
    Set<Currency> quotes,
    DateRange range,
  );

  /// Emits the newest cached rate for every requested quote.
  Stream<Map<Currency, FxRate>> watchLatest(
    Currency base,
    Set<Currency> quotes,
  );

  /// Inserts or updates exact daily rate rows.
  Future<Result<void>> saveAll(List<FxRate> rates);
}

/// Reads and writes cache-expiry bookkeeping used by the coordinator.
abstract interface class CacheMetadataRepository {
  /// Reads metadata for [cacheKey], or `null` on a cache miss.
  Future<Result<CacheMetadataEntry?>> find(String cacheKey);

  /// Inserts or replaces [entry].
  Future<Result<void>> save(CacheMetadataEntry entry);

  /// Removes metadata after a cached payload is deleted.
  Future<Result<void>> remove(String cacheKey);
}

/// Persists provider telemetry used by the Data Status screen.
abstract interface class ProviderStatusRepository {
  /// Emits the latest status for every provider that has been observed.
  Stream<List<ProviderStatus>> watchAll();

  /// Records the start of a request without discarding earlier health data.
  Future<Result<void>> recordRequestStarted(String providerId, DateTime at);

  /// Records a successful request and clears a previous error.
  Future<Result<void>> recordSuccess(String providerId, DateTime at);

  /// Records a failed request using privacy-safe, user-facing detail.
  Future<Result<void>> recordFailure(
    String providerId,
    DateTime at,
    Failure failure,
  );

  /// Atomically increments the provider's cache hit or miss counter.
  Future<Result<void>> recordCacheAccess(
    String providerId, {
    required bool hit,
  });
}
