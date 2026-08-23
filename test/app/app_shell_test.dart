import 'package:dividendendackel/app/app.dart';
import 'package:dividendendackel/app/navigation/app_shell.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_colors.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/theme/theme_preference.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/calendar/calendar_state.dart';
import 'package:dividendendackel/features/calendar/forecast_state.dart';
import 'package:dividendendackel/features/settings/about_screen.dart';
import 'package:dividendendackel/features/settings/data_source_settings.dart';
import 'package:dividendendackel/features/today/today_state.dart';
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
          themePreferenceStoreProvider.overrideWithValue(
            _MemoryThemePreferenceStore(),
          ),
          dataSourceSettingsStoreProvider.overrideWithValue(
            _MemoryDataSourceSettingsStore(),
          ),
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
            (Ref ref) async => const TodayChanges(
              previousAt: null,
              holdingChanges: 0,
              dividendChanges: 0,
              quoteChanges: 0,
            ),
          ),
          calendarEventsProvider.overrideWith(
            (Ref ref, CalendarEventsQuery query) =>
                Stream<List<DividendEvent>>.value(const <DividendEvent>[]),
          ),
          forecastSourceEventsProvider.overrideWith(
            (Ref ref, ForecastEventsQuery query) =>
                Stream<List<DividendEvent>>.value(const <DividendEvent>[]),
          ),
          providerStatusesProvider.overrideWith(
            (Ref ref) => Stream<List<ProviderStatus>>.value(<ProviderStatus>[
              ProviderStatus(
                providerId: 'sec',
                health: ProviderHealth.healthy,
                lastRequestAt: DateTime.utc(2026, 8, 22, 11, 58),
                cacheHits: 3,
                cacheMisses: 1,
              ),
              ProviderStatus(
                providerId: 'frankfurter',
                health: ProviderHealth.rateLimited,
                lastRequestAt: DateTime.utc(2026, 8, 22, 11, 59),
                rateLimitResetAt: DateTime.utc(2026, 8, 22, 13),
                lastErrorCategory: FailureCategory.rateLimited,
                lastErrorMessage: 'Data source limit reached.',
              ),
            ]),
          ),
          activeOperationsProvider.overrideWith(
            (Ref ref) => Stream<List<RequestStatus>>.value(<RequestStatus>[
              RequestStatus(
                requestKey: 'sec:filings',
                provider: 'sec',
                operation: 'fetchFilings',
                priority: RequestPriority.high,
                lifecycle: RequestLifecycle.running,
                queuedAt: DateTime.utc(2026, 8, 22, 11, 59),
                startedAt: DateTime.utc(2026, 8, 22, 11, 59),
                attempt: 1,
                subscriberCount: 1,
              ),
            ]),
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

    testWidgets('opens the income forecast from the calendar', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester, size: const Size(1000, 900));

      await tester.tap(find.text('Calendar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Income forecast'));
      await tester.pumpAndSettle();

      expect(find.text('No holdings to forecast'), findsOneWidget);
      expect(find.text('Calendar'), findsWidgets);
    });

    testWidgets('reaches the data status screen', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Data status'));
      await tester.pumpAndSettle();

      expect(find.text('Data status'), findsWidgets);
      expect(find.text('SEC EDGAR'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.textContaining('75%'), findsOneWidget);
      expect(find.text('Rate limited'), findsOneWidget);
      expect(
        find.text('Last error: Data source limit reached.'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(find.text('Current activity'), 300);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('fetchFilings'), findsOneWidget);
    });

    testWidgets('reaches settings and about', (WidgetTester tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      // The version is visible in Settings itself, so checking it does not
      // require knowing to open another screen.
      await tester.scrollUntilVisible(find.text('About'), 300);
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

    testWidgets('applies a selected theme immediately', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.themeMode, ThemeMode.dark);
      expect(
        Theme.of(tester.element(find.text('Settings'))).brightness,
        Brightness.dark,
      );
    });

    testWidgets('stores provider keys without displaying their value', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Data sources'));
      await tester.pumpAndSettle();

      expect(find.text('SEC EDGAR'), findsOneWidget);
      expect(find.text('Frankfurter / ECB'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Financial Modeling Prep'),
        200,
      );
      final Finder providerCard = find.ancestor(
        of: find.text('Financial Modeling Prep'),
        matching: find.byType(Card),
      );
      await tester.tap(
        find.descendant(of: providerCard, matching: find.text('Add key')),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'top-secret-value');
      await tester.tap(find.text('Save securely'));
      await tester.pumpAndSettle();

      expect(find.text('top-secret-value'), findsNothing);
      expect(find.text('API key stored securely'), findsOneWidget);
      expect(
        find.descendant(of: providerCard, matching: find.text('Replace key')),
        findsOneWidget,
      );
    });

    testWidgets('settings remain usable at large text scale', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.text('About'), 200);
      expect(find.text('About'), findsOneWidget);
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

    test('body and semantic colours meet WCAG AA contrast', () {
      for (final ThemeData theme in <ThemeData>[
        AppTheme.light(),
        AppTheme.dark(),
      ]) {
        final Color surface = theme.colorScheme.surface;
        final AppSemanticColors semantic = theme
            .extension<AppSemanticColors>()!;
        for (final Color foreground in <Color>[
          theme.colorScheme.onSurface,
          theme.colorScheme.onSurfaceVariant,
          semantic.positive,
          semantic.negative,
          semantic.estimate,
          semantic.accent,
        ]) {
          expect(
            _contrastRatio(foreground, surface),
            greaterThanOrEqualTo(4.5),
            reason: '$foreground on $surface in ${theme.brightness}',
          );
        }
      }
    });
  });
}

double _contrastRatio(Color foreground, Color background) {
  final double lighter =
      foreground.computeLuminance() > background.computeLuminance()
      ? foreground.computeLuminance()
      : background.computeLuminance();
  final double darker =
      foreground.computeLuminance() > background.computeLuminance()
      ? background.computeLuminance()
      : foreground.computeLuminance();
  return (lighter + 0.05) / (darker + 0.05);
}

final class _MemoryThemePreferenceStore implements ThemePreferenceStore {
  ThemeMode mode = ThemeMode.system;

  @override
  Future<ThemeMode> load() async => mode;

  @override
  Future<void> save(ThemeMode mode) async => this.mode = mode;
}

final class _MemoryDataSourceSettingsStore implements DataSourceSettingsStore {
  final Map<MarketDataSource, DataSourceConfiguration> configurations =
      <MarketDataSource, DataSourceConfiguration>{
        for (final MarketDataSource source in MarketDataSource.values)
          source: DataSourceConfiguration(
            source: source,
            enabled: source.enabledByDefault,
            hasApiKey: false,
          ),
      };

  @override
  Future<DataSourceConfiguration> load(MarketDataSource source) async =>
      configurations[source]!;

  @override
  Future<void> removeApiKey(MarketDataSource source) async {
    configurations[source] = configurations[source]!.copyWith(
      enabled: false,
      hasApiKey: false,
    );
  }

  @override
  Future<void> setApiKey(MarketDataSource source, String apiKey) async {
    configurations[source] = configurations[source]!.copyWith(hasApiKey: true);
  }

  @override
  Future<void> setEnabled(MarketDataSource source, bool enabled) async {
    configurations[source] = configurations[source]!.copyWith(enabled: enabled);
  }
}
