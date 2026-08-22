import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/calendar/forecast_screen.dart';
import 'package:dividendendackel/features/calendar/forecast_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
  const Instrument instrument = Instrument(
    internalId: 'allianz',
    symbol: 'ALV',
    name: 'Allianz SE',
    currency: Currency.eur,
  );

  List<DividendEvent> history() => <DividendEvent>[
    for (final int year in <int>[2024, 2025])
      for (final int month in <int>[2, 5, 8, 11])
        DividendEvent(
          instrumentId: instrument.internalId,
          amountPerShare: Money.parse(year == 2024 ? '1' : '1.1', Currency.eur),
          status: DividendStatus.confirmed,
          frequency: DividendFrequency.quarterly,
          exDate: DateTime.utc(year, month, 10),
          paymentDate: DateTime.utc(year, month, 20),
          provenance: provenance,
        ),
    DividendEvent(
      instrumentId: instrument.internalId,
      amountPerShare: Money.parse('1.2', Currency.eur),
      status: DividendStatus.announced,
      frequency: DividendFrequency.quarterly,
      exDate: DateTime.utc(2026, 11, 10),
      paymentDate: DateTime.utc(2026, 11, 20),
      provenance: provenance,
    ),
  ];

  Future<void> pumpForecast(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1100, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final Holding holding = Holding(
      instrumentId: instrument.internalId,
      quantity: Decimal.fromInt(10),
      provenance: provenance,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(FakeClock(now)),
          holdingsProvider.overrideWith(
            (Ref ref) => Stream<List<Holding>>.value(<Holding>[holding]),
          ),
          instrumentsByIdProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Instrument>>.value(
              const <String, Instrument>{'allianz': instrument},
            ),
          ),
          forecastSourceEventsProvider.overrideWith(
            (Ref ref, ForecastEventsQuery query) =>
                Stream<List<DividendEvent>>.value(history()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: ForecastScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows 24-month totals, certainty and explanation', (
    WidgetTester tester,
  ) async {
    await pumpForecast(tester);

    expect(find.text('24-month income forecast'), findsOneWidget);
    expect(find.text('Trailing 12 months'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('✓ Paid'), findsWidgets);
    expect(find.text('● Confirmed upcoming'), findsOneWidget);
    expect(find.text('E Estimated'), findsOneWidget);
    expect(find.textContaining('2026 forecast'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('How this was estimated'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Allianz SE'), findsOneWidget);
    expect(find.textContaining('default growth rate'), findsOneWidget);
  });

  testWidgets('switches month, quarter and year breakdowns', (
    WidgetTester tester,
  ) async {
    await pumpForecast(tester);

    expect(find.text('Aug 2026'), findsWidgets);
    await tester.tap(find.text('Quarter'));
    await tester.pump();
    expect(find.text('Q3 2026'), findsOneWidget);
    await tester.tap(find.text('Year'));
    await tester.pump();
    expect(find.text('2026'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
