import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_dividend_repository.dart';
import 'package:dividendendackel/data/repositories/drift_fx_rate_repository.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_market_data_repository.dart';
import 'package:dividendendackel/data/repositories/drift_portfolio_repository.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftInstrumentRepository instruments;
  late DriftPortfolioRepository portfolio;
  late DriftDividendRepository dividends;
  late DriftFxRateRepository fxRates;
  late DriftMarketDataRepository marketData;

  final DateTime now = DateTime.utc(2026, 8, 22, 12);
  final Provenance user = Provenance.user(now);
  final Provenance fmp = Provenance(source: 'fmp', fetchedAt: now);

  const Instrument allianz = Instrument(
    internalId: 'isin:DE0008404005',
    symbol: 'ALV',
    name: 'Allianz SE',
    currency: Currency.eur,
    exchange: 'XETRA',
    mic: 'XETR',
    isin: 'DE0008404005',
    country: 'DE',
    sector: 'Financials',
    providerMappings: <ProviderMapping>[
      ProviderMapping(providerId: 'fmp', symbol: 'ALV.DE'),
    ],
  );
  const Instrument apple = Instrument(
    internalId: 'sym:AAPL@XNAS',
    symbol: 'AAPL',
    name: 'Apple Inc.',
    currency: Currency.usd,
    mic: 'XNAS',
    isin: 'US0378331005',
  );

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    instruments = DriftInstrumentRepository(db);
    portfolio = DriftPortfolioRepository(db);
    dividends = DriftDividendRepository(db);
    fxRates = DriftFxRateRepository(db);
    marketData = DriftMarketDataRepository(db);
    await instruments.save(allianz);
    await instruments.save(apple);
  });

  tearDown(() async {
    await db.close();
  });

  Holding holdingOf(String quantity, {String? averagePrice}) => Holding(
    instrumentId: allianz.internalId,
    quantity: Decimal.parse(quantity),
    averagePurchasePrice: averagePrice == null
        ? null
        : Money.parse(averagePrice, Currency.eur),
    provenance: user,
  );

  DividendEvent dividendOf({
    required String amount,
    DateTime? exDate,
    DateTime? paymentDate,
    DateTime? reportedPeriodStart,
    DateTime? reportedPeriodEnd,
    DividendStatus status = DividendStatus.confirmed,
    String instrumentId = 'isin:DE0008404005',
    Provenance? provenance,
  }) => DividendEvent(
    instrumentId: instrumentId,
    amountPerShare: Money.parse(amount, Currency.eur),
    status: status,
    exDate: exDate,
    paymentDate: paymentDate,
    reportedPeriodStart: reportedPeriodStart,
    reportedPeriodEnd: reportedPeriodEnd,
    provenance: provenance ?? fmp,
  );

  group('DriftInstrumentRepository', () {
    test('checks catalogue existence without loading mapped rows', () async {
      expect((await instruments.hasAny()).valueOrNull, isTrue);

      await db.delete(db.instruments).go();

      expect((await instruments.hasAny()).valueOrNull, isFalse);
    });

    test('watches only requested instrument identities', () async {
      await instruments.save(
        allianz.copyWith(
          internalId: 'sym:OTHER@XETR',
          symbol: 'OTHER',
          name: 'Other AG',
        ),
      );

      final List<Instrument> selected = await instruments.watchByIds(<String>{
        allianz.internalId,
      }).first;

      expect(selected.map((Instrument item) => item.internalId), <String>[
        allianz.internalId,
      ]);
      expect(await instruments.watchByIds(const <String>{}).first, isEmpty);
    });

    test('round-trips an instrument with its provider mappings', () async {
      final Result<Instrument?> result = await instruments.findById(
        allianz.internalId,
      );

      final Instrument? stored = result.valueOrNull;
      expect(stored, isNotNull);
      expect(stored!.name, 'Allianz SE');
      expect(stored.mic, 'XETR');
      expect(stored.currency, Currency.eur);
      expect(stored.symbolFor('fmp'), 'ALV.DE');
    });

    test(
      'returns null for an unknown instrument rather than failing',
      () async {
        final Result<Instrument?> result = await instruments.findById('nope');

        expect(result.isSuccess, isTrue);
        expect(result.valueOrNull, isNull);
      },
    );

    test('searches by name, symbol and ISIN, case-insensitively', () async {
      for (final String query in <String>[
        'allianz',
        'ALV',
        'de0008404005',
        'anz S',
      ]) {
        final Result<List<Instrument>> result = await instruments.search(query);
        expect(
          result.valueOrNull?.map((Instrument i) => i.internalId),
          contains(allianz.internalId),
          reason: 'query "$query"',
        );
      }
    });

    test('an empty query matches nothing rather than everything', () async {
      expect((await instruments.search('   ')).valueOrNull, isEmpty);
    });

    test('replaces provider mappings instead of accumulating them', () async {
      await instruments.save(
        allianz.copyWith(
          providerMappings: const <ProviderMapping>[
            ProviderMapping(providerId: 'finnhub', symbol: 'ALV.XETRA'),
          ],
        ),
      );

      final Instrument stored = (await instruments.findById(
        allianz.internalId,
      )).valueOrNull!;
      expect(stored.providerMappings, hasLength(1));
      expect(stored.symbolFor('fmp'), isNull);
      expect(stored.symbolFor('finnhub'), 'ALV.XETRA');
    });

    test('watches an instrument and pushes updates', () async {
      final Future<Instrument?> renamed = instruments
          .watchInstrument(allianz.internalId)
          .firstWhere((Instrument? i) => i?.name == 'Allianz');

      await instruments.save(allianz.copyWith(name: 'Allianz'));

      expect((await renamed)!.name, 'Allianz');
    });
  });

  group('DriftPortfolioRepository', () {
    test('saves and streams a holding, preserving exact quantities', () async {
      await portfolio.saveHolding(holdingOf('20.5', averagePrice: '210.00'));

      final List<Holding> held = await portfolio.watchHoldings().first;
      expect(held, hasLength(1));
      expect(held.single.quantity, Decimal.parse('20.5'));
      expect(
        held.single.averagePurchasePrice,
        Money.parse('210.00', Currency.eur),
      );
    });

    test(
      'replaces rather than duplicates a holding for the same instrument',
      () async {
        await portfolio.saveHolding(holdingOf('20'));
        await portfolio.saveHolding(holdingOf('30'));

        final List<Holding> held = await portfolio.watchHoldings().first;
        expect(held, hasLength(1));
        expect(held.single.quantity, Decimal.fromInt(30));
      },
    );

    test('updates a quantity', () async {
      await portfolio.saveHolding(holdingOf('20'));

      final Result<void> result = await portfolio.updateQuantity(
        allianz.internalId,
        Decimal.parse('12.75'),
      );

      expect(result.isSuccess, isTrue);
      expect(
        (await portfolio.watchHolding(allianz.internalId).first)!.quantity,
        Decimal.parse('12.75'),
      );
    });

    test(
      'reports a typed failure when updating a holding that is not there',
      () async {
        final Result<void> result = await portfolio.updateQuantity(
          allianz.internalId,
          Decimal.fromInt(5),
        );

        expect(result.failureOrNull, isA<NoDataFailure>());
      },
    );

    test('refuses a negative quantity', () async {
      await portfolio.saveHolding(holdingOf('20'));

      final Result<void> result = await portfolio.updateQuantity(
        allianz.internalId,
        Decimal.parse('-1'),
      );

      expect(result.failureOrNull, isA<InvalidInstrumentFailure>());
    });

    test(
      'removing a holding keeps the instrument and its market data',
      () async {
        // Vision.md §2.4: cached data stays usable, so re-adding is instant.
        await portfolio.saveHolding(holdingOf('20'));
        await dividends.saveAll(<DividendEvent>[
          dividendOf(amount: '13.80', exDate: DateTime.utc(2026, 5, 8)),
        ], idOf: (DividendEvent e) => 'alv-2026');

        await portfolio.removeHolding(allianz.internalId);

        expect(await portfolio.watchHoldings().first, isEmpty);
        expect(
          (await instruments.findById(allianz.internalId)).valueOrNull,
          isNotNull,
        );
        expect(
          await dividends.watchForInstrument(allianz.internalId).first,
          hasLength(1),
        );
      },
    );

    test('manages the watchlist', () async {
      await portfolio.addToWatchlist(
        WatchlistEntry(
          instrumentId: apple.internalId,
          addedAt: now,
          provenance: user,
        ),
      );

      expect(await portfolio.watchWatchlist().first, hasLength(1));

      await portfolio.removeFromWatchlist(apple.internalId);
      expect(await portfolio.watchWatchlist().first, isEmpty);
    });

    test(
      'combines held and watched instruments into the followed set',
      () async {
        await portfolio.saveHolding(holdingOf('20'));
        await portfolio.addToWatchlist(
          WatchlistEntry(
            instrumentId: apple.internalId,
            addedAt: now,
            provenance: user,
          ),
        );

        expect(await portfolio.watchFollowedInstrumentIds().first, <String>{
          allianz.internalId,
          apple.internalId,
        });
      },
    );

    test(
      'the followed set is empty, not stuck, when nothing is followed',
      () async {
        expect(await portfolio.watchFollowedInstrumentIds().first, isEmpty);
      },
    );
  });

  group('DriftDividendRepository', () {
    test('bounds cache-freshness reads to the newest fetched row', () async {
      await dividends.saveAll(<DividendEvent>[
        dividendOf(
          amount: '1',
          exDate: DateTime.utc(2027),
          provenance: Provenance(
            source: 'older',
            fetchedAt: now.subtract(const Duration(days: 1)),
          ),
        ),
        dividendOf(
          amount: '2',
          exDate: DateTime.utc(2025),
          provenance: Provenance(source: 'newer', fetchedAt: now),
        ),
      ], idOf: (DividendEvent event) => event.provenance.source);

      final List<DividendEvent> recent = await dividends
          .watchForInstrument(allianz.internalId, limit: 1)
          .first;

      expect(recent, hasLength(1));
      expect(recent.single.provenance.source, 'newer');
      expect(
        () => dividends.watchForInstrument(allianz.internalId, limit: 0),
        throwsRangeError,
      );
    });

    test('preserves the exact dividend amount through a round trip', () async {
      await dividends.saveAll(<DividendEvent>[
        dividendOf(amount: '13.8000', exDate: DateTime.utc(2026, 5, 8)),
      ], idOf: (DividendEvent e) => 'alv-2026');

      final DividendEvent stored =
          (await dividends.watchForInstrument(allianz.internalId).first).single;

      expect(stored.amountPerShare, Money.parse('13.80', Currency.eur));
      expect(
        stored.grossPaymentFor(Decimal.fromInt(20)),
        Money.parse('276', Currency.eur),
      );
    });

    test(
      'preserves a provider reporting period without inventing dates',
      () async {
        await dividends.saveAll(<DividendEvent>[
          dividendOf(
            amount: '0.25',
            reportedPeriodStart: DateTime.utc(2026, 1, 1),
            reportedPeriodEnd: DateTime.utc(2026, 3, 31),
          ),
        ], idOf: (_) => 'sec-period');

        final DividendEvent stored =
            (await dividends.watchForInstrument(allianz.internalId).first)
                .single;

        expect(stored.reportedPeriodStart, DateTime.utc(2026, 1, 1));
        expect(stored.reportedPeriodEnd, DateTime.utc(2026, 3, 31));
        expect(stored.exDate, isNull);
        expect(stored.declarationDate, isNull);
        expect(stored.paymentDate, isNull);
      },
    );

    test('a deterministic id updates rather than duplicating', () async {
      for (final String amount in <String>['13.80', '14.20']) {
        await dividends.saveAll(<DividendEvent>[
          dividendOf(amount: amount, exDate: DateTime.utc(2026, 5, 8)),
        ], idOf: (DividendEvent e) => 'alv-2026-05');
      }

      final List<DividendEvent> stored = await dividends
          .watchForInstrument(allianz.internalId)
          .first;
      expect(stored, hasLength(1));
      expect(stored.single.amountPerShare, Money.parse('14.20', Currency.eur));
    });

    group('range queries', () {
      setUp(() async {
        await dividends.saveAll(
          <DividendEvent>[
            dividendOf(
              amount: '13.80',
              exDate: DateTime.utc(2026, 5, 8),
              paymentDate: DateTime.utc(2026, 5, 12),
            ),
            dividendOf(
              amount: '1.00',
              exDate: DateTime.utc(2026, 8, 20),
              paymentDate: DateTime.utc(2026, 9, 2),
            ),
            // Announced, payment date not yet confirmed.
            dividendOf(
              amount: '2.00',
              exDate: DateTime.utc(2026, 5, 20),
              status: DividendStatus.announced,
            ),
          ],
          idOf: (DividendEvent e) =>
              '${e.instrumentId}-${e.amountPerShare.amount}',
        );
      });

      test('selects by ex-date when the calendar is in ex-date mode', () async {
        final List<DividendEvent> events = await dividends
            .watchInRange(
              DateRange(DateTime.utc(2026, 5), DateTime.utc(2026, 6)),
              DividendDateMode.exDate,
            )
            .first;

        expect(events, hasLength(2));
        expect(events.first.exDate, DateTime.utc(2026, 5, 8));
      });

      test('excludes events with no date for the selected mode', () async {
        // The announced dividend has no payment date; it cannot be placed on a
        // payment-date calendar and must not be given an invented one.
        final List<DividendEvent> events = await dividends
            .watchInRange(
              DateRange(DateTime.utc(2026, 5), DateTime.utc(2026, 6)),
              DividendDateMode.paymentDate,
            )
            .first;

        expect(events, hasLength(1));
        expect(events.single.paymentDate, DateTime.utc(2026, 5, 12));
      });

      test('treats the range as half-open', () async {
        final List<DividendEvent> events = await dividends
            .watchInRange(
              DateRange(DateTime.utc(2026, 5, 8), DateTime.utc(2026, 5, 20)),
              DividendDateMode.exDate,
            )
            .first;

        expect(events, hasLength(1), reason: 'start inclusive, end exclusive');
      });

      test('filters by instrument when asked', () async {
        final List<DividendEvent> events = await dividends
            .watchInRange(
              DateRange(DateTime.utc(2026), DateTime.utc(2027)),
              DividendDateMode.exDate,
              instrumentIds: <String>{apple.internalId},
            )
            .first;

        expect(events, isEmpty);
      });
    });
  });

  group('DriftMarketDataRepository', () {
    test('stores and reads a quote with its change', () async {
      await marketData.saveQuote(
        Quote(
          instrumentId: allianz.internalId,
          price: Money.parse('287.50', Currency.eur),
          previousClose: Money.parse('286.35', Currency.eur),
          asOf: now,
          provenance: fmp,
        ),
      );

      final Quote? quote = await marketData
          .watchQuote(allianz.internalId)
          .first;
      expect(quote!.price, Money.parse('287.50', Currency.eur));
      expect(quote.change, Money.parse('1.15', Currency.eur));
    });

    test(
      'emits null when no quote is cached, so the UI can stay useful',
      () async {
        expect(await marketData.watchQuote(apple.internalId).first, isNull);
      },
    );

    test('keys multiple quotes by instrument', () async {
      await marketData.saveQuote(
        Quote(
          instrumentId: allianz.internalId,
          price: Money.parse('287.50', Currency.eur),
          asOf: now,
          provenance: fmp,
        ),
      );

      final Map<String, Quote> quotes = await marketData.watchQuotes(<String>{
        allianz.internalId,
        apple.internalId,
      }).first;

      expect(quotes.keys, <String>[allianz.internalId]);
    });

    test('upserts and ranges earnings with exact optional figures', () async {
      EarningsEvent event(String estimate) => EarningsEvent(
        instrumentId: allianz.internalId,
        scheduledFor: DateTime.utc(2026, 8, 25, 20),
        status: EarningsStatus.confirmed,
        timing: EarningsTiming.afterMarketClose,
        fiscalPeriod: 'Q2 2026',
        epsEstimate: Money.parse(estimate, Currency.eur),
        provenance: fmp,
      );

      await marketData.saveEarnings(<EarningsEvent>[
        event('3.10'),
      ], idOf: (EarningsEvent _) => 'alv-q2');
      await marketData.saveEarnings(<EarningsEvent>[
        event('3.20'),
      ], idOf: (EarningsEvent _) => 'alv-q2');

      final List<EarningsEvent> stored = await marketData
          .watchEarningsInRange(
            DateRange(DateTime.utc(2026, 8, 25), DateTime.utc(2026, 8, 26)),
            instrumentIds: <String>{allianz.internalId},
          )
          .first;
      expect(stored, hasLength(1));
      expect(stored.single.epsEstimate, Money.parse('3.20', Currency.eur));
      expect(stored.single.timing, EarningsTiming.afterMarketClose);
    });

    test('rejects mixed-currency earnings figures', () async {
      final Result<void> result = await marketData.saveEarnings(<EarningsEvent>[
        EarningsEvent(
          instrumentId: allianz.internalId,
          scheduledFor: DateTime.utc(2026, 8, 25),
          status: EarningsStatus.reported,
          epsActual: Money.parse('3.20', Currency.eur),
          revenueActual: Money.parse('100', Currency.usd),
          provenance: fmp,
        ),
      ], idOf: (EarningsEvent _) => 'mixed');

      expect(result.failureOrNull, isA<ParsingFailure>());
      expect(await db.select(db.earningsEvents).get(), isEmpty);
    });

    test('returns only active company events in a half-open range', () async {
      CorporateEvent event(
        String id,
        DateTime date, {
        CorporateEventStatus status = CorporateEventStatus.confirmed,
      }) => CorporateEvent(
        id: id,
        instrumentId: allianz.internalId,
        scheduledFor: date,
        type: CorporateEventType.shareholderMeeting,
        status: status,
        title: 'Shareholder meeting',
        url: Uri.parse('https://example.test/events/$id'),
        provenance: fmp,
      );

      await marketData.saveCorporateEvents(<CorporateEvent>[
        event('inside', DateTime.utc(2026, 8, 25)),
        event(
          'completed',
          DateTime.utc(2026, 8, 25),
          status: CorporateEventStatus.completed,
        ),
        event('boundary', DateTime.utc(2026, 8, 26)),
      ]);

      final List<CorporateEvent> stored = await marketData
          .watchCorporateEventsInRange(
            DateRange(DateTime.utc(2026, 8, 25), DateTime.utc(2026, 8, 26)),
            instrumentIds: <String>{allianz.internalId},
          )
          .first;
      expect(stored, hasLength(1));
      expect(stored.single.id, 'inside');
      expect(
        stored.single.url,
        Uri.parse('https://example.test/events/inside'),
      );
    });

    test('upserts news metadata and replaces instrument links', () async {
      NewsItem item(List<String> links, NewsCategory category) => NewsItem(
        id: 'story-1',
        headline: 'Company update',
        sourceName: 'Publisher',
        publishedAt: now,
        url: Uri.parse('https://publisher.example/story-1'),
        category: category,
        summary: 'Provider-supplied short summary',
        relatedInstrumentIds: links,
        provenance: fmp,
      );

      await marketData.saveNews(<NewsItem>[
        item(<String>[
          allianz.internalId,
          apple.internalId,
        ], NewsCategory.general),
      ]);
      final Result<void> updated = await marketData.saveNews(<NewsItem>[
        item(<String>[
          apple.internalId,
          apple.internalId,
        ], NewsCategory.guidance),
      ]);

      expect(updated.isSuccess, isTrue);
      expect(
        await marketData
            .watchRecentNews(instrumentIds: <String>{allianz.internalId})
            .first,
        isEmpty,
      );
      final List<NewsItem> appleNews = await marketData
          .watchRecentNews(instrumentIds: <String>{apple.internalId})
          .first;
      expect(appleNews, hasLength(1));
      expect(appleNews.single.category, NewsCategory.guidance);
      expect(appleNews.single.relatedInstrumentIds, <String>[apple.internalId]);
      expect(
        appleNews.single.url,
        Uri.parse('https://publisher.example/story-1'),
      );
    });

    test('filters portfolio news before applying the result limit', () async {
      NewsItem item(String id, String instrumentId, int minutesAgo) => NewsItem(
        id: id,
        headline: id,
        sourceName: 'Publisher',
        publishedAt: now.subtract(Duration(minutes: minutesAgo)),
        url: Uri.parse('https://publisher.example/$id'),
        relatedInstrumentIds: <String>[instrumentId],
        provenance: fmp,
      );
      await marketData.saveNews(<NewsItem>[
        item('new-unrelated-1', apple.internalId, 1),
        item('new-unrelated-2', apple.internalId, 2),
        item('older-relevant', allianz.internalId, 3),
      ]);

      final List<NewsItem> result = await marketData
          .watchRecentNews(
            instrumentIds: <String>{allianz.internalId},
            limit: 1,
          )
          .first;

      expect(result.map((NewsItem item) => item.id), <String>[
        'older-relevant',
      ]);
    });

    test('rejects a non-web news source link', () async {
      final Result<void> result = await marketData.saveNews(<NewsItem>[
        NewsItem(
          id: 'unsafe',
          headline: 'Headline',
          sourceName: 'Publisher',
          publishedAt: now,
          url: Uri.parse('file:///private/article'),
          relatedInstrumentIds: <String>[allianz.internalId],
          provenance: fmp,
        ),
      ]);

      expect(result.failureOrNull, isA<ParsingFailure>());
      expect(await db.select(db.newsItems).get(), isEmpty);
    });

    test('upserts and reads filing metadata', () async {
      Filing filing(String title) => Filing(
        id: '0000320193-26-000001',
        instrumentId: apple.internalId,
        formType: '10-Q',
        filedAt: DateTime.utc(2026, 8, 20),
        periodOfReport: DateTime.utc(2026, 6, 30),
        title: title,
        url: Uri.parse('https://www.sec.gov/Archives/filing.htm'),
        provenance: fmp,
      );

      await marketData.saveFilings(<Filing>[filing('Quarterly report')]);
      final Result<void> result = await marketData.saveFilings(<Filing>[
        filing('Updated quarterly report'),
      ]);
      final List<Filing> stored = await marketData
          .watchRecentFilings(instrumentIds: <String>{apple.internalId})
          .first;

      expect(result.isSuccess, isTrue);
      expect(stored, hasLength(1));
      expect(stored.single.title, 'Updated quarterly report');
      expect(stored.single.periodOfReport, DateTime.utc(2026, 6, 30));
    });
  });

  group('DriftFxRateRepository', () {
    FxRate fx(String quote, String value, DateTime observedAt) => FxRate(
      base: Currency.eur,
      quote: Currency.parse(quote),
      rate: Decimal.parse(value),
      observedAt: observedAt,
      provenance: Provenance(
        source: 'frankfurter',
        fetchedAt: now,
        updatedAt: observedAt,
      ),
    );

    test(
      'round-trips exact daily rates and selects a half-open range',
      () async {
        await fxRates.saveAll(<FxRate>[
          fx('USD', '1.15', DateTime.utc(2026, 8, 10)),
          fx('GBP', '0.85', DateTime.utc(2026, 8, 10)),
          fx('USD', '1.16', DateTime.utc(2026, 8, 11)),
        ]);

        final List<FxRate> stored = await fxRates.watchInRange(
          Currency.eur,
          <Currency>{Currency.usd, Currency.gbp},
          DateRange(DateTime.utc(2026, 8, 10), DateTime.utc(2026, 8, 11)),
        ).first;

        expect(stored, hasLength(2));
        expect(stored.first.quote, Currency.gbp);
        expect(stored.last.rate, Decimal.parse('1.15'));
        expect(stored.last.provenance.source, 'frankfurter');
      },
    );

    test('returns only the newest rate for each quote', () async {
      await fxRates.saveAll(<FxRate>[
        fx('USD', '1.15', DateTime.utc(2026, 8, 10)),
        fx('GBP', '0.85', DateTime.utc(2026, 8, 10)),
        fx('USD', '1.16', DateTime.utc(2026, 8, 11)),
      ]);

      final Map<Currency, FxRate> latest = await fxRates.watchLatest(
        Currency.eur,
        <Currency>{Currency.usd, Currency.gbp},
      ).first;

      expect(latest[Currency.usd]!.rate, Decimal.parse('1.16'));
      expect(latest[Currency.gbp]!.rate, Decimal.parse('0.85'));
    });

    test('updates a duplicate pair and day instead of accumulating', () async {
      await fxRates.saveAll(<FxRate>[
        fx('USD', '1.15', DateTime.utc(2026, 8, 10)),
      ]);
      await fxRates.saveAll(<FxRate>[
        fx('USD', '1.17', DateTime.utc(2026, 8, 10)),
      ]);

      final List<FxRate> stored = await fxRates.watchInRange(
        Currency.eur,
        <Currency>{Currency.usd},
        DateRange(DateTime.utc(2026), DateTime.utc(2027)),
      ).first;

      expect(stored, hasLength(1));
      expect(stored.single.rate, Decimal.parse('1.17'));
    });
  });

  group('DateRange', () {
    test('is half-open', () {
      final DateRange range = DateRange(
        DateTime.utc(2026, 5),
        DateTime.utc(2026, 6),
      );

      expect(range.contains(DateTime.utc(2026, 5)), isTrue);
      expect(range.contains(DateTime.utc(2026, 5, 31)), isTrue);
      expect(range.contains(DateTime.utc(2026, 6)), isFalse);
    });

    test('rejects an empty or inverted range', () {
      expect(
        () => DateRange(DateTime.utc(2026, 6), DateTime.utc(2026, 5)),
        throwsArgumentError,
      );
      expect(
        () => DateRange(DateTime.utc(2026, 5), DateTime.utc(2026, 5)),
        throwsArgumentError,
      );
    });

    test('builds a day-count range', () {
      expect(
        DateRange.days(DateTime.utc(2026, 8, 22), 3).end,
        DateTime.utc(2026, 8, 25),
      );
    });
  });
}
