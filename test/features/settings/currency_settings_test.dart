import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/currency/fx_state.dart';
import 'package:dividendendackel/features/settings/currency_settings.dart';
import 'package:dividendendackel/features/settings/currency_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_clock.dart';

void main() {
  test('platform store falls back to EUR for an unknown saved code', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'portfolio.displayCurrency': 'NOT_A_CURRENCY',
    });
    final PlatformDisplayCurrencyStore store = PlatformDisplayCurrencyStore();
    expect(await store.load(), Currency.eur);
  });

  test('loads, immediately applies and persists display currency', () async {
    final _Store store = _Store(Currency.usd);
    final ProviderContainer container = ProviderContainer(
      overrides: [displayCurrencyStoreProvider.overrideWithValue(store)],
    );
    addTearDown(container.dispose);

    expect(container.read(displayCurrencyProvider).currency, Currency.eur);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(displayCurrencyProvider).currency, Currency.usd);

    await container.read(displayCurrencyProvider.notifier).select(Currency.gbp);
    expect(container.read(displayCurrencyProvider).currency, Currency.gbp);
    expect(store.saved, Currency.gbp);
  });

  testWidgets('shows explicit source, date and staleness', (
    WidgetTester tester,
  ) async {
    final DateTime now = DateTime.utc(2026, 8, 23);
    final FxRate rate = FxRate(
      base: Currency.eur,
      quote: Currency.usd,
      rate: Decimal.parse('1.2'),
      observedAt: DateTime.utc(2026, 8, 10),
      provenance: Provenance(source: 'frankfurter', fetchedAt: now),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(FakeClock(now)),
          displayCurrencyStoreProvider.overrideWithValue(_Store(Currency.usd)),
          trackedCurrenciesProvider.overrideWith(
            (Ref ref) async => <Currency>{Currency.usd},
          ),
          cachedFxRatesProvider.overrideWith(
            (Ref ref) => Stream<List<FxRate>>.value(<FxRate>[rate]),
          ),
        ],
        child: const MaterialApp(home: CurrencySettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('Currency & exchange rates'), findsOneWidget);
    expect(find.text('1 EUR = 1.2 USD'), findsOneWidget);
    expect(
      find.text('frankfurter · 2026-08-10 · stale (13 days old)'),
      findsOneWidget,
    );
    expect(find.textContaining('provider=ECB'), findsOneWidget);
  });
}

final class _Store implements DisplayCurrencyStore {
  _Store(this.loaded);
  final Currency loaded;
  Currency? saved;

  @override
  Future<Currency> load() async => loaded;

  @override
  Future<void> save(Currency currency) async => saved = currency;
}
