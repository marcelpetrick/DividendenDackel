import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Calendar presentation modes required by Vision.md §9.
enum DividendCalendarView { month, year, agenda }

/// Which collection contributes events to the calendar.
enum DividendCalendarScope { portfolio, watchlist, all }

/// Pure calendar calculations shared by the screen and its tests.
abstract final class DividendCalendarMath {
  /// Removes the time component without changing the represented local day.
  static DateTime day(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Range needed by one calendar view around [focus].
  static DateRange visibleRange(DateTime focus, DividendCalendarView view) =>
      switch (view) {
        DividendCalendarView.month => DateRange(
          DateTime(focus.year, focus.month),
          DateTime(focus.year, focus.month + 1),
        ),
        DividendCalendarView.year => DateRange(
          DateTime(focus.year),
          DateTime(focus.year + 1),
        ),
        DividendCalendarView.agenda => DateRange(
          day(focus),
          day(focus).add(const Duration(days: 365)),
        ),
      };

  /// Groups events by the date currently organizing the calendar.
  static Map<DateTime, List<DividendEvent>> groupByDay(
    Iterable<DividendEvent> events,
    DividendDateMode mode,
  ) {
    final Map<DateTime, List<DividendEvent>> result =
        <DateTime, List<DividendEvent>>{};
    for (final DividendEvent event in events) {
      final DateTime? date = event.dateFor(mode);
      if (date != null) {
        result.putIfAbsent(day(date), () => <DividendEvent>[]).add(event);
      }
    }
    return result;
  }

  /// Calendar cells covering a month, padded to whole display weeks.
  static List<DateTime> monthCells(DateTime focus, {required bool weekends}) {
    final DateTime first = DateTime(focus.year, focus.month);
    final DateTime last = DateTime(focus.year, focus.month + 1, 0);
    DateTime cursor = first.subtract(Duration(days: first.weekday - 1));
    final List<DateTime> cells = <DateTime>[];
    while (!cursor.isAfter(last) || cells.length % (weekends ? 7 : 5) != 0) {
      if (weekends || cursor.weekday <= DateTime.friday) {
        cells.add(cursor);
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return cells;
  }
}

/// Stable query identity for a reactive calendar range.
final class CalendarEventsQuery {
  /// Creates a calendar query.
  CalendarEventsQuery({
    required this.range,
    required this.dateMode,
    Set<String>? instrumentIds,
  }) : instrumentIds = instrumentIds == null
           ? null
           : Set<String>.unmodifiable(instrumentIds);

  /// Half-open visible date range.
  final DateRange range;

  /// Ex-date or payment-date organization.
  final DividendDateMode dateMode;

  /// Included instruments, or `null` for every known instrument.
  final Set<String>? instrumentIds;

  @override
  bool operator ==(Object other) =>
      other is CalendarEventsQuery &&
      other.range == range &&
      other.dateMode == dateMode &&
      _sameIds(other.instrumentIds, instrumentIds);

  @override
  int get hashCode {
    final List<String> sorted = instrumentIds?.toList() ?? <String>[];
    sorted.sort();
    return Object.hash(range, dateMode, Object.hashAll(sorted));
  }

  static bool _sameIds(Set<String>? left, Set<String>? right) {
    if (left == null || right == null) {
      return left == right;
    }
    return left.length == right.length && left.containsAll(right);
  }
}

/// Dividend events for one visible calendar query.
final calendarEventsProvider =
    StreamProvider.family<List<DividendEvent>, CalendarEventsQuery>(
      (Ref ref, CalendarEventsQuery query) => ref
          .watch(dividendRepositoryProvider)
          .watchInRange(
            query.range,
            query.dateMode,
            instrumentIds: query.instrumentIds,
          ),
    );
