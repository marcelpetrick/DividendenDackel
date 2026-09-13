import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/journey_harness.dart';

void registerFinancialJourneys() {
  // Covers route: /settings
  // Covers route: /settings/tax
  testWidgets('tax and currency keep gross, net, and source units visible', (
    WidgetTester tester,
  ) async {
    final JourneyHarness harness = await JourneyHarness.start(
      tester,
      quoteMode: JourneyQuoteMode.available,
    );
    await harness.openDestination(tester, 'Portfolio');
    await harness.addHolding(
      tester,
      query: 'MSFT',
      name: 'Microsoft Corporation',
      isin: 'US5949181045',
      quantity: '10',
      averagePrice: '180',
    );
    await harness.refresh(tester);
    await harness.openDestination(tester, 'Calendar');
    await tester.tap(find.text('Agenda'));
    await JourneyHarness.settle(tester);

    final Finder payment = find
        .byKey(const ValueKey<String>('held-payment'))
        .first;
    await tester.scrollUntilVisible(
      payment,
      300,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 30,
    );
    await JourneyHarness.settle(tester);
    expect(
      find.descendant(of: payment, matching: find.textContaining('Gross')),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: payment,
        matching: find.textContaining('Net (estimated)'),
      ),
      findsWidgets,
    );
    expect(find.textContaining('USD'), findsWidgets);

    await tester.tap(find.byTooltip('Settings'));
    await JourneyHarness.settle(tester);
    await tester.tap(find.text('Dividend tax estimate'));
    await JourneyHarness.settle(tester);
    expect(find.textContaining('Estimate only'), findsOneWidget);
    expect(find.text('Annual savings allowance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Covers route: /research
  // Covers route: /research/:instrumentId
  testWidgets('research exposes score reasoning and dividend growth periods', (
    WidgetTester tester,
  ) async {
    final JourneyHarness harness = await JourneyHarness.start(
      tester,
      quoteMode: JourneyQuoteMode.available,
    );
    await harness.openDestination(tester, 'Portfolio');
    await harness.addHolding(
      tester,
      query: 'ALV',
      name: 'Allianz SE',
      isin: 'DE0008404005',
      quantity: '4',
      averagePrice: '90',
    );
    await harness.seedReportedAnnualDividends(
      'isin:DE0008404005',
      Currency.eur,
    );
    await harness.refresh(tester);
    await harness.openDestination(tester, 'Research');
    await tester.tap(find.text('Allianz SE'));
    await JourneyHarness.settle(tester);

    expect(find.text('Research score'), findsOneWidget);
    expect(
      find.text('Research context only — not a recommendation.'),
      findsOneWidget,
    );
    final Finder history = find.text('Dividend history');
    await tester.scrollUntilVisible(
      history,
      300,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 30,
    );
    await JourneyHarness.settle(tester);
    expect(history, findsOneWidget);
    expect(find.textContaining('CAGR'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
