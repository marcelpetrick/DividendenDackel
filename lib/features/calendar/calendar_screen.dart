import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The dividend calendar (Vision.md §9).
///
/// Currently the agenda view only; the month and year views and the
/// ex-date/payment-date toggle land with task D4.
class CalendarScreen extends ConsumerWidget {
  /// Creates the calendar screen.
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<DividendEvent>> events = ref.watch(
      upcomingDividendsProvider(365),
    );
    final Map<String, Instrument> instruments =
        ref.watch(instrumentsByIdProvider).value ??
        const <String, Instrument>{};
    final Map<String, Holding> holdings = <String, Holding>{
      for (final Holding h
          in ref.watch(holdingsProvider).value ?? const <Holding>[])
        h.instrumentId: h,
    };

    return AsyncValueView<List<DividendEvent>>(
      value: events,
      isEmpty: (List<DividendEvent> data) => data.isEmpty,
      emptyTitle: 'No dividend events',
      emptyMessage: 'Nothing is scheduled for the instruments you follow.',
      emptyIcon: Icons.calendar_month_outlined,
      builder: (BuildContext context, List<DividendEvent> data) =>
          ListView.separated(
            itemCount: data.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) => DividendEventTile(
              event: data[index],
              instrument: instruments[data[index].instrumentId],
              holding: holdings[data[index].instrumentId],
            ),
          ),
    );
  }
}
