import 'package:dividendendackel/app/app.dart';
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
      await tester.tap(find.text('Add holding'));
      await tester.pumpAndSettle();

      expect(find.textContaining('BASF SE added'), findsOneWidget);
      final Finder basfHolding = find.byKey(
        const ValueKey<String>('holding-isin:DE000BASF111'),
      );
      for (
        int attempt = 0;
        attempt < 8 && basfHolding.evaluate().isEmpty;
        attempt++
      ) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -250));
        await tester.pumpAndSettle();
      }
      expect(basfHolding, findsOneWidget);
      expect(find.textContaining('7.5 shares'), findsOneWidget);

      await tester.tap(find.text('Calendar').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Agenda'));
      await tester.pumpAndSettle();

      expect(find.textContaining('/ share'), findsWidgets);
      expect(find.byKey(const ValueKey<String>('held-payment')), findsWidgets);

      await tester.tap(find.text('Income forecast'));
      await tester.pumpAndSettle();
      expect(find.text('24-month income forecast'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);

      await tester.tap(find.byTooltip('Refresh data'));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 20),
      );

      expect(find.text('24-month income forecast'), findsOneWidget);
      expect(
        find.textContaining('source failures; saved data remains visible'),
        findsOneWidget,
      );
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

final class _ThemeStore implements ThemePreferenceStore {
  @override
  Future<ThemeMode> load() async => ThemeMode.system;

  @override
  Future<void> save(ThemeMode mode) async {}
}

final class _CurrencyStore implements DisplayCurrencyStore {
  @override
  Future<Currency> load() async => Currency.eur;

  @override
  Future<void> save(Currency currency) async {}
}

final class _TaxStore implements TaxSettingsStore {
  @override
  Future<TaxSettings> load(WithholdingRateTable defaults) async =>
      TaxSettings(profile: DividendTaxProfile(), table: defaults);

  @override
  Future<void> save(TaxSettings settings) async {}
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
