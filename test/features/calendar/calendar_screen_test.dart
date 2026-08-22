import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/calendar/calendar_screen.dart';
import 'package:dividendendackel/features/calendar/calendar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23, 12);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
  const Instrument allianz = Instrument(
    internalId: 'allianz',
    symbol: 'ALV',
    name: 'Allianz SE',
    currency: Currency.eur,
    mic: 'XETR',
  );
  const Instrument basf = Instrument(
    internalId: 'basf',
    symbol: 'BAS',
    name: 'BASF SE',
    currency: Currency.eur,
    mic: 'XETR',
  );

  List<DividendEvent> events() => <DividendEvent>[
    for (int index = 0; index < 3; index++)
      DividendEvent(
        instrumentId: allianz.internalId,
        amountPerShare: Money.parse('${2 + index}', Currency.eur),
        status: index == 1
            ? DividendStatus.historicallyEstimated
            : DividendStatus.confirmed,
        exDate: DateTime.utc(2026, 8, 25),
        paymentDate: DateTime.utc(2026, 9, 2 + index),
        provenance: provenance,
      ),
  ];

  Future<List<CalendarEventsQuery>> pumpCalendar(
    WidgetTester tester, {
    Size size = const Size(1100, 1000),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final List<CalendarEventsQuery> queries = <CalendarEventsQuery>[];
    final Holding holding = Holding(
      instrumentId: allianz.internalId,
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
          watchlistProvider.overrideWith(
            (Ref ref) => Stream<List<WatchlistEntry>>.value(<WatchlistEntry>[
              WatchlistEntry(
                instrumentId: basf.internalId,
                addedAt: now,
                provenance: provenance,
              ),
            ]),
          ),
          instrumentsByIdProvider.overrideWith(
            (Ref ref) => Stream<Map<String, Instrument>>.value(
              const <String, Instrument>{'allianz': allianz, 'basf': basf},
            ),
          ),
          calendarEventsProvider.overrideWith((
            Ref ref,
            CalendarEventsQuery query,
          ) {
            queries.add(query);
            final List<DividendEvent> filtered = events().where((event) {
              final DateTime? date = event.dateFor(query.dateMode);
              return date != null &&
                  query.range.contains(date) &&
                  (query.instrumentIds?.contains(event.instrumentId) ?? true);
            }).toList();
            return Stream<List<DividendEvent>>.value(filtered);
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(body: CalendarScreen()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return queries;
  }

  testWidgets('caps busy days and expands held payment details', (
    WidgetTester tester,
  ) async {
    await pumpCalendar(tester);

    expect(find.text('Show 1 more'), findsOneWidget);
    expect(find.text('E'), findsOneWidget);
    await tester.tap(find.text('Show 1 more'));
    await tester.pump();

    expect(find.text('25 August 2026 · 3 events'), findsOneWidget);
    expect(find.textContaining('Gross €20.00'), findsOneWidget);
    expect(find.textContaining('Net (estimated)'), findsOneWidget);
    expect(find.text('Confirmed'), findsWidgets);
  });

  testWidgets('switches views and date meaning with an explanation', (
    WidgetTester tester,
  ) async {
    final List<CalendarEventsQuery> queries = await pumpCalendar(tester);

    expect(find.textContaining('own the share before'), findsOneWidget);
    await tester.tap(find.text('Payment'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('reach your account'), findsOneWidget);
    expect(queries.last.dateMode, DividendDateMode.paymentDate);

    await tester.tap(find.text('Year'));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('year-month-1')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('year-month-12')), findsOneWidget);

    await tester.tap(find.text('Agenda'));
    await tester.pump();
    await tester.pump();
    expect(queries.last.range.start, DateTime(2026, 8, 23));
    expect(queries.last.range.end, DateTime(2027, 8, 23));
  });

  testWidgets('scope and currency controls are explicit and honest', (
    WidgetTester tester,
  ) async {
    final List<CalendarEventsQuery> queries = await pumpCalendar(tester);

    expect(queries.last.instrumentIds, <String>{allianz.internalId});
    await tester.tap(find.byType(DropdownMenu<DividendCalendarScope>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All instruments').last);
    await tester.pump();
    await tester.pump();
    expect(queries.last.instrumentIds, isNull);

    final DropdownMenu<Currency?> currencyMenu = tester.widget(
      find.byKey(const ValueKey<String>('display-currency')),
    );
    currencyMenu.onSelected!(Currency.usd);
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('fx-notice')), findsOneWidget);
    expect(find.textContaining('native currency'), findsOneWidget);
  });

  testWidgets('fits a phone and can remove weekend columns', (
    WidgetTester tester,
  ) async {
    await pumpCalendar(tester, size: const Size(412, 915));

    expect(find.text('Sun'), findsOneWidget);
    await tester.tap(find.text('Weekends'));
    await tester.pump();
    expect(find.text('Sun'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
