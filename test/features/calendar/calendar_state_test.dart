import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/features/calendar/calendar_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DividendCalendarMath', () {
    test('builds exact month, year and rolling agenda ranges', () {
      final DateTime focus = DateTime(2026, 8, 23, 15);

      expect(
        DividendCalendarMath.visibleRange(
          focus,
          DividendCalendarView.month,
        ).start,
        DateTime(2026, 8),
      );
      expect(
        DividendCalendarMath.visibleRange(
          focus,
          DividendCalendarView.month,
        ).end,
        DateTime(2026, 9),
      );
      expect(
        DividendCalendarMath.visibleRange(focus, DividendCalendarView.year).end,
        DateTime(2027),
      );
      expect(
        DividendCalendarMath.visibleRange(
          focus,
          DividendCalendarView.agenda,
        ).end,
        DateTime(2027, 8, 23),
      );
    });

    test('removes weekend columns while retaining complete work weeks', () {
      final List<DateTime> withWeekends = DividendCalendarMath.monthCells(
        DateTime(2026, 8),
        weekends: true,
      );
      final List<DateTime> weekdays = DividendCalendarMath.monthCells(
        DateTime(2026, 8),
        weekends: false,
      );

      expect(withWeekends.length % 7, 0);
      expect(weekdays.length % 5, 0);
      expect(weekdays, everyElement(predicate<DateTime>((d) => d.weekday < 6)));
      expect(weekdays, contains(DateTime(2026, 8, 31)));
    });

    test(
      'query identity ignores set order but distinguishes all from none',
      () {
        final Set<String> ids = <String>{'a', 'b'};
        final CalendarEventsQuery left = CalendarEventsQuery(
          range: DateRange(DateTime(2026), DateTime(2027)),
          dateMode: DividendDateMode.exDate,
          instrumentIds: ids,
        );
        final CalendarEventsQuery right = CalendarEventsQuery(
          range: DateRange(DateTime(2026), DateTime(2027)),
          dateMode: DividendDateMode.exDate,
          instrumentIds: <String>{'b', 'a'},
        );

        expect(left, right);
        expect(left.hashCode, right.hashCode);
        ids.add('later');
        expect(left.instrumentIds, <String>{'a', 'b'});
        expect(
          left,
          isNot(
            CalendarEventsQuery(
              range: DateRange(DateTime(2026), DateTime(2027)),
              dateMode: DividendDateMode.exDate,
            ),
          ),
        );
      },
    );
  });
}
