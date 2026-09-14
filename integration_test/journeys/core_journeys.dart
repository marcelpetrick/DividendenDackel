import 'package:dividendendackel/features/portfolio/add_instrument_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/journey_harness.dart';

void registerCoreJourneys() {
  // Covers route: /today
  // Covers route: /portfolio/add
  testWidgets('first run reaches an honest empty Today screen', (
    WidgetTester tester,
  ) async {
    final JourneyHarness harness = await JourneyHarness.start(
      tester,
      onboarded: false,
    );

    expect(find.text('Your portfolio stays on this device'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await JourneyHarness.settle(tester);
    expect(find.text('Follow only what matters to you'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await JourneyHarness.settle(tester);
    expect(find.text('Facts keep their context'), findsOneWidget);
    await tester.tap(find.text('Go to Today'));
    await JourneyHarness.settle(tester);

    expect(harness.onboarding.completeValue, isTrue);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('0 holdings'), findsOneWidget);
    expect(find.textContaining('No cached quotes'), findsOneWidget);
    expect(find.text('Start with your portfolio'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('add-first-holding')));
    await JourneyHarness.settle(tester);
    expect(find.byType(AddInstrumentDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Covers route: /portfolio
  testWidgets('adds German holdings through the real portfolio flow', (
    WidgetTester tester,
  ) async {
    final JourneyHarness harness = await JourneyHarness.start(tester);
    await harness.openDestination(tester, 'Portfolio');

    await harness.addHolding(
      tester,
      query: 'ALV',
      name: 'Allianz SE',
      isin: 'DE0008404005',
      quantity: '8',
      averagePrice: '350',
    );
    await harness.addHolding(
      tester,
      query: 'MUV2',
      name: 'Münchener Rückversicherungs-Gesellschaft AG',
      isin: 'DE0008430026',
      quantity: '3',
      averagePrice: '420',
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('adds a US holding beside a German holding', (
    WidgetTester tester,
  ) async {
    final JourneyHarness harness = await JourneyHarness.start(tester);
    await harness.openDestination(tester, 'Portfolio');
    await harness.addHolding(
      tester,
      query: 'ALV',
      name: 'Allianz SE',
      isin: 'DE0008404005',
    );
    await harness.addHolding(
      tester,
      query: 'MSFT',
      name: 'Microsoft Corporation',
      isin: 'US5949181045',
      averagePrice: '180',
    );

    expect(await harness.holdingCurrencyCodes(), <String>{'EUR', 'USD'});
    expect(tester.takeException(), isNull);
  });

  for (final JourneyQuoteMode mode in JourneyQuoteMode.values) {
    testWidgets('valuation is honest when prices are ${mode.name}', (
      WidgetTester tester,
    ) async {
      final JourneyHarness harness = await JourneyHarness.start(
        tester,
        quoteMode: mode,
      );
      await harness.openDestination(tester, 'Portfolio');
      await harness.addHolding(
        tester,
        query: 'ALV',
        name: 'Allianz SE',
        isin: 'DE0008404005',
        quantity: '2',
        averagePrice: '90',
      );
      await harness.refresh(tester);
      await harness.openDestination(tester, 'Today');

      if (mode == JourneyQuoteMode.available) {
        expect(find.text('€200.00'), findsOneWidget);
        expect(find.textContaining('today'), findsWidgets);
        expect(find.textContaining('No cached quotes'), findsNothing);
      } else {
        expect(find.textContaining('No cached quotes'), findsOneWidget);
        expect(
          find.textContaining('saved data remains visible'),
          findsOneWidget,
        );
      }
      expect(find.text('1 holding'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
