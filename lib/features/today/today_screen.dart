import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The central product experience (Vision.md §7).
///
/// Answers what matters today and what happens next. It must stay useful when
/// live quotes are unavailable, so every figure here degrades to "not known
/// yet" rather than to zero.
class TodayScreen extends ConsumerWidget {
  /// Creates the Today screen.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<DividendEvent>> next7 = ref.watch(
      upcomingDividendsProvider(7),
    );
    final AsyncValue<List<DividendEvent>> next30 = ref.watch(
      upcomingDividendsProvider(30),
    );
    final Map<String, Instrument> instruments =
        ref.watch(instrumentsByIdProvider).value ??
        const <String, Instrument>{};
    final AsyncValue<List<Holding>> holdings = ref.watch(holdingsProvider);

    return ListView(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      children: <Widget>[
        _SummaryCard(
          holdingCount: holdings.value?.length,
          upcomingCount: next7.value?.length,
        ),
        const SizedBox(height: AppTheme.space * 2),
        _ExpectedDividendsCard(
          next7: next7,
          next30: next30,
          holdings: holdings.value ?? const <Holding>[],
        ),
        const SizedBox(height: AppTheme.space * 2),
        Text('Next 7 days', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppTheme.space),
        SizedBox(
          height: 300,
          child: AsyncValueView<List<DividendEvent>>(
            value: next7,
            isEmpty: (List<DividendEvent> data) => data.isEmpty,
            emptyTitle: 'Nothing in the next 7 days',
            emptyMessage:
                'No ex-dividend dates are coming up for your '
                'holdings or watchlist.',
            emptyIcon: Icons.event_available_outlined,
            builder: (BuildContext context, List<DividendEvent> data) =>
                ListView.separated(
                  itemCount: data.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) =>
                      DividendEventTile(
                        event: data[index],
                        instrument: instruments[data[index].instrumentId],
                      ),
                ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.holdingCount, required this.upcomingCount});

  final int? holdingCount;
  final int? upcomingCount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Portfolio today', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.space),
            Text(
              holdingCount == null
                  ? 'Loading your holdings…'
                  : '$holdingCount holdings',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              upcomingCount == null
                  ? ''
                  : '$upcomingCount dividend events in the next 7 days',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpectedDividendsCard extends StatelessWidget {
  const _ExpectedDividendsCard({
    required this.next7,
    required this.next30,
    required this.holdings,
  });

  final AsyncValue<List<DividendEvent>> next7;
  final AsyncValue<List<DividendEvent>> next30;
  final List<Holding> holdings;

  /// Sums the gross payments due to the user, grouped by currency.
  ///
  /// Grouped rather than totalled because amounts in different currencies must
  /// never be silently combined (Vision.md §45). Until an FX rate with its own
  /// provenance exists, each currency is reported on its own line.
  Map<Currency, Money> _expected(List<DividendEvent> events) {
    final Map<String, Holding> byInstrument = <String, Holding>{
      for (final Holding h in holdings) h.instrumentId: h,
    };
    final Map<Currency, Money> totals = <Currency, Money>{};

    for (final DividendEvent event in events) {
      final Holding? holding = byInstrument[event.instrumentId];
      if (holding == null) {
        continue;
      }
      final Money payment = event.grossPaymentFor(holding.quantity);
      totals[payment.currency] =
          (totals[payment.currency] ?? Money.zero(payment.currency)) + payment;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Expected dividends', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.space),
            _row(context, 'Next 7 days', next7),
            const SizedBox(height: AppTheme.space / 2),
            _row(context, 'Next 30 days', next30),
            const SizedBox(height: AppTheme.space),
            Text(
              'Gross, before tax. Estimated events are included and marked.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    AsyncValue<List<DividendEvent>> events,
  ) {
    final ThemeData theme = Theme.of(context);
    final Map<Currency, Money>? totals = events.value == null
        ? null
        : _expected(events.requireValue);

    final Widget value = totals == null
        ? Text('…', style: theme.textTheme.bodyMedium)
        : totals.isEmpty
        ? Text(
            'none',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (final Money total in totals.values)
                MoneyText(total, style: theme.textTheme.titleSmall),
            ],
          );
    final bool useVerticalLayout =
        MediaQuery.textScalerOf(context).scale(16) >= 24;

    if (useVerticalLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppTheme.space / 4),
          Align(alignment: Alignment.centerRight, child: value),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        const SizedBox(width: AppTheme.space),
        value,
      ],
    );
  }
}

/// One dividend event in a list.
class DividendEventTile extends StatelessWidget {
  /// Creates a tile for [event].
  const DividendEventTile({
    required this.event,
    required this.instrument,
    this.holding,
    super.key,
  });

  /// The event to show.
  final DividendEvent event;

  /// The paying instrument, when known.
  final Instrument? instrument;

  /// The user's position, used to show the expected payment.
  final Holding? holding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Holding? holding = this.holding;
    final Money? payment = holding == null
        ? null
        : event.grossPaymentFor(holding.quantity);

    return ListTile(
      title: Text(instrument?.name ?? event.instrumentId),
      // Wrap rather than Row: on a narrow phone the amount and the status
      // label together exceed the tile's subtitle width and would clip.
      subtitle: Wrap(
        spacing: AppTheme.space,
        runSpacing: AppTheme.space / 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            '${event.amountPerShare.format(withSymbol: true)} / share',
            style: theme.textTheme.bodySmall,
          ),
          DividendStatusChip(event.status),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (event.exDate != null)
            Text(_formatDate(event.exDate!), style: theme.textTheme.bodyMedium),
          if (payment != null)
            MoneyText(payment, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String _formatDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]}';
}
