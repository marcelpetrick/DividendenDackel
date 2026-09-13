import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/journey_harness.dart';

void registerSystemJourneys() {
  // Covers route: /settings/data-sources
  // Covers route: /settings/notifications
  // Covers route: /settings/currency
  // Covers route: /about
  // Covers route: /about/changelog
  testWidgets('settings explain providers, preferences, and build identity', (
    WidgetTester tester,
  ) async {
    await JourneyHarness.start(tester, initialLocation: '/settings');

    await tester.tap(find.text('Data sources'));
    await JourneyHarness.settle(tester);
    expect(find.text('Data sources'), findsOneWidget);
    final Finder alphaVantageGuide = find.byKey(
      const ValueKey<String>('guide-alphaVantage'),
    );
    await tester.scrollUntilVisible(
      alphaVantageGuide,
      300,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 30,
    );
    await tester.tap(alphaVantageGuide);
    await JourneyHarness.settle(tester);
    expect(find.text('Setting up Alpha Vantage'), findsOneWidget);
    expect(find.textContaining('25 price requests per day'), findsOneWidget);
    Navigator.of(tester.element(find.text('Setting up Alpha Vantage'))).pop();
    await JourneyHarness.settle(tester);
    await tester.pageBack();
    await JourneyHarness.settle(tester);

    await tester.tap(find.text('Notifications'));
    await JourneyHarness.settle(tester);
    expect(find.text('Disabled'), findsOneWidget);
    expect(find.text('Important only'), findsOneWidget);
    expect(find.text('All events'), findsOneWidget);
    await tester.pageBack();
    await JourneyHarness.settle(tester);

    await tester.tap(find.text('Currency & exchange rates'));
    await JourneyHarness.settle(tester);
    expect(find.text('No exchange rate needed'), findsOneWidget);
    expect(find.textContaining('not executable broker prices'), findsOneWidget);
    await tester.pageBack();
    await JourneyHarness.settle(tester);

    final Finder about = find.text('About');
    await tester.scrollUntilVisible(
      about,
      300,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 30,
    );
    await tester.tap(about);
    await JourneyHarness.settle(tester);
    expect(find.text('DividendenDackel'), findsOneWidget);
    expect(find.text('0.0.0 (0)'), findsOneWidget);
    expect(find.text('Commit: integration-test'), findsOneWidget);

    final Finder changelog = find.byKey(
      const ValueKey<String>('about-changelog'),
    );
    await tester.scrollUntilVisible(
      changelog,
      300,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 30,
    );
    await tester.tap(changelog);
    await JourneyHarness.settle(tester);
    expect(find.text('What changed'), findsOneWidget);
    expect(find.text('In development'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // Covers route: /status
  testWidgets('data status stays useful and exports safe diagnostics', (
    WidgetTester tester,
  ) async {
    await JourneyHarness.start(tester);

    await tester.tap(find.byTooltip('Data status'));
    await JourneyHarness.settle(tester);
    expect(find.text('Data sources'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('provider-sec')), findsOneWidget);
    final Finder noActiveRequests = find.text('No active requests.');
    await tester.scrollUntilVisible(
      noActiveRequests,
      300,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 30,
    );
    expect(noActiveRequests, findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('copy-diagnostics')));
    await JourneyHarness.settle(tester);
    expect(find.textContaining('Diagnostics copied.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
