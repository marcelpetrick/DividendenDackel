import 'package:dividendendackel/app/app.dart';
import 'package:dividendendackel/app/navigation/app_shell.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_colors.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/settings/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(400, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        // These tests cover the shell — navigation, layout and theming — so
        // they run without a database. That keeps them hermetic and stops
        // drift's stream machinery outliving the widget tree, which the test
        // binding reports as a pending timer. The data layer has its own tests.
        overrides: [
          clockProvider.overrideWithValue(FakeClock(DateTime.utc(2026, 8, 22))),
          sampleDataProvider.overrideWith((Ref ref) async {}),
          holdingsProvider.overrideWith(
            (Ref ref) => Stream<List<Holding>>.value(const <Holding>[]),
          ),
          watchlistProvider.overrideWith(
            (Ref ref) =>
                Stream<List<WatchlistEntry>>.value(const <WatchlistEntry>[]),
          ),
          instrumentsByIdProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Instrument>>.value(
              const <String, Instrument>{},
            ),
          ),
          followedInstrumentIdsProvider.overrideWith(
            (Ref ref) => Stream<Set<String>>.value(const <String>{}),
          ),
          quotesProvider.overrideWith(
            (Ref ref) =>
                Stream<Map<String, Quote>>.value(const <String, Quote>{}),
          ),
          upcomingDividendsProvider.overrideWith(
            (Ref ref, int days) =>
                Stream<List<DividendEvent>>.value(const <DividendEvent>[]),
          ),
          // Reading the real package version needs a platform channel, which
          // a widget test has no business standing up. What matters here is
          // that the version reaches the screen.
          appVersionProvider.overrideWith(
            (Ref ref) async => const AppVersionInfo(
              version: '0.1.0',
              buildNumber: '1',
              commit: 'abc1234',
            ),
          ),
        ],
        child: const DividendenDackelApp(),
      ),
    );
    await tester.pump();
  }

  group('app shell', () {
    testWidgets('boots onto the Today screen', (WidgetTester tester) async {
      await pumpApp(tester);

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('Today'), findsWidgets);
    });

    testWidgets('uses a bottom bar on a narrow window', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, size: const Size(400, 800));

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('uses a navigation rail on a wide window', (
      WidgetTester tester,
    ) async {
      // Vision.md §25: one product that adapts, so the layout follows the
      // window size rather than the platform.
      await pumpApp(tester, size: const Size(1000, 800));

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('offers every top-level destination', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);

      for (final String label in <String>[
        'Today',
        'Calendar',
        'Portfolio',
        'Research',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });

    testWidgets('navigates between sections', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Portfolio').last);
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Portfolio'), findsWidgets);
    });

    testWidgets('reaches the data status screen', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Data status'));
      await tester.pumpAndSettle();

      expect(find.text('Data status'), findsWidgets);
      expect(find.text('Recent activity'), findsOneWidget);
    });

    testWidgets('reaches settings and about', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);

      // The version is visible in Settings itself, so checking it does not
      // require knowing to open another screen.
      expect(find.text('Version 0.1.0 (1)'), findsOneWidget);

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(find.text('DividendenDackel'), findsWidgets);
      expect(
        find.text('The dachshund that fetches your dividends.'),
        findsOneWidget,
      );
      expect(find.text('0.1.0 (1)'), findsOneWidget);
      expect(find.text('Commit: abc1234'), findsOneWidget);
    });
  });

  group('theme', () {
    test('both themes carry the semantic palette widgets rely on', () {
      // Widgets ask for meaning ("this is an estimate") rather than a raw
      // colour, so a theme missing the extension would silently fall back.
      for (final ThemeData theme in <ThemeData>[
        AppTheme.light(),
        AppTheme.dark(),
      ]) {
        expect(theme.extension<AppSemanticColors>(), isNotNull);
        expect(theme.useMaterial3, isTrue);
      }
    });

    test('light and dark resolve to different semantic colours', () {
      expect(
        AppTheme.light().extension<AppSemanticColors>()!.positive,
        isNot(AppTheme.dark().extension<AppSemanticColors>()!.positive),
      );
    });

    test('status labels never rely on colour alone', () {
      // Vision.md §27: every status must also be a word, not just a colour.
      for (final DividendStatus status in DividendStatus.values) {
        expect(DividendStatusChip.labelFor(status), isNotEmpty);
      }
    });
  });
}
