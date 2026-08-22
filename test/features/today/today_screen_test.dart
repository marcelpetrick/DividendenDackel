import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/calendar/calendar_state.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:dividendendackel/features/today/today_screen.dart';
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(FakeClock(now)),
          taxSettingsStoreProvider.overrideWithValue(_TaxStore()),
          holdingsProvider.overrideWith(
            (Ref ref) => Stream<List<Holding>>.value(<Holding>[holding]),
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
    expect(tester.takeException(), isNull);
  });
}

final class _TaxStore implements TaxSettingsStore {
  @override
  Future<TaxSettings> load(WithholdingRateTable defaults) async =>
      TaxSettings(profile: DividendTaxProfile(), table: defaults);

  @override
  Future<void> save(TaxSettings settings) async {}
}
