import 'package:decimal/decimal.dart';
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
import 'package:dividendendackel/features/settings/about_screen.dart';
import 'package:dividendendackel/features/settings/currency_settings.dart';
import 'package:dividendendackel/features/settings/data_source_settings.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:dividendendackel/features/today/today_state.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Whether the deterministic journey provider returns prices or behaves as an
/// unavailable network. Both modes use the same real repositories and UI.
enum JourneyQuoteMode { available, unavailable }

/// Real-app integration harness with an isolated database and deterministic
/// platform/provider boundaries.
final class JourneyHarness {
  JourneyHarness._({
    required this.database,
    required this.coordinator,
    required this.clock,
    required this.onboarding,
  });

  final AppDatabase database;
  final RequestCoordinator coordinator;
  final FixedJourneyClock clock;
  final MemoryOnboardingStore onboarding;

  static Future<JourneyHarness> start(
    WidgetTester tester, {
    bool onboarded = true,
    JourneyQuoteMode quoteMode = JourneyQuoteMode.unavailable,
    String initialLocation = '/today',
  }) async {
    final FixedJourneyClock clock = FixedJourneyClock(
      DateTime.utc(2026, 8, 23, 12),
    );
    final AppDatabase database = AppDatabase.withExecutor(
      NativeDatabase.memory(),
    );
    final RequestCoordinator coordinator = RequestCoordinator(
      clock: clock,
      providerPolicies: <String, ProviderRequestPolicy>{
        'journey': ProviderRequestPolicy(maxAttempts: 1),
      },
    );
    final MemoryOnboardingStore onboarding = MemoryOnboardingStore(onboarded);
    final ProviderRegistry registry = ProviderRegistry(
      providers: <MarketDataProvider>[
        JourneyQuoteProvider(mode: quoteMode, clock: clock),
      ],
    );
    final ProviderMarketDataService service = ProviderMarketDataService(
      ProviderFallbackChain(registry: registry, coordinator: coordinator),
    );
    final PortfolioRefreshRunner runner = PortfolioRefreshRunner(
      clock: clock,
      instruments: DriftInstrumentRepository(database),
      portfolio: DriftPortfolioRepository(database),
      dividends: DriftDividendRepository(database),
      marketData: DriftMarketDataRepository(database),
      providers: service,
      registry: registry,
      revalidator: StaleWhileRevalidateExecutor(
        metadata: DriftCacheMetadataRepository(database),
        policy: CachePolicy(),
      ),
    );
    final JourneyHarness harness = JourneyHarness._(
      database: database,
      coordinator: coordinator,
      clock: clock,
      onboarding: onboarding,
    );
    addTearDown(() => harness.dispose(tester));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(clock),
          onboardingStoreProvider.overrideWithValue(onboarding),
          automaticPortfolioRefreshEnabledProvider.overrideWithValue(false),
          languagePreferenceStoreProvider.overrideWithValue(
            MemoryLanguageStore(),
          ),
          themePreferenceStoreProvider.overrideWithValue(MemoryThemeStore()),
          displayCurrencyStoreProvider.overrideWithValue(MemoryCurrencyStore()),
          taxSettingsStoreProvider.overrideWithValue(MemoryTaxStore()),
          todaySnapshotStoreProvider.overrideWithValue(MemorySnapshotStore()),
          notificationPreferenceStoreProvider.overrideWithValue(
            MemoryNotificationStore(),
          ),
          localNotificationGatewayProvider.overrideWithValue(
            const MemoryNotificationGateway(),
          ),
          dataSourceSettingsStoreProvider.overrideWithValue(
            MemoryDataSourceSettingsStore(),
          ),
          appVersionProvider.overrideWith(
            (Ref ref) async => const AppVersionInfo(
              version: '0.0.0',
              buildNumber: '0',
              commit: 'integration-test',
            ),
          ),
          providerMarketDataServiceProvider.overrideWithValue(service),
          portfolioRefreshRunnerProvider.overrideWithValue(runner),
          fxRateFetcherProvider.overrideWithValue(
            (Currency base, Set<Currency> quotes, DateRange range) async =>
                _fxResult(
                  base: base,
                  quotes: quotes,
                  clock: clock,
                  available: quoteMode == JourneyQuoteMode.available,
                ),
          ),
        ],
        child: DividendenDackelApp(initialLocation: initialLocation),
      ),
    );
    await settle(tester);
    return harness;
  }

  static Future<void> settle(WidgetTester tester) => tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 20),
  );

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await coordinator.dispose();
    await database.close();
  }

  Future<void> openDestination(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await settle(tester);
  }

  Future<void> addHolding(
    WidgetTester tester, {
    required String query,
    required String name,
    required String isin,
    String quantity = '5',
    String averagePrice = '100',
  }) async {
    final Finder add = find.byKey(const ValueKey<String>('add-instrument'));
    if (add.evaluate().isEmpty) {
      await openDestination(tester, 'Portfolio');
    }
    if (add.evaluate().isEmpty) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
      await settle(tester);
    }
    await tester.tap(add);
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, query);
    await tester.tap(find.byTooltip('Search'));
    await settle(tester);
    await tester.ensureVisible(find.text(name));
    await settle(tester);
    await tester.tap(find.text(name));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey<String>('holding-quantity')),
      quantity,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('holding-average-price')),
      averagePrice,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    await tester.ensureVisible(find.text('Add holding'));
    await settle(tester);
    await tester.tap(find.text('Add holding'));
    await settle(tester);
    expect(find.textContaining('$name added'), findsOneWidget);
    final Finder holding = find.byKey(ValueKey<String>('holding-isin:$isin'));
    await tester.scrollUntilVisible(
      holding,
      300,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 30,
    );
    await settle(tester);
    expect(holding, findsOneWidget);
    // The confirmation SnackBar temporarily covers the floating add button on
    // a short desktop window. Let it leave before a journey adds another row.
    await tester.pump(const Duration(seconds: 5));
    await settle(tester);
  }

  Future<void> refresh(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Refresh data'));
    await settle(tester);
  }

  Future<Set<String>> holdingCurrencyCodes() async {
    final List<Holding> holdings = await DriftPortfolioRepository(database)
        .watchHoldings()
        .first;
    final List<Instrument> instruments =
        await DriftInstrumentRepository(database)
            .watchByIds(
              holdings.map((Holding holding) => holding.instrumentId).toSet(),
            )
            .first;
    return instruments
        .map((Instrument instrument) => instrument.currency.code)
        .toSet();
  }

  Future<void> seedReportedAnnualDividends(
    String instrumentId,
    Currency currency,
  ) async {
    final DateTime fetchedAt = clock.now().toUtc();
    final List<DividendEvent> events = <DividendEvent>[
      for (int offset = 0; offset < 8; offset++)
        DividendEvent(
          instrumentId: instrumentId,
          amountPerShare: Money(Decimal.fromInt(8 + offset), currency),
          status: DividendStatus.confirmed,
          exDate: DateTime.utc(2018 + offset, 6, 1),
          paymentDate: DateTime.utc(2018 + offset, 6, 5),
          provenance: Provenance(
            source: 'journey-history',
            fetchedAt: fetchedAt,
            confidence: Confidence.high,
            reportedCurrency: currency,
          ),
        ),
    ];
    final Result<void> result = await DriftDividendRepository(database)
        .saveAll(events, idOf: dividendEventIdentity);
    if (result.failureOrNull case final Failure failure) {
      throw StateError('Could not seed reported dividend history: $failure');
    }
  }

  static Result<List<FxRate>> _fxResult({
    required Currency base,
    required Set<Currency> quotes,
    required FixedJourneyClock clock,
    required bool available,
  }) {
    if (!available) return const Failed<List<FxRate>>(NetworkFailure());
    final DateTime day = DateTime.utc(2026, 8, 21);
    return Success<List<FxRate>>(<FxRate>[
      for (final Currency quote in quotes)
        FxRate(
          base: base,
          quote: quote,
          rate: quote == Currency.usd
              ? Decimal.parse('1.15')
              : quote == Currency.gbp
              ? Decimal.parse('0.86')
              : Decimal.one,
          observedAt: day,
          provenance: Provenance(
            source: 'journey-fx',
            fetchedAt: clock.now(),
            reportedCurrency: quote,
          ),
        ),
    ]);
  }
}

final class FixedJourneyClock implements Clock {
  const FixedJourneyClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

final class JourneyQuoteProvider implements QuoteDataProvider {
  const JourneyQuoteProvider({required this.mode, required this.clock});

  final JourneyQuoteMode mode;
  final Clock clock;

  @override
  String get id => 'journey';

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.quote,
  };

  @override
  Future<Result<Quote>> fetchQuote(
    Instrument instrument, {
    required CancellationToken cancellationToken,
  }) async {
    if (mode == JourneyQuoteMode.unavailable) {
      return const Failed<Quote>(NetworkFailure());
    }
    final Decimal price = switch (instrument.currency) {
      Currency(:final String code) when code == 'USD' => Decimal.fromInt(200),
      Currency(:final String code) when code == 'GBP' => Decimal.fromInt(15),
      _ => Decimal.fromInt(100),
    };
    final DateTime fetchedAt = clock.now().toUtc();
    return Success<Quote>(
      Quote(
        instrumentId: instrument.internalId,
        price: Money(price, instrument.currency),
        previousClose: Money(price - Decimal.one, instrument.currency),
        asOf: fetchedAt.subtract(const Duration(hours: 1)),
        provenance: Provenance(
          source: id,
          fetchedAt: fetchedAt,
          reportedCurrency: instrument.currency,
          originalSymbol: instrument.symbol,
          exchange: instrument.exchange,
        ),
      ),
    );
  }
}

final class MemoryOnboardingStore implements OnboardingStore {
  MemoryOnboardingStore(this.completeValue);

  bool completeValue;

  @override
  Future<void> complete() async => completeValue = true;

  @override
  Future<bool> isComplete() async => completeValue;
}

final class MemoryLanguageStore implements LanguagePreferenceStore {
  @override
  Future<AppLanguage> load() async => AppLanguage.english;

  @override
  Future<void> save(AppLanguage language) async {}
}

final class MemoryThemeStore implements ThemePreferenceStore {
  @override
  Future<ThemeMode> load() async => ThemeMode.system;

  @override
  Future<void> save(ThemeMode mode) async {}
}

final class MemoryCurrencyStore implements DisplayCurrencyStore {
  @override
  Future<Currency> load(String portfolioId) async => Currency.eur;

  @override
  Future<void> save(String portfolioId, Currency currency) async {}
}

final class MemoryTaxStore implements TaxSettingsStore {
  @override
  Future<TaxSettings> load(
    WithholdingRateTable defaults, {
    required String portfolioId,
  }) async => TaxSettings(profile: DividendTaxProfile(), table: defaults);

  @override
  Future<void> save(String portfolioId, TaxSettings settings) async {}
}

final class MemorySnapshotStore implements TodaySnapshotStore {
  TodaySnapshot? snapshot;

  @override
  Future<TodaySnapshot?> load() async => snapshot;

  @override
  Future<void> save(TodaySnapshot value) async => snapshot = value;
}

final class MemoryNotificationStore implements NotificationPreferenceStore {
  @override
  Future<NotificationMode> loadMode() async => NotificationMode.disabled;

  @override
  Future<void> saveMode(NotificationMode mode) async {}

  @override
  Future<Set<String>> loadDelivered() async => const <String>{};

  @override
  Future<void> markDelivered(String key) async {}
}

final class MemoryNotificationGateway implements LocalNotificationGateway {
  const MemoryNotificationGateway();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> show(PortfolioNotification notification) async {}
}

final class MemoryDataSourceSettingsStore implements DataSourceSettingsStore {
  final Map<MarketDataSource, bool> _enabled = <MarketDataSource, bool>{};
  final Set<MarketDataSource> _keyed = <MarketDataSource>{};

  @override
  Future<DataSourceConfiguration> load(MarketDataSource source) async =>
      DataSourceConfiguration(
        source: source,
        enabled: _enabled[source] ?? source.enabledByDefault,
        hasApiKey: _keyed.contains(source),
      );

  @override
  Future<void> removeApiKey(MarketDataSource source) async {
    _keyed.remove(source);
  }

  @override
  Future<void> setApiKey(MarketDataSource source, String apiKey) async {
    _keyed.add(source);
  }

  @override
  Future<void> setEnabled(MarketDataSource source, bool enabled) async {
    _enabled[source] = enabled;
  }
}
