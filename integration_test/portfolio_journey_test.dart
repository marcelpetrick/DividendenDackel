import 'package:dividendendackel/app/app.dart';
import 'package:dividendendackel/app/localization/language_preference.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/theme_preference.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/cache_policy.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/core/networking/stale_while_revalidate.dart';
import 'package:dividendendackel/core/utils/clock.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/data/providers/provider_registry.dart';
import 'package:dividendendackel/data/repositories/drift_cache_metadata_repository.dart';
import 'package:dividendendackel/data/repositories/drift_dividend_repository.dart';
import 'package:dividendendackel/data/repositories/drift_instrument_repository.dart';
import 'package:dividendendackel/data/repositories/drift_market_data_repository.dart';
import 'package:dividendendackel/data/repositories/drift_portfolio_repository.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/features/currency/fx_state.dart';
import 'package:dividendendackel/features/notifications/notification_state.dart';
import 'package:dividendendackel/features/onboarding/onboarding_state.dart';
import 'package:dividendendackel/features/refresh/portfolio_refresh.dart';
import 'package:dividendendackel/features/settings/currency_settings.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:dividendendackel/features/today/today_state.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'adds a holding, shows calendar and forecast, then remains useful offline',
    (WidgetTester tester) async {
      final _FixedClock clock = _FixedClock(DateTime.utc(2026, 8, 23, 12));
      final AppDatabase database = AppDatabase.withExecutor(
        NativeDatabase.memory(),
      );
      final RequestCoordinator coordinator = RequestCoordinator(
        clock: clock,
        providerPolicies: <String, ProviderRequestPolicy>{
          'offline': ProviderRequestPolicy(maxAttempts: 1),
        },
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await coordinator.dispose();
        await database.close();
      });

      final ProviderRegistry offlineRegistry = ProviderRegistry(
        providers: <MarketDataProvider>[const _OfflineQuoteProvider()],
      );
      final ProviderMarketDataService offlineService =
          ProviderMarketDataService(
            ProviderFallbackChain(
              registry: offlineRegistry,
              coordinator: coordinator,
            ),
          );
      final PortfolioRefreshRunner offlineRunner = PortfolioRefreshRunner(
        clock: clock,
        instruments: DriftInstrumentRepository(database),
        portfolio: DriftPortfolioRepository(database),
        dividends: DriftDividendRepository(database),
        marketData: DriftMarketDataRepository(database),
        providers: offlineService,
        registry: offlineRegistry,
        revalidator: StaleWhileRevalidateExecutor(
          metadata: DriftCacheMetadataRepository(database),
          policy: CachePolicy(),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            clockProvider.overrideWithValue(clock),
            onboardingCompletedProvider.overrideWith((Ref ref) async => true),
            automaticPortfolioRefreshEnabledProvider.overrideWithValue(false),
            // Without this the journey reads the developer's real
            // shared_preferences and renders whatever language they last
            // chose in the app, while the assertions below are English.
            languagePreferenceStoreProvider.overrideWithValue(_LanguageStore()),
            themePreferenceStoreProvider.overrideWithValue(_ThemeStore()),
            displayCurrencyStoreProvider.overrideWithValue(_CurrencyStore()),
            taxSettingsStoreProvider.overrideWithValue(_TaxStore()),
            todaySnapshotStoreProvider.overrideWithValue(_SnapshotStore()),
            notificationPreferenceStoreProvider.overrideWithValue(
              _NotificationStore(),
            ),
            localNotificationGatewayProvider.overrideWithValue(
              const _NotificationGateway(),
            ),
            providerMarketDataServiceProvider.overrideWithValue(offlineService),
            portfolioRefreshRunnerProvider.overrideWithValue(offlineRunner),
            fxRateFetcherProvider.overrideWithValue(
              (Currency base, Set<Currency> quotes, DateRange range) async =>
                  const Failed<List<FxRate>>(NetworkFailure()),
            ),
          ],
          child: const DividendenDackelApp(),
        ),
      );
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 20),
      );

      expect(find.text('Today'), findsWidgets);
      await tester.tap(find.text('Portfolio').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('add-instrument')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'BAS');
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('BASF SE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BASF SE'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey<String>('holding-quantity')),
        '7.5',
      );
      await tester.enterText(
        find.byKey(const ValueKey<String>('holding-average-price')),
        '45.20',
      );
      // Dismiss the keyboard and scroll the button into view first: it sits
      // inside the dialog's scroll view, and on a short screen the keyboard
      // pushes it out of reach, so the tap lands on nothing.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Add holding'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add holding'));
      await tester.pumpAndSettle();

      expect(find.textContaining('BASF SE added'), findsOneWidget);
      final Finder basfHolding = find.byKey(
        const ValueKey<String>('holding-isin:DE000BASF111'),
      );
      await tester.scrollUntilVisible(
        basfHolding,
        300,
        scrollable: find.byType(Scrollable).first,
        maxScrolls: 30,
      );
      await tester.pumpAndSettle();
      expect(basfHolding, findsOneWidget);
      // Scoped to the holding row: the activity ledger also renders the
      // quantity ("Opening balance · BAS · XETR · 7.5 shares"), so a bare
      // textContaining match depends on how much of the lazy list happens to
      // be built and breaks whenever a card changes height.
      expect(
        find.descendant(
          of: basfHolding,
          matching: find.textContaining('7.5 shares'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Calendar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agenda'));
      await tester.pumpAndSettle();

      expect(find.textContaining('/ share'), findsWidgets);
      expect(find.byKey(const ValueKey<String>('held-payment')), findsWidgets);

      await tester.tap(find.text('Income forecast'));
      await tester.pumpAndSettle();
      expect(find.text('24-month income forecast'), findsOneWidget);
      final Finder monthView = find.text('Month');
      final Finder forecastScroll = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(
        monthView,
        250,
        scrollable: forecastScroll,
        maxScrolls: 20,
      );
      expect(monthView, findsOneWidget);

      await tester.tap(find.byTooltip('Refresh data'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 20),
      );

      await tester.scrollUntilVisible(
        find.text('24-month income forecast'),
        -250,
        scrollable: forecastScroll,
        maxScrolls: 20,
      );
      expect(find.text('24-month income forecast'), findsOneWidget);
      // The banner says "1 source failed" or "N source failures", so assert
      // on the part that does not depend on how many sources happened to fail.
      expect(find.textContaining('saved data remains visible'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

final class _OfflineQuoteProvider implements QuoteDataProvider {
  const _OfflineQuoteProvider();

  @override
  String get id => 'offline';

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.quote,
  };

  @override
  Future<Result<Quote>> fetchQuote(
    Instrument instrument, {
    required CancellationToken cancellationToken,
  }) async => const Failed<Quote>(NetworkFailure());
}

final class _LanguageStore implements LanguagePreferenceStore {
  @override
  Future<AppLanguage> load() async => AppLanguage.english;

  @override
  Future<void> save(AppLanguage language) async {}
}

final class _ThemeStore implements ThemePreferenceStore {
  @override
  Future<ThemeMode> load() async => ThemeMode.system;

  @override
  Future<void> save(ThemeMode mode) async {}
}

final class _CurrencyStore implements DisplayCurrencyStore {
  @override
  Future<Currency> load(String portfolioId) async => Currency.eur;

  @override
  Future<void> save(String portfolioId, Currency currency) async {}
}

final class _TaxStore implements TaxSettingsStore {
  @override
  Future<TaxSettings> load(
    WithholdingRateTable defaults, {
    required String portfolioId,
  }) async => TaxSettings(profile: DividendTaxProfile(), table: defaults);

  @override
  Future<void> save(String portfolioId, TaxSettings settings) async {}
}

final class _SnapshotStore implements TodaySnapshotStore {
  TodaySnapshot? snapshot;

  @override
  Future<TodaySnapshot?> load() async => snapshot;

  @override
  Future<void> save(TodaySnapshot snapshot) async => this.snapshot = snapshot;
}

final class _NotificationStore implements NotificationPreferenceStore {
  @override
  Future<NotificationMode> loadMode() async => NotificationMode.disabled;

  @override
  Future<void> saveMode(NotificationMode mode) async {}

  @override
  Future<Set<String>> loadDelivered() async => const <String>{};

  @override
  Future<void> markDelivered(String key) async {}
}

final class _NotificationGateway implements LocalNotificationGateway {
  const _NotificationGateway();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> show(PortfolioNotification notification) async {}
}
