import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/use_cases/calendar_export.dart';
import 'package:dividendendackel/features/calendar/calendar_export_writer.dart';
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
    double textScale = 1,
    CalendarExportWriter? exportWriter,
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
          effectivePortfolioIdProvider.overrideWith(
            (Ref ref) => InvestmentPortfolio.defaultId,
          ),
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
          if (exportWriter != null)
            calendarExportWriterProvider.overrideWithValue(exportWriter),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          builder: (BuildContext context, Widget? child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
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

  testWidgets('exports the current scope and date-mode snapshot locally', (
    WidgetTester tester,
  ) async {
    final _FakeCalendarExportWriter writer = _FakeCalendarExportWriter();
    await pumpCalendar(tester, exportWriter: writer);

    await tester.tap(find.byKey(const ValueKey<String>('export-calendar')));
    await tester.pumpAndSettle();

    expect(writer.documents, hasLength(1));
    expect(writer.documents.single.eventCount, 3);
    expect(
      writer.documents.single.contents,
      contains('X-WR-CALNAME:DividendenDackel · Current portfolio · Ex-date'),
    );
    expect(
      writer.documents.single.contents,
      contains('DTSTART;VALUE=DATE:20260825'),
    );
    expect(find.text('3 dividend events exported locally.'), findsOneWidget);

    await tester.tap(find.text('Payment'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byTooltip('Next period'));
    await tester.pump();
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('export-calendar')));
    await tester.pumpAndSettle();
    expect(writer.documents, hasLength(2));
    expect(
      writer.documents.last.contents,
      contains('DTSTART;VALUE=DATE:20260902'),
    );
  });

  testWidgets('reports a local calendar save failure without getting stuck', (
    WidgetTester tester,
  ) async {
    final _FakeCalendarExportWriter writer = _FakeCalendarExportWriter(
      fail: true,
    );
    await pumpCalendar(tester, exportWriter: writer);

    await tester.tap(find.byKey(const ValueKey<String>('export-calendar')));
    await tester.pumpAndSettle();

    expect(find.text('Calendar export could not be saved.'), findsOneWidget);
    final IconButton button = tester.widget(
      find.byKey(const ValueKey<String>('export-calendar')),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
    'supports large text without clipping interactive calendar rows',
    (WidgetTester tester) async {
      await pumpCalendar(tester, size: const Size(412, 915), textScale: 2);

      expect(
        find.byKey(
          const ValueKey<String>('calendar-day-2026-08-25T00:00:00.000'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Year'));
      await tester.pump();
      await tester.pump();
      expect(
        find.bySemanticsLabel(RegExp(r'January 2026, \d+ payments')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

final class _FakeCalendarExportWriter implements CalendarExportWriter {
  _FakeCalendarExportWriter({this.fail = false});

  final bool fail;
  final List<CalendarExportDocument> documents = <CalendarExportDocument>[];

  @override
  Future<bool> save(CalendarExportDocument document) async {
    documents.add(document);
    if (fail) throw StateError('simulated local write failure');
    return true;
  }
}
