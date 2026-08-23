import 'dart:convert';

import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/domain/use_cases/calendar_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fetchedAt = DateTime.utc(2026, 8, 20);
  final Provenance provenance = Provenance(
    source: 'company, filing',
    fetchedAt: fetchedAt,
  );
  const Instrument instrument = Instrument(
    internalId: 'acme',
    symbol: 'ACME',
    name: 'Acme, Inc.; Europe 🐕',
    currency: Currency.eur,
    mic: 'XETR',
  );

  DividendEvent event({
    DividendStatus status = DividendStatus.historicallyEstimated,
    DateTime? exDate,
    DateTime? paymentDate,
  }) => DividendEvent(
    instrumentId: instrument.internalId,
    amountPerShare: Money.parse('1.2345', Currency.eur),
    status: status,
    exDate: exDate ?? DateTime.utc(2026, 8, 25),
    paymentDate: paymentDate ?? DateTime.utc(2026, 9, 2),
    provenance: provenance,
  );

  CalendarExportDocument export({
    Iterable<DividendEvent>? events,
    DividendDateMode mode = DividendDateMode.exDate,
    DateTime? createdAt,
  }) => CalendarIcsExporter.export(
    events: events ?? <DividendEvent>[event()],
    instruments: const <String, Instrument>{'acme': instrument},
    range: DateRange(DateTime.utc(2026, 8), DateTime.utc(2026, 10)),
    dateMode: mode,
    scopeLabel: 'Current portfolio',
    createdAt: createdAt ?? DateTime.utc(2026, 8, 23, 12, 34, 56),
  );

  test('writes an RFC 5545 all-day event and visibly marks estimates', () {
    final CalendarExportDocument document = export();

    expect(document.eventCount, 1);
    expect(
      document.fileName,
      'dividendendackel-calendar-20260801-20260930.ics',
    );
    expect(document.contents, startsWith('BEGIN:VCALENDAR\r\n'));
    expect(document.contents, endsWith('END:VCALENDAR\r\n'));
    expect(document.contents, contains('DTSTAMP:20260823T123456Z\r\n'));
    expect(document.contents, contains('DTSTART;VALUE=DATE:20260825\r\n'));
    expect(document.contents, contains('DTEND;VALUE=DATE:20260826\r\n'));
    expect(document.contents, contains('SUMMARY:[ESTIMATE] Dividend:'));
    expect(document.contents, contains('STATUS:TENTATIVE\r\n'));
    expect(document.contents, contains('Estimate: This date or amount'));
    expect(document.contents, contains('Acme\\, Inc.\\; Europe'));
    expect(document.contents, contains('Source: company\\, filing'));
  });

  test('uses the selected date mode and excludes events outside its range', () {
    final CalendarExportDocument document = export(
      mode: DividendDateMode.paymentDate,
      events: <DividendEvent>[
        event(status: DividendStatus.confirmed),
        event(
          paymentDate: DateTime.utc(2026, 10, 1),
          exDate: DateTime.utc(2026, 8, 26),
        ),
      ],
    );

    expect(document.eventCount, 1);
    expect(document.contents, contains('DTSTART;VALUE=DATE:20260902'));
    expect(document.contents, isNot(contains('DTSTART;VALUE=DATE:20261001')));
    expect(document.contents, contains('STATUS:CONFIRMED'));
    expect(document.contents, isNot(contains('[ESTIMATE]')));
    expect(
      document.contents,
      contains('X-DIVIDENDENDACKEL-DATE-MODE:paymentDate'),
    );
  });

  test('keeps event identity stable while export timestamps change', () {
    final CalendarExportDocument first = export();
    final CalendarExportDocument second = export(
      createdAt: DateTime.utc(2026, 8, 24),
    );

    String uid(CalendarExportDocument document) => document.contents
        .split('\r\n')
        .singleWhere((String line) => line.startsWith('UID:'));
    expect(uid(first), uid(second));
    expect(first.contents, isNot(second.contents));
  });

  test('folds every physical line to at most 75 UTF-8 octets', () {
    final CalendarExportDocument document = export();

    for (final String line in document.contents.split('\r\n')) {
      expect(utf8.encode(line).length, lessThanOrEqualTo(75), reason: line);
    }
    expect(document.contents, contains('\r\n '));
  });
}
