import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';

/// A complete, local iCalendar snapshot ready to be saved by the platform.
final class CalendarExportDocument {
  /// Creates an export document.
  const CalendarExportDocument({
    required this.fileName,
    required this.contents,
    required this.eventCount,
  });

  /// Privacy-neutral suggested file name.
  final String fileName;

  /// RFC 5545 iCalendar text, including CRLF line endings.
  final String contents;

  /// Number of dividend events in [contents].
  final int eventCount;
}

/// Creates deterministic, importable dividend-calendar snapshots.
///
/// The use case has no file or network access. The UI supplies its already
/// filtered events and passes the resulting bytes to a platform save dialog.
abstract final class CalendarIcsExporter {
  /// Exports events whose selected date is inside the half-open [range].
  static CalendarExportDocument export({
    required Iterable<DividendEvent> events,
    required Map<String, Instrument> instruments,
    required DateRange range,
    required DividendDateMode dateMode,
    required String scopeLabel,
    required DateTime createdAt,
  }) {
    final List<(DateTime, DividendEvent)> dated =
        <(DateTime, DividendEvent)>[
          for (final DividendEvent event in events)
            if (event.dateFor(dateMode) case final DateTime date)
              if (range.contains(date)) (date, event),
        ]..sort((
          (DateTime, DividendEvent) left,
          (DateTime, DividendEvent) right,
        ) {
          final int byDate = left.$1.compareTo(right.$1);
          if (byDate != 0) return byDate;
          final int byInstrument = left.$2.instrumentId.compareTo(
            right.$2.instrumentId,
          );
          if (byInstrument != 0) return byInstrument;
          return left.$2.amountPerShare.amount.compareTo(
            right.$2.amountPerShare.amount,
          );
        });

    final List<String> lines = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//DividendenDackel//Dividend Calendar//EN',
      'CALSCALE:GREGORIAN',
      'METHOD:PUBLISH',
      'X-WR-CALNAME:${_escape('DividendenDackel · $scopeLabel · ${_modeLabel(dateMode)}')}',
      'X-DIVIDENDENDACKEL-DATE-MODE:${dateMode.name}',
      'X-DIVIDENDENDACKEL-RANGE:${_date(range.start)}/${_date(range.end)}',
      for (final (DateTime date, DividendEvent event) in dated)
        ..._eventLines(
          event: event,
          date: date,
          instrument: instruments[event.instrumentId],
          dateMode: dateMode,
          createdAt: createdAt,
        ),
      'END:VCALENDAR',
    ];
    final String contents = '${lines.expand(_fold).join('\r\n')}\r\n';
    return CalendarExportDocument(
      fileName:
          'dividendendackel-calendar-${_date(range.start)}-${_date(range.end.subtract(const Duration(days: 1)))}.ics',
      contents: contents,
      eventCount: dated.length,
    );
  }

  static List<String> _eventLines({
    required DividendEvent event,
    required DateTime date,
    required Instrument? instrument,
    required DividendDateMode dateMode,
    required DateTime createdAt,
  }) {
    final String name = instrument?.name ?? event.instrumentId;
    final String symbol = instrument?.displaySymbol ?? event.instrumentId;
    final String estimatePrefix = event.isEstimate ? '[ESTIMATE] ' : '';
    final String certainty = _statusLabel(event.status);
    final String description = <String>[
      'Instrument: $name ($symbol)',
      'Dividend per share: ${event.amountPerShare.amount} ${event.amountPerShare.currency.code}',
      'Date basis: ${_modeLabel(dateMode)}',
      'Certainty: $certainty',
      'Source: ${event.provenance.source}',
      if (event.isEstimate)
        'Estimate: This date or amount is not confirmed and may change.',
    ].join('\n');
    final String identity = <Object?>[
      dateMode.name,
      event.instrumentId,
      _date(date),
      event.amountPerShare.amount,
      event.amountPerShare.currency.code,
    ].join('|');
    final String uid = sha256.convert(utf8.encode(identity)).toString();
    final DateTime end = DateTime(date.year, date.month, date.day + 1);
    return <String>[
      'BEGIN:VEVENT',
      'UID:$uid@dividendendackel.local',
      'DTSTAMP:${_timestamp(createdAt)}',
      'DTSTART;VALUE=DATE:${_date(date)}',
      'DTEND;VALUE=DATE:${_date(end)}',
      'SUMMARY:${_escape('${estimatePrefix}Dividend: $name')}',
      'DESCRIPTION:${_escape(description)}',
      'STATUS:${event.isEstimate ? 'TENTATIVE' : 'CONFIRMED'}',
      'TRANSP:TRANSPARENT',
      'END:VEVENT',
    ];
  }

  static String _modeLabel(DividendDateMode mode) => switch (mode) {
    DividendDateMode.exDate => 'Ex-date',
    DividendDateMode.paymentDate => 'Payment date',
  };

  static String _statusLabel(DividendStatus status) => switch (status) {
    DividendStatus.confirmed => 'Confirmed',
    DividendStatus.announced => 'Announced',
    DividendStatus.expected => 'Expected (estimate)',
    DividendStatus.historicallyEstimated => 'Historically estimated',
    DividendStatus.unknown => 'Unconfirmed estimate',
  };

  static String _escape(String value) => value
      .replaceAll('\\', '\\\\')
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll('\n', '\\n')
      .replaceAll(';', '\\;')
      .replaceAll(',', '\\,');

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}'
      '${value.month.toString().padLeft(2, '0')}'
      '${value.day.toString().padLeft(2, '0')}';

  static String _timestamp(DateTime value) {
    final DateTime utc = value.toUtc();
    return '${_date(utc)}T'
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}'
        '${utc.second.toString().padLeft(2, '0')}Z';
  }

  /// Folds content lines at 75 UTF-8 octets without splitting a code point.
  static Iterable<String> _fold(String line) sync* {
    String current = '';
    int bytes = 0;
    int limit = 75;
    for (final int rune in line.runes) {
      final String character = String.fromCharCode(rune);
      final int characterBytes = utf8.encode(character).length;
      if (bytes + characterBytes > limit && current.isNotEmpty) {
        yield current;
        current = ' $character';
        bytes = 1 + characterBytes;
        limit = 75;
      } else {
        current += character;
        bytes += characterBytes;
      }
    }
    yield current;
  }
}
