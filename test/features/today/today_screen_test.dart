import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/calendar/calendar_state.dart';
import 'package:dividendendackel/features/news/news_link_launcher.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:dividendendackel/features/today/today_screen.dart';
import 'package:dividendendackel/features/today/today_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  testWidgets('shows held dividends as separate gross and estimated net', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.utc(2026, 8, 23);
    final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
    const Instrument instrument = Instrument(
      internalId: 'de',
      symbol: 'DE',
      name: 'German share',
      currency: Currency.eur,
      country: 'DE',
    );
    final Holding holding = Holding(
      instrumentId: 'de',
      quantity: Decimal.fromInt(10),
      provenance: provenance,
    );
    final DividendEvent event = DividendEvent(
      instrumentId: 'de',
      amountPerShare: Money.parse('2', Currency.eur),
      status: DividendStatus.announced,
      exDate: now.add(const Duration(days: 1)),
      paymentDate: now.add(const Duration(days: 2)),
      provenance: provenance,
    );
    final EarningsEvent earnings = EarningsEvent(
      instrumentId: 'de',
      scheduledFor: now.add(const Duration(days: 1)),
      status: EarningsStatus.confirmed,
      timing: EarningsTiming.afterMarketClose,
      provenance: provenance,
    );
    final CorporateEvent companyEvent = CorporateEvent(
      id: 'event-1',
      instrumentId: 'de',
      scheduledFor: now.add(const Duration(days: 2)),
      type: CorporateEventType.investorDay,
      status: CorporateEventStatus.estimated,
      title: 'Capital markets day',
      provenance: provenance,
    );
    final NewsItem news = NewsItem(
      id: 'news-1',
      headline: 'Dividend policy updated',
      sourceName: 'Original Publisher',
      publishedAt: now.subtract(const Duration(hours: 2)),
      url: Uri.parse('https://publisher.example/story'),
      category: NewsCategory.dividends,
      summary: 'This provider summary must not be republished.',
      relatedInstrumentIds: const <String>['de'],
      provenance: provenance,
    );
    final _NewsLauncher launcher = _NewsLauncher();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(FakeClock(now)),
          taxSettingsStoreProvider.overrideWithValue(_TaxStore()),
          holdingsProvider.overrideWith(
            (Ref ref) => Stream<List<Holding>>.value(<Holding>[holding]),
          ),
          watchlistProvider.overrideWith(
            (Ref ref) =>
                Stream<List<WatchlistEntry>>.value(const <WatchlistEntry>[]),
          ),
          quotesProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Quote>>.value(<String, Quote>{
              'de': Quote(
                instrumentId: 'de',
                price: Money.parse('100', Currency.eur),
                previousClose: Money.parse('99', Currency.eur),
                asOf: now,
                provenance: provenance,
              ),
            }),
          ),
          instrumentsByIdProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Instrument>>.value(
              const <String, Instrument>{'de': instrument},
            ),
          ),
          upcomingDividendsProvider.overrideWith(
            (Ref ref, int days) =>
                Stream<List<DividendEvent>>.value(<DividendEvent>[event]),
          ),
          upcomingDividendPaymentsProvider.overrideWith(
            (Ref ref, int days) =>
                Stream<List<DividendEvent>>.value(<DividendEvent>[event]),
          ),
          upcomingEarningsProvider.overrideWith(
            (Ref ref, int days) =>
                Stream<List<EarningsEvent>>.value(<EarningsEvent>[earnings]),
          ),
          upcomingCorporateEventsProvider.overrideWith(
            (Ref ref, int days) => Stream<List<CorporateEvent>>.value(
              <CorporateEvent>[companyEvent],
            ),
          ),
          recentPortfolioNewsProvider.overrideWith(
            (Ref ref) => Stream<List<NewsItem>>.value(<NewsItem>[news]),
          ),
          newsLinkLauncherProvider.overrideWithValue(launcher),
          todaySnapshotStoreProvider.overrideWithValue(_SnapshotStore()),
          calendarEventsProvider.overrideWith(
            (Ref ref, CalendarEventsQuery query) =>
                Stream<List<DividendEvent>>.value(<DividendEvent>[event]),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TodayScreen())),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Gross €20.00'), findsWidgets);
    expect(find.text('Net (estimated) €20.00'), findsWidgets);
    expect(find.textContaining('not tax advice'), findsWidgets);
    expect(find.text('Today matters'), findsOneWidget);
    expect(find.textContaining('Ex-dividend tomorrow'), findsOneWidget);
    expect(find.textContaining('Earnings tomorrow'), findsOneWidget);
    expect(find.text('After market close'), findsWidgets);
    expect(find.textContaining('Capital markets day in 2 days'), findsWidgets);
    expect(find.text('Dividend policy updated'), findsOneWidget);
    expect(find.textContaining('Original Publisher ·'), findsOneWidget);
    expect(find.text('Dividends'), findsOneWidget);
    expect(find.textContaining('Why: Held position'), findsNWidgets(5));
    expect(
      find.bySemanticsLabel(RegExp(r'Relevance score \d+ out of 100')),
      findsNWidgets(5),
    );
    expect(
      find.text('This provider summary must not be republished.'),
      findsNothing,
    );
    await tester.tap(find.text('Open original'));
    await tester.pump();
    expect(launcher.opened, <Uri>[
      Uri.parse('https://publisher.example/story'),
    ]);
    await tester.scrollUntilVisible(find.text('Next 3 days'), 300);
    expect(find.text('Next 3 days'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Upcoming company events · 30 days'),
      300,
    );
    expect(find.text('Upcoming company events · 30 days'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Next 365 days'), 300);
    expect(find.text('Next 365 days'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Changes since last refresh'),
      300,
    );
    expect(find.textContaining('Baseline saved'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stays useful without quotes and shows refresh changes', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.utc(2026, 8, 23);
    final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
    final Holding holding = Holding(
      instrumentId: 'de',
      quantity: Decimal.one,
      provenance: provenance,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(FakeClock(now)),
          holdingsProvider.overrideWith(
            (Ref ref) => Stream<List<Holding>>.value(<Holding>[holding]),
          ),
          watchlistProvider.overrideWith(
            (Ref ref) =>
                Stream<List<WatchlistEntry>>.value(const <WatchlistEntry>[]),
          ),
          instrumentsByIdProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Instrument>>.value(
              const <String, Instrument>{
                'de': Instrument(
                  internalId: 'de',
                  symbol: 'DE',
                  name: 'German share',
                  currency: Currency.eur,
                ),
              },
            ),
          ),
          quotesProvider.overrideWith(
            (Ref ref) =>
                Stream<Map<String, Quote>>.value(const <String, Quote>{}),
          ),
          upcomingDividendsProvider.overrideWith(
            (Ref ref, int days) =>
                Stream<List<DividendEvent>>.value(const <DividendEvent>[]),
          ),
          upcomingDividendPaymentsProvider.overrideWith(
            (Ref ref, int days) =>
                Stream<List<DividendEvent>>.value(const <DividendEvent>[]),
          ),
          upcomingEarningsProvider.overrideWith(
            (Ref ref, int days) =>
                Stream<List<EarningsEvent>>.value(const <EarningsEvent>[]),
          ),
          upcomingCorporateEventsProvider.overrideWith(
            (Ref ref, int days) =>
                Stream<List<CorporateEvent>>.value(const <CorporateEvent>[]),
          ),
          todayChangesProvider.overrideWith(
            (Ref ref) async => TodayChanges(
              previousAt: now.subtract(const Duration(hours: 1)),
              holdingChanges: 1,
              dividendChanges: 2,
              quoteChanges: 0,
            ),
          ),
          recentPortfolioNewsProvider.overrideWith(
            (Ref ref) => Stream<List<NewsItem>>.value(const <NewsItem>[]),
          ),
          newsLinkLauncherProvider.overrideWithValue(_NewsLauncher()),
        ],
        child: const MaterialApp(home: Scaffold(body: TodayScreen())),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('No cached quotes'), findsOneWidget);
    expect(
      find.text('No relevant portfolio events or headlines are cached.'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Changes since last refresh'),
      300,
    );
    expect(find.text('1 holding change(s)'), findsOneWidget);
    expect(find.text('2 dividend-outlook change(s)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final class _NewsLauncher implements NewsLinkLauncher {
  final List<Uri> opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }
}

final class _SnapshotStore implements TodaySnapshotStore {
  TodaySnapshot? value;

  @override
  Future<TodaySnapshot?> load() async => value;

  @override
  Future<void> save(TodaySnapshot snapshot) async => value = snapshot;
}

final class _TaxStore implements TaxSettingsStore {
  @override
  Future<TaxSettings> load(WithholdingRateTable defaults) async =>
      TaxSettings(profile: DividendTaxProfile(), table: defaults);

  @override
  Future<void> save(TaxSettings settings) async {}
}
