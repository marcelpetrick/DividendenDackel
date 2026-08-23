import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter/material.dart';

/// Explainable, currency-separated ledger performance and cash-flow detail.
class PortfolioPerformanceCard extends StatefulWidget {
  /// Creates the performance card.
  const PortfolioPerformanceCard({
    required this.activities,
    required this.scopeId,
    required this.valuations,
    required this.overview,
    required this.instruments,
    required this.asOf,
    super.key,
  });

  /// Active and reversed immutable ledger rows.
  final List<PortfolioActivity> activities;

  /// Portfolio or explicit consolidated identity for valuation evidence.
  final String scopeId;

  /// Locally accumulated portfolio value evidence.
  final List<PortfolioValuationSnapshot> valuations;

  /// Current native-currency portfolio values.
  final PortfolioOverview overview;

  /// Instrument metadata used only to establish native currencies.
  final Map<String, Instrument> instruments;

  /// Current calculation date.
  final DateTime asOf;

  @override
  State<PortfolioPerformanceCard> createState() =>
      _PortfolioPerformanceCardState();
}

class _PortfolioPerformanceCardState extends State<PortfolioPerformanceCard> {
  PerformanceGrouping _grouping = PerformanceGrouping.monthly;

  @override
  Widget build(BuildContext context) {
    final Map<String, Currency> instrumentCurrencies = <String, Currency>{
      for (final Instrument instrument in widget.instruments.values)
        instrument.internalId: instrument.currency,
    };
    final Map<Currency, Money> currentValues = <Currency, Money>{
      for (final PortfolioCurrencySummary summary
          in widget.overview.byCurrency.values)
        summary.currency: summary.totalValue,
    };
    final Set<Currency> completeCurrencies = <Currency>{
      for (final PortfolioCurrencySummary summary
          in widget.overview.byCurrency.values)
        if (summary.isComplete) summary.currency,
    };
    final Set<Currency> currentHoldingCurrencies = <Currency>{
      for (final PortfolioPositionSummary position in widget.overview.positions)
        if (position.value case final Money value)
          value.currency
        else if (position.instrument case final Instrument instrument)
          instrument.currency,
    };
    final Set<String> currentHoldingInstrumentIds = <String>{
      for (final PortfolioPositionSummary position in widget.overview.positions)
        position.holding.instrumentId,
    };
    for (final PortfolioActivity activity in widget.activities) {
      final Currency? currency =
          activity.unitPrice?.currency ??
          activity.cashAmount?.currency ??
          (activity.instrumentId == null
              ? null
              : instrumentCurrencies[activity.instrumentId]);
      if (currency != null &&
          currentHoldingInstrumentIds.contains(activity.instrumentId)) {
        currentHoldingCurrencies.add(currency);
      }
    }
    for (final PortfolioActivity activity in widget.activities) {
      final Currency? currency =
          activity.unitPrice?.currency ??
          activity.cashAmount?.currency ??
          (activity.instrumentId == null
              ? null
              : instrumentCurrencies[activity.instrumentId]);
      if (currency != null && !currentValues.containsKey(currency)) {
        currentValues[currency] = Money.zero(currency);
        if (!currentHoldingCurrencies.contains(currency)) {
          completeCurrencies.add(currency);
        }
      }
    }
    final List<PortfolioValuationSnapshot> currentValuations =
        PortfolioPerformanceCalculator.currentValuations(
          scopeId: widget.scopeId,
          overview: widget.overview,
          activities: widget.activities,
          instrumentCurrencies: instrumentCurrencies,
        );
    final Map<Currency, DateTime> currentValuationDates = <Currency, DateTime>{
      for (final PortfolioValuationSnapshot valuation in currentValuations)
        if (valuation.isComplete) valuation.currency: valuation.observedAt,
      for (final Currency currency in currentValues.keys)
        if (!currentHoldingCurrencies.contains(currency))
          currency: DateTime.utc(
            widget.asOf.year,
            widget.asOf.month,
            widget.asOf.day,
          ),
    };
    final PortfolioPerformanceReport report =
        PortfolioPerformanceCalculator.calculate(
          activities: widget.activities,
          instrumentCurrencies: instrumentCurrencies,
          valuations: widget.valuations,
          currentValues: currentValues,
          completeValueCurrencies: completeCurrencies,
          currentValuationDates: currentValuationDates,
          asOf: widget.asOf,
          grouping: _grouping,
          periodCount: _periodCount(_grouping),
        );
    final ThemeData theme = Theme.of(context);
    return Card(
      key: const ValueKey<String>('portfolio-performance'),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.query_stats_outlined),
                const SizedBox(width: AppTheme.space),
                Expanded(
                  child: Text('Performance', style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space / 2),
            const Text(
              'Security-only total return. Purchases and opening balances are '
              'capital in; sales and actual dividends are capital out; taxes '
              'and fees are costs. Cash deposits and withdrawals are shown but '
              'excluded because this app does not value a cash balance.',
            ),
            const SizedBox(height: AppTheme.space),
            if (report.byCurrency.isEmpty)
              const Text(
                'Record a valued purchase or cache a position quote to start '
                'performance coverage.',
              )
            else
              for (final PortfolioCurrencyPerformance performance
                  in report.byCurrency.values) ...<Widget>[
                _CurrencyPerformance(performance: performance),
                const SizedBox(height: AppTheme.space),
              ],
            const Divider(height: AppTheme.space * 3),
            Wrap(
              spacing: AppTheme.space,
              runSpacing: AppTheme.space / 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text('Cash-flow detail', style: theme.textTheme.titleMedium),
                SegmentedButton<PerformanceGrouping>(
                  key: const ValueKey<String>('performance-grouping'),
                  showSelectedIcon: false,
                  segments: const <ButtonSegment<PerformanceGrouping>>[
                    ButtonSegment<PerformanceGrouping>(
                      value: PerformanceGrouping.monthly,
                      label: Text('Month'),
                    ),
                    ButtonSegment<PerformanceGrouping>(
                      value: PerformanceGrouping.quarterly,
                      label: Text('Quarter'),
                    ),
                    ButtonSegment<PerformanceGrouping>(
                      value: PerformanceGrouping.annual,
                      label: Text('Year'),
                    ),
                  ],
                  selected: <PerformanceGrouping>{_grouping},
                  onSelectionChanged: (Set<PerformanceGrouping> selection) =>
                      setState(() => _grouping = selection.single),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space / 2),
            for (final PortfolioCurrencyPerformance performance
                in report.byCurrency.values)
              _PeriodDetail(performance: performance, grouping: _grouping),
          ],
        ),
      ),
    );
  }

  static int _periodCount(PerformanceGrouping grouping) => switch (grouping) {
    PerformanceGrouping.monthly => 12,
    PerformanceGrouping.quarterly => 8,
    PerformanceGrouping.annual => 5,
  };
}

class _CurrencyPerformance extends StatelessWidget {
  const _CurrencyPerformance({required this.performance});

  final PortfolioCurrencyPerformance performance;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${performance.currency.code} return',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.space / 2),
            Wrap(
              spacing: AppTheme.space * 3,
              runSpacing: AppTheme.space,
              children: <Widget>[
                _Metric(
                  label: 'XIRR · money-weighted',
                  metric: performance.xirr,
                  annualized: true,
                ),
                _Metric(
                  label: 'TTWROR · time-weighted',
                  metric: performance.ttwror,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space / 2),
            Text(
              'Current covered value: ${performance.currentValue.format()}'
              '${performance.currentValueComplete ? '' : ' · incomplete'}',
            ),
            const SizedBox(height: AppTheme.space / 2),
            Text(
              PortfolioPerformanceCalculator.xirrFormula,
              style: theme.textTheme.bodySmall,
            ),
            Text(
              PortfolioPerformanceCalculator.ttwrorFormula,
              style: theme.textTheme.bodySmall,
            ),
            for (final String limitation in performance.limitations)
              Text('• $limitation', style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.metric,
    this.annualized = false,
  });

  final String label;
  final PortfolioReturnMetric? metric;
  final bool annualized;

  @override
  Widget build(BuildContext context) {
    final PortfolioReturnMetric? value = metric;
    return SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          Text(
            value == null
                ? 'Unavailable'
                : '${value.rate.format(decimals: 2, withSign: true)}${annualized ? ' p.a.' : ''}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (value != null)
            Text(
              '${_date(value.start)} – ${_date(value.end)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _PeriodDetail extends StatelessWidget {
  const _PeriodDetail({required this.performance, required this.grouping});

  final PortfolioCurrencyPerformance performance;
  final PerformanceGrouping grouping;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    childrenPadding: EdgeInsets.zero,
    title: Text('${performance.currency.code} ${_groupLabel(grouping)} detail'),
    subtitle: const Text(
      'Purchases · sales · dividends · taxes · fees · net invested',
    ),
    children: <Widget>[
      for (final PerformancePeriodBreakdown period in performance.periods)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_periodLabel(period, grouping)),
          subtitle: Text(
            'Purchases ${period.purchases.format()} · '
            'Sales ${period.sales.format()} · '
            'Dividends ${period.dividends.format()} · '
            'Taxes ${period.taxes.format()} · Fees ${period.fees.format()}\n'
            'Deposits ${period.deposits.format()} · '
            'Withdrawals ${period.withdrawals.format()} · '
            'Net invested ${period.netInvested.format()}'
            '${period.isComplete ? '' : ' · incomplete activity values'}',
          ),
        ),
    ],
  );

  static String _groupLabel(PerformanceGrouping grouping) => switch (grouping) {
    PerformanceGrouping.monthly => 'monthly',
    PerformanceGrouping.quarterly => 'quarterly',
    PerformanceGrouping.annual => 'annual',
  };

  static String _periodLabel(
    PerformancePeriodBreakdown period,
    PerformanceGrouping grouping,
  ) => switch (grouping) {
    PerformanceGrouping.monthly =>
      '${_months[period.start.month - 1]} ${period.start.year}',
    PerformanceGrouping.quarterly =>
      'Q${((period.start.month - 1) ~/ 3) + 1} ${period.start.year}',
    PerformanceGrouping.annual => '${period.start.year}',
  };
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

const List<String> _months = <String>[
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
