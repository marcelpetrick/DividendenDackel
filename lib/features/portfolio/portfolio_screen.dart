import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/app/widgets/gross_net_amount.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/portfolio/add_instrument_dialog.dart';
import 'package:dividendendackel/features/tax/tax_estimates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Portfolio value, income and collection management (Vision.md §8).
class PortfolioScreen extends ConsumerWidget {
  /// Creates the portfolio screen.
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Holding>> holdings = ref.watch(holdingsProvider);
    final List<WatchlistEntry> watchlist =
        ref.watch(watchlistProvider).value ?? const <WatchlistEntry>[];
    final Map<String, Instrument> instruments =
        ref.watch(instrumentsByIdProvider).value ??
        const <String, Instrument>{};
    final Map<String, Quote> quotes =
        ref.watch(quotesProvider).value ?? const <String, Quote>{};
    final AsyncValue<List<DividendEvent>> dividendData = ref.watch(
      upcomingDividendsProvider(365),
    );
    final List<DividendEvent> dividends =
        dividendData.value ?? const <DividendEvent>[];
    final DateTime now = ref.watch(clockProvider).now();
    final AsyncValue<PortfolioTaxEstimates> currentTax = ref.watch(
      portfolioTaxEstimatesProvider(now.year),
    );
    final AsyncValue<PortfolioTaxEstimates> nextTax = ref.watch(
      portfolioTaxEstimatesProvider(now.year + 1),
    );

    return Scaffold(
      body: AsyncValueView<List<Holding>>(
        value: holdings,
        builder: (BuildContext context, List<Holding> data) {
          final PortfolioOverview overview = const PortfolioOverviewCalculator()
              .calculate(
                holdings: data,
                instruments: instruments,
                quotes: quotes,
                dividends: dividends,
                asOf: now,
              );
          final _TaxWindow taxWindow = _taxWindow(
            dividends,
            <AsyncValue<PortfolioTaxEstimates>>[currentTax, nextTax],
            <String>{for (final Holding holding in data) holding.instrumentId},
          );
          return _PortfolioBody(
            overview: overview,
            watchlist: watchlist,
            instruments: instruments,
            dividendDataAvailable: dividendData.hasValue,
            taxWindow: taxWindow,
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey<String>('add-instrument'),
        onPressed: () => _showAddInstrument(context),
        icon: const Icon(Icons.add),
        label: const Text('Add instrument'),
      ),
    );
  }

  Future<void> _showAddInstrument(BuildContext context) async {
    final String? message = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => const AddInstrumentDialog(),
    );
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _PortfolioBody extends StatelessWidget {
  const _PortfolioBody({
    required this.overview,
    required this.watchlist,
    required this.instruments,
    required this.dividendDataAvailable,
    required this.taxWindow,
  });

  final PortfolioOverview overview;
  final List<WatchlistEntry> watchlist;
  final Map<String, Instrument> instruments;
  final bool dividendDataAvailable;
  final _TaxWindow taxWindow;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(
      AppTheme.space * 2,
      AppTheme.space * 2,
      AppTheme.space * 2,
      AppTheme.space * 10,
    ),
    children: <Widget>[
      Text('Overview', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppTheme.space),
      if (overview.byCurrency.isEmpty)
        const _EmptyPortfolioCard()
      else
        Wrap(
          spacing: AppTheme.space,
          runSpacing: AppTheme.space,
          children: <Widget>[
            for (final PortfolioCurrencySummary summary
                in overview.byCurrency.values)
              _CurrencySummaryCard(
                summary: summary,
                dividendDataAvailable: dividendDataAvailable,
                taxWindow: taxWindow,
              ),
          ],
        ),
      const SizedBox(height: AppTheme.space * 2),
      Text('Holdings', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppTheme.space),
      if (overview.positions.isEmpty)
        Text(
          'No holdings yet. Add an instrument to start tracking its value and dividends.',
          style: Theme.of(context).textTheme.bodyMedium,
        )
      else
        for (final PortfolioPositionSummary position in overview.positions)
          _PositionCard(
            position: position,
            dividendDataAvailable: dividendDataAvailable,
          ),
      const SizedBox(height: AppTheme.space * 2),
      Text('Watchlist', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppTheme.space),
      if (watchlist.isEmpty)
        Text(
          'No watchlist entries yet.',
          style: Theme.of(context).textTheme.bodyMedium,
        )
      else
        Card(
          child: Column(
            children: <Widget>[
              for (final WatchlistEntry entry in watchlist)
                ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: Text(
                    instruments[entry.instrumentId]?.name ?? entry.instrumentId,
                  ),
                  subtitle: Text(
                    instruments[entry.instrumentId]?.displaySymbol ??
                        'Instrument metadata unavailable',
                  ),
                ),
            ],
          ),
        ),
    ],
  );
}

class _EmptyPortfolioCard extends StatelessWidget {
  const _EmptyPortfolioCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(AppTheme.space * 2),
      child: Row(
        children: <Widget>[
          Icon(Icons.pie_chart_outline),
          SizedBox(width: AppTheme.space),
          Expanded(
            child: Text(
              'Add a holding to see portfolio value, day change, allocation, yield and the next dividend.',
            ),
          ),
        ],
      ),
    ),
  );
}

class _CurrencySummaryCard extends StatelessWidget {
  const _CurrencySummaryCard({
    required this.summary,
    required this.dividendDataAvailable,
    required this.taxWindow,
  });

  final PortfolioCurrencySummary summary;
  final bool dividendDataAvailable;
  final _TaxWindow taxWindow;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: 310,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${summary.currency.code} portfolio',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.space),
              if (summary.pricedPositionCount == 0)
                Text('No priced value', style: theme.textTheme.headlineSmall)
              else
                MoneyText(
                  summary.totalValue,
                  style: theme.textTheme.headlineSmall,
                ),
              Text(
                summary.isComplete
                    ? '${summary.positionCount} priced holdings'
                    : '${summary.pricedPositionCount} of '
                          '${summary.positionCount} holdings priced',
                style: theme.textTheme.labelSmall,
              ),
              const Divider(height: AppTheme.space * 2),
              _SummaryRow(
                label: 'Day change',
                value: summary.dayChange == null
                    ? const Text('Not available')
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MoneyText(
                            summary.dayChange!,
                            showSign: true,
                            colorBySign: true,
                          ),
                          if (summary.dayChangePercent != null)
                            Text(
                              ' · ${summary.dayChangePercent!.format(withSign: true)}',
                            ),
                        ],
                      ),
              ),
              _SummaryRow(
                label: 'Next 365 days',
                value: dividendDataAvailable
                    ? MoneyText(summary.forecastAnnualDividend)
                    : const Text('Loading…'),
              ),
              _SummaryRow(
                label: 'Net (estimated)',
                value: !dividendDataAvailable || taxWindow.loading
                    ? const Text('Calculating…')
                    : summary.currency != Currency.eur
                    ? const Text('Needs dated EUR FX')
                    : Text(
                        '${taxWindow.netEur.format(withSymbol: true)}'
                        '${taxWindow.unsupportedCount == 0 ? '' : ' + ${taxWindow.unsupportedCount} unavailable'}',
                      ),
              ),
              _SummaryRow(
                label: 'Forward gross yield',
                value: Text(
                  dividendDataAvailable
                      ? summary.forwardYield?.format() ?? 'Not available'
                      : 'Loading…',
                ),
              ),
              Text(
                'Estimate—not tax advice.',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final bool stack =
          constraints.maxWidth < 360 ||
          MediaQuery.textScalerOf(context).scale(16) >= 24;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.space / 2),
        child: stack
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(label),
                  const SizedBox(height: AppTheme.space / 4),
                  Align(alignment: Alignment.centerRight, child: value),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Text(label)),
                  const SizedBox(width: AppTheme.space),
                  Flexible(child: value),
                ],
              ),
      );
    },
  );
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({
    required this.position,
    required this.dividendDataAvailable,
  });

  final PortfolioPositionSummary position;
  final bool dividendDataAvailable;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Instrument? instrument = position.instrument;
    final PositionDividend? next = position.nextDividend;
    return Card(
      key: ValueKey<String>('holding-${position.holding.instrumentId}'),
      margin: const EdgeInsets.only(bottom: AppTheme.space),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        instrument?.name ?? position.holding.instrumentId,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        '${instrument?.displaySymbol ?? ''} · '
                        '${position.holding.quantity} shares',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (position.value != null)
                  MoneyText(position.value!, style: theme.textTheme.titleMedium)
                else
                  const Text('No price yet'),
              ],
            ),
            const SizedBox(height: AppTheme.space),
            Wrap(
              spacing: AppTheme.space * 2,
              runSpacing: AppTheme.space / 2,
              children: <Widget>[
                _TextMetric(
                  label: 'Day change',
                  value: position.dayChange == null
                      ? 'Not available'
                      : '${position.dayChange!.format(withSymbol: true)} '
                            '(${position.dayChangePercent?.format(withSign: true) ?? '—'})',
                ),
                _TextMetric(
                  label:
                      'Allocation in ${instrument?.currency.code ?? 'currency'}',
                  value: position.allocation?.format() ?? 'Not available',
                ),
                _TextMetric(
                  label: 'Forward gross yield',
                  value: dividendDataAvailable
                      ? position.forwardYield?.format() ?? 'Not available'
                      : 'Loading…',
                ),
              ],
            ),
            const Divider(height: AppTheme.space * 2),
            if (!dividendDataAvailable)
              Text('Loading dividend data…', style: theme.textTheme.bodySmall)
            else if (next == null)
              Text(
                'Next dividend not known yet.',
                style: theme.textTheme.bodySmall,
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: AppTheme.space / 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Next dividend ${_date(context, next.event)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        GrossNetAmount(
                          event: next.event,
                          gross: next.grossAmount,
                        ),
                      ],
                    ),
                  ),
                  DividendStatusChip(next.event.status),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _date(BuildContext context, DividendEvent event) {
    final DateTime date = event.paymentDate ?? event.exDate!;
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }
}

final class _TaxWindow {
  const _TaxWindow({
    required this.loading,
    required this.netEur,
    required this.unsupportedCount,
  });
  final bool loading;
  final Money netEur;
  final int unsupportedCount;
}

_TaxWindow _taxWindow(
  Iterable<DividendEvent> events,
  Iterable<AsyncValue<PortfolioTaxEstimates>> annualValues,
  Set<String> heldInstrumentIds,
) {
  final bool loading = annualValues.any((value) => !value.hasValue);
  final Map<String, TaxEventEstimate> estimates = <String, TaxEventEstimate>{
    for (final AsyncValue<PortfolioTaxEstimates> annual in annualValues)
      if (annual.value case final value?) ...value.byEventKey,
  };
  Money net = Money.zero(Currency.eur);
  int unsupported = 0;
  for (final DividendEvent event in events) {
    if (!heldInstrumentIds.contains(event.instrumentId)) continue;
    switch (estimates[dividendTaxEventKey(event)]?.result) {
      case DividendTaxBreakdown(net: final Money payment):
        net += payment;
      case UnsupportedTaxCalculation():
        unsupported++;
      case null:
        if (!loading) unsupported++;
    }
  }
  return _TaxWindow(
    loading: loading,
    netEur: net,
    unsupportedCount: unsupported,
  );
}

class _TextMetric extends StatelessWidget {
  const _TextMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      Text(value, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}
