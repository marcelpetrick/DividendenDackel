import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/utils/clock.dart';
import 'package:dividendendackel/data/sample/sample_dataset.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';

/// Materializes the bundled sample dataset into the local database.
///
/// Patterns are projected around *today* rather than a fixed year, so the
/// calendar and the forecast are populated whenever the app is run. Past
/// payments become `confirmed` history — which is what the dividend CAGR is
/// computed from — and future ones are marked as estimates, never as facts
/// (Vision.md §9.4, §48).
final class SampleDataSeeder {
  /// Creates a seeder writing through the given repositories.
  SampleDataSeeder({
    required this.instruments,
    required this.portfolio,
    required this.dividends,
    required this.marketData,
    this.clock = const SystemClock(),
  });

  /// Instrument repository.
  final InstrumentRepository instruments;

  /// Portfolio repository.
  final PortfolioRepository portfolio;

  /// Dividend repository.
  final DividendRepository dividends;

  /// Market data repository.
  final MarketDataRepository marketData;

  /// Time source, so seeding is deterministic in tests.
  final Clock clock;

  /// How far ahead dividends are projected.
  ///
  /// Two years matches what is useful for planning income and is as far as a
  /// rule-based estimate can honestly reach.
  static const int forecastYears = 2;

  /// A payment inside this window is treated as announced rather than merely
  /// estimated, reflecting that companies confirm shortly before the date.
  static const Duration announcedWindow = Duration(days: 45);

  /// Seeds [dataset], replacing nothing the user has changed.
  ///
  /// Instruments and market data are upserted; the demonstration portfolio and
  /// watchlist are only written when [includePortfolio] is set, so seeding can
  /// refresh reference data without touching user-owned rows (Vision.md §76).
  Future<Result<void>> seed(
    SampleDataset dataset, {
    bool includePortfolio = true,
  }) => Result.guardAsync<void>(() async {
    final DateTime now = clock.now().toUtc();
    final Provenance provenance = Provenance.sample(now);

    for (final SampleInstrument sample in dataset.instruments) {
      final Result<void> saved = await instruments.save(sample.instrument);
      _rethrowFailure(saved);

      _rethrowFailure(
        await marketData.saveQuote(
          Quote(
            instrumentId: sample.internalId,
            price: sample.price,
            previousClose: sample.previousClose,
            asOf: now,
            provenance: provenance,
          ),
        ),
      );
    }

    for (final SampleDividendPattern pattern in dataset.dividendPatterns) {
      final List<DividendEvent> events = buildDividendEvents(
        pattern,
        now: now,
        provenance: provenance,
      );
      _rethrowFailure(await dividends.saveAll(events, idOf: dividendEventId));
    }

    if (includePortfolio) {
      for (final SampleHolding holding in dataset.portfolio) {
        _rethrowFailure(
          await portfolio.saveHolding(
            Holding(
              instrumentId: holding.instrumentId,
              quantity: holding.quantity,
              averagePurchasePrice: Money(
                holding.averagePrice,
                _currencyOf(dataset, holding.instrumentId),
              ),
              purchaseDate: now.add(Duration(days: holding.purchaseOffsetDays)),
              provenance: provenance,
            ),
          ),
        );
      }

      for (final SampleWatchlistEntry entry in dataset.watchlist) {
        _rethrowFailure(
          await portfolio.addToWatchlist(
            WatchlistEntry(
              instrumentId: entry.instrumentId,
              addedAt: now.add(Duration(days: entry.addedOffsetDays)),
              provenance: provenance,
            ),
          ),
        );
      }
    }
  });

  /// Builds the dividend history and forecast implied by [pattern].
  ///
  /// Historical amounts are discounted by the pattern's growth rate, so the
  /// generated series has a real, computable CAGR rather than a flat line.
  static List<DividendEvent> buildDividendEvents(
    SampleDividendPattern pattern, {
    required DateTime now,
    required Provenance provenance,
  }) {
    final int currentYear = now.year;
    final Decimal base = pattern.amountPerPayment;
    final Decimal growthFactor = Decimal.one + pattern.annualGrowthRate.rate;
    final List<DividendEvent> events = <DividendEvent>[];

    for (
      int year = currentYear - pattern.historyYears;
      year <= currentYear + forecastYears;
      year++
    ) {
      final int yearsFromNow = year - currentYear;
      final Decimal amount = _scaleByGrowth(base, growthFactor, yearsFromNow);

      for (final MonthDay anchor in pattern.anchors) {
        final DateTime exDate = anchor.inYear(year);
        final DateTime paymentDate = exDate.add(
          Duration(days: pattern.paymentOffsetDays),
        );

        events.add(
          DividendEvent(
            instrumentId: pattern.instrumentId,
            amountPerShare: Money(amount, pattern.currency),
            status: _statusFor(exDate, now),
            frequency: pattern.frequency,
            exDate: exDate,
            paymentDate: paymentDate,
            provenance: provenance.copyWith(
              confidence: exDate.isAfter(now)
                  ? Confidence.low
                  : Confidence.high,
            ),
          ),
        );
      }
    }
    return events;
  }

  /// A stable id for a generated event, so re-seeding updates in place.
  static String dividendEventId(DividendEvent event) {
    final DateTime? date = event.exDate;
    final String key = date == null
        ? 'unknown'
        : '${date.year}-${date.month.toString().padLeft(2, '0')}-'
              '${date.day.toString().padLeft(2, '0')}';
    return 'sample:${event.instrumentId}:$key';
  }

  static DividendStatus _statusFor(DateTime exDate, DateTime now) {
    if (!exDate.isAfter(now)) {
      return DividendStatus.confirmed;
    }
    if (exDate.difference(now) <= announcedWindow) {
      return DividendStatus.announced;
    }
    return DividendStatus.historicallyEstimated;
  }

  /// Applies [factor] raised to [exponent], which may be negative.
  static Decimal _scaleByGrowth(Decimal base, Decimal factor, int exponent) {
    if (exponent == 0 || factor == Decimal.one) {
      return base;
    }
    Decimal result = base;
    for (int i = 0; i < exponent.abs(); i++) {
      result = exponent > 0
          ? result * factor
          : (result / factor).toDecimal(scaleOnInfinitePrecision: 8);
    }
    return result.round(scale: 4);
  }

  static Currency _currencyOf(SampleDataset dataset, String instrumentId) =>
      dataset.instruments
          .firstWhere((SampleInstrument i) => i.internalId == instrumentId)
          .instrument
          .currency;

  /// Propagates a repository failure so `Result.guardAsync` can capture it
  /// with its original type intact.
  static void _rethrowFailure(Result<void> result) {
    final Failure? failure = result.failureOrNull;
    if (failure != null) {
      throw failure;
    }
  }
}
