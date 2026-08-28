import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_dividend_repository.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_market_data_repository.dart';
import 'package:dividendendackel/data/repositories/drift_portfolio_repository.dart';
import 'package:dividendendackel/data/sample/sample_data_seeder.dart';
import 'package:dividendendackel/data/sample/sample_dataset.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  late SampleDataset dataset;

  setUpAll(() {
    // Read the shipped asset directly: this is the file the app bundles, so
    // testing a copy would not prove the shipped one is valid.
    dataset = SampleDataset.parse(
      File(SampleDataset.assetPath).readAsStringSync(),
    );
  });

  group('SampleDataset', () {
    test('parses the bundled asset', () {
      expect(dataset.instruments, hasLength(10));
      expect(dataset.dividendPatterns, hasLength(10));
      expect(dataset.earningsPatterns, hasLength(10));
      expect(dataset.corporateEventPatterns, isNotEmpty);
      expect(dataset.portfolio, isNotEmpty);
      expect(dataset.watchlist, isNotEmpty);
      expect(dataset.news, isNotEmpty);
    });

    test('every reference resolves to a known instrument', () {
      // A typo here would silently produce an empty calendar.
      expect(dataset.isReferentiallyComplete, isTrue);
    });

    test('covers annual, quarterly and monthly payers', () {
      final Set<DividendFrequency> frequencies = dataset.dividendPatterns
          .map((SampleDividendPattern p) => p.frequency)
          .toSet();

      expect(
        frequencies,
        containsAll(<DividendFrequency>[
          DividendFrequency.annual,
          DividendFrequency.quarterly,
          DividendFrequency.monthly,
        ]),
      );
    });

    test('covers more than one currency, exercising the currency rules', () {
      expect(
        dataset.instruments
            .map((SampleInstrument i) => i.instrument.currency)
            .toSet()
            .length,
        greaterThan(1),
      );
    });

    test('ships explicit SEC CIK mappings for US sample identities', () {
      final List<SampleInstrument> usInstruments = dataset.instruments
          .where((SampleInstrument item) => item.instrument.country == 'US')
          .toList(growable: false);

      expect(usInstruments, isNotEmpty);
      for (final SampleInstrument item in usInstruments) {
        final ProviderMapping mapping = item.instrument.providerMappings
            .singleWhere(
              (ProviderMapping candidate) => candidate.providerId == 'sec',
            );
        expect(mapping.providerInstrumentId, matches(RegExp(r'^\d{10}$')));
      }
    });

    test('splits the annual amount across the payment anchors', () {
      final SampleDividendPattern quarterly = dataset.dividendPatterns
          .firstWhere(
            (SampleDividendPattern p) =>
                p.frequency == DividendFrequency.quarterly,
          );

      expect(quarterly.anchors, hasLength(4));
      expect(
        quarterly.amountPerPayment * Decimal.fromInt(4),
        quarterly.currentAnnualAmount,
      );
    });

    test('rejects malformed data loudly', () {
      expect(
        () => SampleDataset.parse('{"instruments": "not a list"}'),
        throwsA(isA<ParsingFailure>()),
      );
      expect(
        () => SampleDataset.parse('not json at all'),
        throwsA(isA<ParsingFailure>()),
      );
    });
  });

  group('MonthDay', () {
    test('parses and renders MM-DD', () {
      expect(MonthDay.parse('05-08'), const MonthDay(5, 8));
      expect(const MonthDay(5, 8).toString(), '05-08');
    });

    test('clamps to the length of the month', () {
      // 02-30 is not a date; the anchor must not roll into March.
      expect(const MonthDay(2, 30).inYear(2027), DateTime.utc(2027, 2, 28));
      expect(const MonthDay(2, 29).inYear(2028), DateTime.utc(2028, 2, 29));
    });

    test('rejects malformed input', () {
      for (final String raw in <String>['', '13-01', '05', 'xx-yy', '05-00']) {
        expect(
          () => MonthDay.parse(raw),
          throwsA(isA<ParsingFailure>()),
          reason: raw,
        );
      }
    });
  });

  group('SampleDataSeeder.buildDividendEvents', () {
    final DateTime now = DateTime.utc(2026, 8, 22);
    final Provenance provenance = Provenance.sample(now);

    SampleDividendPattern patternFor(DividendFrequency frequency) => dataset
        .dividendPatterns
        .firstWhere((SampleDividendPattern p) => p.frequency == frequency);

    test('generates history and a forward projection', () {
      final SampleDividendPattern pattern = patternFor(
        DividendFrequency.annual,
      );
      final List<DividendEvent> events = SampleDataSeeder.buildDividendEvents(
        pattern,
        now: now,
        provenance: provenance,
      );

      final Set<int> years = events
          .map((DividendEvent e) => e.exDate!.year)
          .toSet();
      expect(years, contains(now.year - pattern.historyYears));
      expect(years, contains(now.year + SampleDataSeeder.forecastYears));
    });

    test('the bundled dataset carries no price for any real company', () {
      // The report that started this: Allianz showed 287.50 against a real
      // 451, because the file bundled an invented price and the seeder stamped
      // it `asOf: now`. The fields are gone, so it cannot come back by
      // accident.
      final String raw = File('assets/sample/dataset.json').readAsStringSync();
      expect(raw.contains('"price"'), isFalse);
      expect(raw.contains('"previousClose"'), isFalse);
    });

    test('no sample payment is ever confirmed, however far in the past', () {
      final List<DividendEvent> events = SampleDataSeeder.buildDividendEvents(
        patternFor(DividendFrequency.quarterly),
        now: now,
        provenance: provenance,
      );

      final DividendEvent past = events.firstWhere(
        (DividendEvent e) => e.exDate!.isBefore(now),
      );
      final DividendEvent distant = events.firstWhere(
        (DividendEvent e) =>
            e.exDate!.difference(now) > const Duration(days: 200),
      );

      // The amounts are invented. Calling a past one confirmed asserts that
      // a real company paid a figure it never paid.
      expect(past.status, DividendStatus.historicallyEstimated);
      expect(past.isEstimate, isTrue);
      expect(distant.status, DividendStatus.historicallyEstimated);
      expect(distant.isEstimate, isTrue);
      expect(distant.provenance.confidence, Confidence.low);
    });

    test('an imminent payment is announced rather than merely estimated', () {
      final List<DividendEvent> events = SampleDataSeeder.buildDividendEvents(
        patternFor(DividendFrequency.monthly),
        now: now,
        provenance: provenance,
      );

      final Iterable<DividendEvent> soon = events.where(
        (DividendEvent e) =>
            e.exDate!.isAfter(now) &&
            e.exDate!.difference(now) <= SampleDataSeeder.announcedWindow,
      );

      expect(soon, isNotEmpty);
      expect(
        soon.every((DividendEvent e) => e.status == DividendStatus.announced),
        isTrue,
      );
    });

    test('history grows, so the generated series has a real CAGR', () {
      final SampleDividendPattern pattern = patternFor(
        DividendFrequency.annual,
      );
      final List<DividendEvent> events =
          SampleDataSeeder.buildDividendEvents(
            pattern,
            now: now,
            provenance: provenance,
          )..sort(
            (DividendEvent a, DividendEvent b) =>
                a.exDate!.compareTo(b.exDate!),
          );

      // A flat series would make dividend CAGR untestable and the forecast
      // meaningless, so the generator must actually apply the growth rate.
      expect(
        events.last.amountPerShare.amount,
        greaterThan(events.first.amountPerShare.amount),
      );
    });

    test('a monthly payer produces twelve payments a year', () {
      final List<DividendEvent> events = SampleDataSeeder.buildDividendEvents(
        patternFor(DividendFrequency.monthly),
        now: now,
        provenance: provenance,
      );

      expect(
        events.where((DividendEvent e) => e.exDate!.year == now.year),
        hasLength(12),
      );
    });

    test('payment dates follow their ex-dates', () {
      final List<DividendEvent> events = SampleDataSeeder.buildDividendEvents(
        patternFor(DividendFrequency.quarterly),
        now: now,
        provenance: provenance,
      );

      expect(
        events.every((DividendEvent e) => e.paymentDate!.isAfter(e.exDate!)),
        isTrue,
      );
    });

    test('event ids are stable, so re-seeding updates in place', () {
      final SampleDividendPattern pattern = patternFor(
        DividendFrequency.annual,
      );
      List<String> idsFrom() => SampleDataSeeder.buildDividendEvents(
        pattern,
        now: now,
        provenance: provenance,
      ).map(SampleDataSeeder.dividendEventId).toList();

      expect(idsFrom(), idsFrom());
      expect(idsFrom().toSet(), hasLength(idsFrom().length));
    });
  });

  group('SampleDataSeeder.seed', () {
    late AppDatabase db;
    late SampleDataSeeder seeder;
    late DriftPortfolioRepository portfolio;
    late DriftDividendRepository dividends;
    late DriftMarketDataRepository marketData;
    late DriftInstrumentRepository instruments;
    final FakeClock clock = FakeClock(DateTime.utc(2026, 8, 22));

    setUp(() {
      db = AppDatabase.withExecutor(NativeDatabase.memory());
      instruments = DriftInstrumentRepository(db);
      portfolio = DriftPortfolioRepository(db);
      dividends = DriftDividendRepository(db);
      marketData = DriftMarketDataRepository(db);
      seeder = SampleDataSeeder(
        instruments: instruments,
        portfolio: portfolio,
        dividends: dividends,
        marketData: marketData,
        clock: clock,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('populates instruments, dividends, events and the portfolio '
        'but never a quote', () async {
      expect((await seeder.seed(dataset)).isSuccess, isTrue);

      expect(await instruments.watchAll().first, hasLength(10));
      expect(await portfolio.watchHoldings().first, hasLength(7));
      expect(await portfolio.watchWatchlist().first, hasLength(3));
      // Vision.md §79: the bundled prices are invented and these are real
      // companies, so no price is seeded at all. Metadata still is, which is
      // what keeps the instrument discoverable offline.
      expect(await marketData.watchQuote('isin:DE0008404005').first, isNull);
      expect(
        await marketData
            .watchEarningsInRange(
              DateRange(DateTime.utc(2026), DateTime.utc(2028)),
            )
            .first,
        isNotEmpty,
      );
      final List<NewsItem> news = await marketData
          .watchRecentNews(instrumentIds: <String>{'isin:DE0008404005'})
          .first;
      expect(news, isNotEmpty);
      expect(news.single.category, NewsCategory.dividends);
      expect(news.single.provenance.source, Provenance.sampleSource);
      expect(news.single.url.host, 'github.com');
      expect(
        await marketData
            .watchCorporateEventsInRange(
              DateRange(DateTime.utc(2026, 8, 22), DateTime.utc(2028)),
            )
            .first,
        isNotEmpty,
      );
    });

    test('marks everything it writes as sample data', () async {
      await seeder.seed(dataset);

      final List<Holding> holdings = await portfolio.watchHoldings().first;
      expect(
        holdings.every(
          (Holding h) => h.provenance.source == Provenance.sampleSource,
        ),
        isTrue,
      );
    });

    test('gives the calendar upcoming events relative to today', () async {
      await seeder.seed(dataset);

      final List<DividendEvent> next90 = await dividends
          .watchInRange(
            DateRange.days(clock.now(), 90),
            DividendDateMode.exDate,
          )
          .first;

      expect(next90, isNotEmpty);
    });

    test(
      'is idempotent, so re-seeding does not duplicate the calendar',
      () async {
        await seeder.seed(dataset);
        final int first =
            (await dividends.watchForInstrument('isin:DE0008404005').first)
                .length;

        await seeder.seed(dataset);
        final int second =
            (await dividends.watchForInstrument('isin:DE0008404005').first)
                .length;

        expect(second, first);
        expect(await portfolio.watchHoldings().first, hasLength(7));
      },
    );

    test('can refresh reference data without touching the portfolio', () async {
      await seeder.seed(dataset, includePortfolio: false);

      expect(await instruments.watchAll().first, hasLength(10));
      expect(await portfolio.watchHoldings().first, isEmpty);
    });

    test('a seeded holding has no price, so its value is unavailable '
        'rather than invented', () async {
      await seeder.seed(dataset);

      final Holding allianz = (await portfolio.watchHoldings().first)
          .firstWhere((Holding h) => h.instrumentId == 'isin:DE0008404005');

      expect(allianz.quantity, Decimal.fromInt(20));
      // A user checked Allianz against the market and found the seeded
      // 287.50 against a real 451. An absent value is recoverable; a
      // confident wrong one is not.
      expect(await marketData.watchQuote('isin:DE0008404005').first, isNull);
    });
  });
}
