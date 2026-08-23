import 'package:dividendendackel/app/navigation/app_router.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/news/news_link_launcher.dart';
import 'package:dividendendackel/features/research/research_detail_screen.dart';
import 'package:dividendendackel/features/research/research_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  testWidgets(
    'opens a complete cached research detail from the instrument list',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final DateTime now = DateTime.utc(2026, 8, 23, 12);
      final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
      const Instrument instrument = Instrument(
        internalId: 'isin:DE0008404005',
        symbol: 'ALV',
        name: 'Allianz SE',
        currency: Currency.eur,
        mic: 'XETR',
        isin: 'DE0008404005',
        country: 'DE',
        sector: 'Financials',
      );
      ScoredAssessment assessment(
        int score,
        String summary,
        List<ScoreFactor> factors,
      ) => ScoredAssessment(score: score, summary: summary, factors: factors);
      final ScoredAssessment dividendScore = assessment(
        80,
        'Strong dividend evidence among available metrics.',
        <ScoreFactor>[
          ScoreFactor(
            label: 'No cut in 8 years',
            impact: FactorImpact.positive,
          ),
        ],
      );
      final ScoredAssessment eventScore = assessment(
        40,
        'Material event risk among available metrics.',
        <ScoreFactor>[
          ScoreFactor(
            label: 'Earnings are due in 5 days',
            impact: FactorImpact.negative,
          ),
        ],
      );
      final ResearchSnapshot snapshot = ResearchSnapshot(
        instrumentId: instrument.internalId,
        takenAt: now,
        overall: assessment(
          67,
          'Available evidence is mixed. Based on 2 of 6 dimensions; missing dimensions are omitted.',
          <ScoreFactor>[
            ScoreFactor(
              label: 'Dividend 80/100',
              impact: FactorImpact.positive,
            ),
            ScoreFactor(
              label: 'Event risk 40/100',
              impact: FactorImpact.neutral,
            ),
          ],
        ),
        dimensions: <ResearchDimension, ScoredAssessment>{
          ResearchDimension.dividend: dividendScore,
          ResearchDimension.eventRisk: eventScore,
        },
        provenance: provenance,
      );
      final DividendEvent dividend = DividendEvent(
        instrumentId: instrument.internalId,
        amountPerShare: Money.parse('13.80', Currency.eur),
        status: DividendStatus.confirmed,
        paymentDate: now.add(const Duration(days: 40)),
        provenance: provenance,
      );
      final EarningsEvent earnings = EarningsEvent(
        instrumentId: instrument.internalId,
        scheduledFor: now.add(const Duration(days: 5)),
        status: EarningsStatus.confirmed,
        timing: EarningsTiming.beforeMarketOpen,
        provenance: provenance,
      );
      final CorporateEvent companyEvent = CorporateEvent(
        id: 'event',
        instrumentId: instrument.internalId,
        scheduledFor: now.add(const Duration(days: 20)),
        type: CorporateEventType.investorDay,
        status: CorporateEventStatus.confirmed,
        title: 'Capital markets day',
        provenance: provenance,
      );
      final NewsItem news = NewsItem(
        id: 'news',
        headline: 'Dividend policy updated',
        sourceName: 'Publisher',
        publishedAt: now.subtract(const Duration(hours: 2)),
        url: Uri.parse('https://publisher.example/story'),
        category: NewsCategory.dividends,
        relatedInstrumentIds: const <String>['isin:DE0008404005'],
        provenance: provenance,
      );
      final Filing filing = Filing(
        id: 'filing',
        instrumentId: instrument.internalId,
        formType: '8-K',
        filedAt: now.subtract(const Duration(days: 2)),
        url: Uri.parse('https://publisher.example/filing'),
        title: 'Material report',
        provenance: provenance,
      );
      final _Launcher launcher = _Launcher();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            clockProvider.overrideWithValue(FakeClock(now)),
            instrumentsByIdProvider.overrideWith(
              (Ref ref) => Stream<Map<String, Instrument>>.value(
                const <String, Instrument>{'isin:DE0008404005': instrument},
              ),
            ),
            researchInstrumentProvider.overrideWith(
              (Ref ref, String id) => Stream<Instrument?>.value(instrument),
            ),
            researchQuoteProvider.overrideWith(
              (Ref ref, String id) => Stream<Quote?>.value(
                Quote(
                  instrumentId: id,
                  price: Money.parse('287.50', Currency.eur),
                  previousClose: Money.parse('286.35', Currency.eur),
                  asOf: now,
                  provenance: provenance,
                ),
              ),
            ),
            researchDividendHistoryProvider.overrideWith(
              (Ref ref, String id) =>
                  Stream<List<DividendEvent>>.value(<DividendEvent>[dividend]),
            ),
            researchEarningsProvider.overrideWith(
              (Ref ref, String id) =>
                  Stream<List<EarningsEvent>>.value(<EarningsEvent>[earnings]),
            ),
            researchCorporateEventsProvider.overrideWith(
              (Ref ref, String id) => Stream<List<CorporateEvent>>.value(
                <CorporateEvent>[companyEvent],
              ),
            ),
            researchNewsProvider.overrideWith(
              (Ref ref, String id) =>
                  Stream<List<NewsItem>>.value(<NewsItem>[news]),
            ),
            researchFilingsProvider.overrideWith(
              (Ref ref, String id) =>
                  Stream<List<Filing>>.value(<Filing>[filing]),
            ),
            currentResearchSnapshotProvider.overrideWith(
              (Ref ref, String id) async => snapshot,
            ),
            researchHistoryProvider.overrideWith(
              (Ref ref, String id) => Stream<List<ResearchSnapshot>>.value(
                <ResearchSnapshot>[snapshot],
              ),
            ),
            newsLinkLauncherProvider.overrideWithValue(launcher),
          ],
          child: MaterialApp.router(
            routerConfig: buildRouter(initialLocation: '/research'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Research'), findsWidgets);
      expect(find.text('Allianz SE'), findsOneWidget);
      await tester.tap(find.text('Allianz SE'));
      await tester.pumpAndSettle();

      expect(find.text('Price overview'), findsOneWidget);
      expect(find.text('€287.50'), findsOneWidget);
      expect(find.text('67 / 100'), findsOneWidget);
      expect(
        find.text('Research context only — not a recommendation.'),
        findsOneWidget,
      );
      expect(find.text('Not enough cached evidence'), findsNWidgets(4));

      await tester.scrollUntilVisible(find.text('Fundamentals'), 500);
      expect(
        find.textContaining('unavailable from configured sources'),
        findsNWidgets(4),
      );
      await tester.scrollUntilVisible(
        find.text('Upcoming events and earnings'),
        500,
      );
      expect(find.textContaining('Earnings ·'), findsOneWidget);
      expect(find.text('Capital markets day'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Dividend history'), 500);
      expect(find.text('€13.80'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('News and filings'), 500);
      expect(find.text('Dividend policy updated'), findsOneWidget);
      expect(find.text('Material report'), findsOneWidget);
      await tester.tap(find.byTooltip('Open original'));
      await tester.pump();
      expect(launcher.opened, <Uri>[
        Uri.parse('https://publisher.example/story'),
      ]);
      await tester.scrollUntilVisible(
        find.text('Bull case and bear case'),
        500,
      );
      expect(find.text('No cut in 8 years'), findsOneWidget);
      expect(find.text('Earnings are due in 5 days'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('What would change the assessment?'),
        500,
      );
      expect(
        find.textContaining('Conditions from the scoring model'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(find.text('Research-score history'), 500);
      expect(find.text('67 / 100'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows an explicit state when the instrument no longer exists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          researchInstrumentProvider.overrideWith(
            (Ref ref, String id) => Stream<Instrument?>.value(null),
          ),
        ],
        child: const MaterialApp(
          home: ResearchDetailScreen(instrumentId: 'missing'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Instrument not found'), findsOneWidget);
    expect(
      find.textContaining('removed from the local database'),
      findsOneWidget,
    );
  });
}

final class _Launcher implements NewsLinkLauncher {
  final List<Uri> opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }
}
