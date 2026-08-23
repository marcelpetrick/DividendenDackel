import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/gross_net_amount.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/tax/tax_estimates.dart';
import 'package:dividendendackel/features/today/today_state.dart';
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
    final AsyncValue<List<DividendEvent>> next3Ex = ref.watch(
      upcomingDividendsProvider(3),
    );
    final AsyncValue<List<DividendEvent>> next3Payments = ref.watch(
      upcomingDividendPaymentsProvider(3),
    );
    final AsyncValue<List<DividendEvent>> next7 = ref.watch(
      upcomingDividendPaymentsProvider(7),
    );
    final AsyncValue<List<DividendEvent>> next30 = ref.watch(
      upcomingDividendPaymentsProvider(30),
    );
    final AsyncValue<List<DividendEvent>> next365 = ref.watch(
      upcomingDividendPaymentsProvider(365),
    );
    final AsyncValue<Map<String, Instrument>> instrumentValue = ref.watch(
      instrumentsByIdProvider,
    );
    final Map<String, Instrument> instruments =
        instrumentValue.value ?? const <String, Instrument>{};
    final AsyncValue<List<Holding>> holdings = ref.watch(holdingsProvider);
    final AsyncValue<Map<String, Quote>> quoteValue = ref.watch(quotesProvider);
    final Map<String, Quote> quotes =
        quoteValue.value ?? const <String, Quote>{};
    final Map<String, Holding> holdingsByInstrument = <String, Holding>{
      for (final Holding holding in holdings.value ?? const <Holding>[])
        holding.instrumentId: holding,
    };
    final DateTime now = ref.watch(clockProvider).now();
    final PortfolioOverview? overview = holdings.value == null
        ? null
        : const PortfolioOverviewCalculator().calculate(
            holdings: holdings.requireValue,
            instruments: instruments,
            quotes: quotes,
            dividends: next365.value ?? const <DividendEvent>[],
            asOf: now,
          );

    return ListView(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      children: <Widget>[
        _SummaryCard(
          holdingCount: holdings.value?.length,
          relevantCount: next3Ex.hasValue && next3Payments.hasValue
              ? next3Ex.requireValue.length + next3Payments.requireValue.length
              : null,
          overview: overview,
          quoteDataAvailable: quoteValue.hasValue,
        ),
        const SizedBox(height: AppTheme.space * 2),
        _TodayMattersCard(
          exEvents: next3Ex,
          paymentEvents: next3Payments,
          instruments: instruments,
          holdings: holdingsByInstrument,
          now: now,
        ),
        const SizedBox(height: AppTheme.space * 2),
        _NextThreeDaysCard(exEvents: next3Ex, paymentEvents: next3Payments),
        const SizedBox(height: AppTheme.space * 2),
        _ExpectedDividendsCard(
          next7: next7,
          next30: next30,
          next365: next365,
          holdings: holdings.value ?? const <Holding>[],
        ),
        const SizedBox(height: AppTheme.space * 2),
        _ChangesCard(changes: ref.watch(todayChangesProvider)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.holdingCount,
    required this.relevantCount,
    required this.overview,
    required this.quoteDataAvailable,
  });

  final int? holdingCount;
  final int? relevantCount;
  final PortfolioOverview? overview;
  final bool quoteDataAvailable;

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
              relevantCount == null
                  ? 'Loading the next 3 days…'
                  : '$relevantCount relevant dividend date(s) in the next 3 days',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.space),
            if (overview == null)
              const Text('Loading cached portfolio values…')
            else if (!quoteDataAvailable ||
                overview!.byCurrency.values.every(
                  (PortfolioCurrencySummary summary) =>
                      summary.pricedPositionCount == 0,
                ))
              const Text(
                'No cached quotes. Holdings and the dividend schedule below '
                'still work offline.',
              )
            else
              for (final PortfolioCurrencySummary summary
                  in overview!.byCurrency.values)
                if (summary.pricedPositionCount > 0)
                  Wrap(
                    spacing: AppTheme.space,
                    children: <Widget>[
                      MoneyText(
                        summary.totalValue,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        summary.dayChange == null
                            ? 'day change unavailable'
                            : '${summary.dayChange!.format(withSymbol: true)} today',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _TodayMattersCard extends StatelessWidget {
  const _TodayMattersCard({
    required this.exEvents,
    required this.paymentEvents,
    required this.instruments,
    required this.holdings,
    required this.now,
  });
  final AsyncValue<List<DividendEvent>> exEvents;
  final AsyncValue<List<DividendEvent>> paymentEvents;
  final Map<String, Instrument> instruments;
  final Map<String, Holding> holdings;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final List<_Matter> matters = <_Matter>[
      for (final DividendEvent event
          in exEvents.value ?? const <DividendEvent>[])
        if (event.exDate case final DateTime date)
          _Matter(event: event, date: date, kind: 'Ex-dividend'),
      for (final DividendEvent event
          in paymentEvents.value ?? const <DividendEvent>[])
        if (event.paymentDate case final DateTime date)
          _Matter(event: event, date: date, kind: 'Payment'),
    ]..sort((_Matter a, _Matter b) => a.date.compareTo(b.date));
    final bool loading = exEvents.isLoading || paymentEvents.isLoading;
    final bool failed = exEvents.hasError || paymentEvents.hasError;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Today matters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.space),
            if (failed)
              const Text(
                'Upcoming dates could not be refreshed. Cached portfolio and '
                'income figures remain available.',
              )
            else if (loading)
              const LinearProgressIndicator(semanticsLabel: 'Loading events')
            else if (matters.isEmpty)
              const Text('No dividend dates need attention in the next 3 days.')
            else
              for (final _Matter matter in matters.take(3))
                _MatterTile(
                  matter: matter,
                  instrument: instruments[matter.event.instrumentId],
                  holding: holdings[matter.event.instrumentId],
                  now: now,
                ),
          ],
        ),
      ),
    );
  }
}

final class _Matter {
  const _Matter({required this.event, required this.date, required this.kind});
  final DividendEvent event;
  final DateTime date;
  final String kind;
}

class _MatterTile extends StatelessWidget {
  const _MatterTile({
    required this.matter,
    required this.instrument,
    required this.holding,
    required this.now,
  });
  final _Matter matter;
  final Instrument? instrument;
  final Holding? holding;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final Money? gross = holding == null
        ? null
        : matter.event.grossPaymentFor(holding!.quantity);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        matter.kind == 'Payment'
            ? Icons.payments_outlined
            : Icons.event_available_outlined,
      ),
      title: Text(instrument?.name ?? matter.event.instrumentId),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${matter.kind} ${_relativeDay(matter.date, now)}'),
          if (gross != null) GrossNetAmount(event: matter.event, gross: gross),
        ],
      ),
      trailing: DividendStatusChip(matter.event.status),
    );
  }

  static String _relativeDay(DateTime value, DateTime now) {
    final DateTime day = DateTime(value.year, value.month, value.day);
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int difference = day.difference(today).inDays;
    return switch (difference) {
      0 => 'today',
      1 => 'tomorrow',
      _ => 'in $difference days',
    };
  }
}

class _NextThreeDaysCard extends StatelessWidget {
  const _NextThreeDaysCard({
    required this.exEvents,
    required this.paymentEvents,
  });
  final AsyncValue<List<DividendEvent>> exEvents;
  final AsyncValue<List<DividendEvent>> paymentEvents;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Next 3 days', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppTheme.space),
          Text(
            exEvents.hasError
                ? 'Ex-dividend dates: unavailable'
                : exEvents.value == null
                ? 'Ex-dividend dates: loading…'
                : '${exEvents.requireValue.length} ex-dividend date(s)',
          ),
          Text(
            paymentEvents.hasError
                ? 'Payments: unavailable'
                : paymentEvents.value == null
                ? 'Payments: loading…'
                : '${paymentEvents.requireValue.length} payment date(s)',
          ),
        ],
      ),
    ),
  );
}

class _ChangesCard extends StatelessWidget {
  const _ChangesCard({required this.changes});
  final AsyncValue<TodayChanges> changes;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Changes since last refresh',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.space),
          switch (changes) {
            AsyncData<TodayChanges>(:final TodayChanges value)
                when value.isFirstSnapshot =>
              const Text(
                'Baseline saved on this device. Changes will appear after the '
                'next data refresh.',
              ),
            AsyncData<TodayChanges>(:final TodayChanges value)
                when !value.hasChanges =>
              Text(
                'No portfolio, quote or dividend-outlook changes since '
                '${_dateTime(context, value.previousAt!)}.',
              ),
            AsyncData<TodayChanges>(:final TodayChanges value) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('${value.holdingChanges} holding change(s)'),
                Text('${value.quoteChanges} quote change(s)'),
                Text('${value.dividendChanges} dividend-outlook change(s)'),
                Text(
                  'Compared with ${_dateTime(context, value.previousAt!)}.',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            AsyncError<TodayChanges>() => const Text(
              'Could not update the local comparison. Current portfolio and '
              'dividend data remain available above.',
            ),
            _ => const LinearProgressIndicator(
              semanticsLabel: 'Comparing refresh changes',
            ),
          },
        ],
      ),
    ),
  );

  static String _dateTime(BuildContext context, DateTime value) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return '${localizations.formatMediumDate(value)} at '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(value))}';
  }
}

class _ExpectedDividendsCard extends ConsumerWidget {
  const _ExpectedDividendsCard({
    required this.next7,
    required this.next30,
    required this.next365,
    required this.holdings,
  });

  final AsyncValue<List<DividendEvent>> next7;
  final AsyncValue<List<DividendEvent>> next30;
  final AsyncValue<List<DividendEvent>> next365;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Expected dividends', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppTheme.space),
            _row(context, ref, 'Next 7 days', next7),
            const SizedBox(height: AppTheme.space / 2),
            _row(context, ref, 'Next 30 days', next30),
            const SizedBox(height: AppTheme.space / 2),
            _row(context, ref, 'Next 365 days', next365),
            const SizedBox(height: AppTheme.space),
            Text(
              'Gross and estimated net are never combined. Forecast events '
              'are included and marked. Estimate—not tax advice.',
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
    WidgetRef ref,
    String label,
    AsyncValue<List<DividendEvent>> events,
  ) {
    final ThemeData theme = Theme.of(context);
    final Map<Currency, Money>? totals = events.value == null
        ? null
        : _expected(events.requireValue);
    final _ExpectedNet? estimatedNet = events.value == null
        ? null
        : _net(ref, events.requireValue);

    final Widget value = events.hasError
        ? Text('Unavailable', style: theme.textTheme.bodyMedium)
        : totals == null
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
                Text(
                  'Gross ${total.format(withSymbol: true)}',
                  style: theme.textTheme.titleSmall,
                ),
              if (estimatedNet?.loading ?? false)
                const Text('Net (estimated) calculating…')
              else if (estimatedNet != null)
                Text(
                  'Net (estimated) '
                  '${estimatedNet.netEur.format(withSymbol: true)}',
                  style: theme.textTheme.titleSmall,
                ),
              if ((estimatedNet?.unsupportedCount ?? 0) > 0)
                Text(
                  '${estimatedNet!.unsupportedCount} need a payment date, '
                  'EUR FX, or country data',
                  style: theme.textTheme.labelSmall,
                ),
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

  _ExpectedNet _net(WidgetRef ref, List<DividendEvent> events) {
    final Set<int> years = <int>{
      for (final DividendEvent event in events)
        if (event.paymentDate != null) event.paymentDate!.year,
    };
    final List<AsyncValue<PortfolioTaxEstimates>> annual =
        <AsyncValue<PortfolioTaxEstimates>>[
          for (final int year in years)
            ref.watch(portfolioTaxEstimatesProvider(year)),
        ];
    final bool loading = annual.any((value) => !value.hasValue);
    final Map<String, TaxEventEstimate> estimates = <String, TaxEventEstimate>{
      for (final AsyncValue<PortfolioTaxEstimates> value in annual)
        if (value.value case final estimate?) ...estimate.byEventKey,
    };
    Money net = Money.zero(Currency.eur);
    int unsupported = 0;
    for (final DividendEvent event in events) {
      if (!holdings.any(
        (holding) => holding.instrumentId == event.instrumentId,
      )) {
        continue;
      }
      switch (estimates[dividendTaxEventKey(event)]?.result) {
        case DividendTaxBreakdown(net: final Money payment):
          net += payment;
        case UnsupportedTaxCalculation():
          unsupported++;
        case null:
          if (!loading) unsupported++;
      }
    }
    return _ExpectedNet(
      loading: loading,
      netEur: net,
      unsupportedCount: unsupported,
    );
  }
}

final class _ExpectedNet {
  const _ExpectedNet({
    required this.loading,
    required this.netEur,
    required this.unsupportedCount,
  });
  final bool loading;
  final Money netEur;
  final int unsupportedCount;
}
