import 'dart:math' as math;

import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/features/calendar/forecast_state.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:dividendendackel/features/tax/tax_estimates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ForecastView { month, quarter, year }

/// Portfolio dividend-income forecast (Vision.md §10).
class ForecastScreen extends ConsumerStatefulWidget {
  /// Creates the forecast screen.
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  _ForecastView _view = _ForecastView.month;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Holding>> holdingsValue = ref.watch(holdingsProvider);
    return AsyncValueView<List<Holding>>(
      value: holdingsValue,
      isEmpty: (List<Holding> holdings) => holdings.isEmpty,
      emptyTitle: 'No holdings to forecast',
      emptyMessage: 'Add a holding before projecting portfolio income.',
      emptyIcon: Icons.stacked_line_chart,
      builder: (BuildContext context, List<Holding> holdings) {
        final DateTime now = ref.watch(clockProvider).now();
        final Set<String> ids = <String>{
          for (final Holding holding in holdings) holding.instrumentId,
        };
        final AsyncValue<List<DividendEvent>> source = ref.watch(
          forecastSourceEventsProvider(
            ForecastEventsQuery(
              range: DateRange(
                DateTime(now.year - 12),
                DateTime(now.year, now.month + 24),
              ),
              instrumentIds: ids,
            ),
          ),
        );
        return AsyncValueView<Map<String, Instrument>>(
          value: ref.watch(instrumentsByIdProvider),
          builder:
              (
                BuildContext context,
                Map<String, Instrument> instruments,
              ) => AsyncValueView<List<DividendEvent>>(
                value: source,
                isEmpty: (List<DividendEvent> events) => events.isEmpty,
                emptyTitle: 'No dividend history',
                emptyMessage:
                    'A forecast needs dated reported payments. The app will '
                    'not invent a schedule without them.',
                emptyIcon: Icons.query_stats_outlined,
                builder: (BuildContext context, List<DividendEvent> events) {
                  final List<DividendForecast> forecasts = <DividendForecast>[
                    for (final Holding holding in holdings)
                      if (instruments[holding.instrumentId]
                          case final instrument?)
                        DividendForecastEngine().forecast(
                          instrumentId: holding.instrumentId,
                          currency: instrument.currency,
                          events: events,
                          asOf: now,
                        ),
                  ];
                  return AsyncValueView<TaxSettings>(
                    value: ref.watch(taxSettingsProvider),
                    builder: (BuildContext context, TaxSettings settings) {
                      final PortfolioDividendIncomeForecast projection =
                          const DividendIncomeForecastCalculator().calculate(
                            holdings: holdings,
                            historicalEvents: events,
                            forecasts: forecasts,
                            asOf: now,
                          );
                      final _ForecastTaxProjection taxes =
                          _ForecastTaxProjection.calculate(
                            historicalEvents: events,
                            forecasts: forecasts,
                            holdings: holdings,
                            instruments: instruments,
                            settings: settings,
                          );
                      return _ForecastBody(
                        projection: projection,
                        forecasts: forecasts,
                        instruments: instruments,
                        taxes: taxes,
                        view: _view,
                        onViewChanged: (_ForecastView view) =>
                            setState(() => _view = view),
                      );
                    },
                  );
                },
              ),
        );
      },
    );
  }
}

class _ForecastBody extends StatelessWidget {
  const _ForecastBody({
    required this.projection,
    required this.forecasts,
    required this.instruments,
    required this.taxes,
    required this.view,
    required this.onViewChanged,
  });

  final PortfolioDividendIncomeForecast projection;
  final List<DividendForecast> forecasts;
  final Map<String, Instrument> instruments;
  final _ForecastTaxProjection taxes;
  final _ForecastView view;
  final ValueChanged<_ForecastView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    final List<DividendIncomePeriod> periods = switch (view) {
      _ForecastView.month => projection.months,
      _ForecastView.quarter => projection.quarters,
      _ForecastView.year => projection.years,
    };
    return ListView(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      children: <Widget>[
        Text(
          '24-month income forecast',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Gross and estimated-net income using today’s holding quantities. '
          'Estimates are '
          'rule-based, not guaranteed. “Paid” means the confirmed payment date '
          'has passed; it is not broker reconciliation.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppTheme.space * 2),
        _Summary(projection: projection, taxes: taxes),
        const SizedBox(height: AppTheme.space * 2),
        _CurrentMonth(period: projection.months.first, taxes: taxes),
        const SizedBox(height: AppTheme.space * 2),
        SegmentedButton<_ForecastView>(
          showSelectedIcon: false,
          segments: const <ButtonSegment<_ForecastView>>[
            ButtonSegment<_ForecastView>(
              value: _ForecastView.month,
              label: Text('Month'),
            ),
            ButtonSegment<_ForecastView>(
              value: _ForecastView.quarter,
              label: Text('Quarter'),
            ),
            ButtonSegment<_ForecastView>(
              value: _ForecastView.year,
              label: Text('Year'),
            ),
          ],
          selected: <_ForecastView>{view},
          onSelectionChanged: (Set<_ForecastView> values) =>
              onViewChanged(values.single),
        ),
        const SizedBox(height: AppTheme.space),
        const _Legend(),
        const SizedBox(height: AppTheme.space),
        for (final DividendIncomePeriod period in periods)
          _PeriodBar(
            period: period,
            view: view,
            maximumByCurrency: _maxTotals(periods),
            net: taxes.forPeriod(period.start, period.end),
          ),
        const SizedBox(height: AppTheme.space * 2),
        Text(
          'Cumulative income',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.space),
        _CumulativeCharts(months: projection.months, taxes: taxes),
        const SizedBox(height: AppTheme.space * 2),
        Text('Payout table', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppTheme.space),
        _PayoutTable(months: projection.months, taxes: taxes),
        const SizedBox(height: AppTheme.space),
        Text(
          'Net figures are estimates, not tax advice. Payments without dated '
          'EUR FX or source-country data remain explicitly unavailable.',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: AppTheme.space * 2),
        Text(
          'How this was estimated',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppTheme.space),
        for (final DividendForecast forecast in forecasts)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              forecast.status == DividendForecastStatus.available
                  ? Icons.query_stats_outlined
                  : Icons.info_outline,
            ),
            title: Text(
              instruments[forecast.instrumentId]?.name ?? forecast.instrumentId,
            ),
            subtitle: Text(forecast.explanation),
          ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.projection, required this.taxes});
  final PortfolioDividendIncomeForecast projection;
  final _ForecastTaxProjection taxes;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppTheme.space,
    runSpacing: AppTheme.space,
    children: <Widget>[
      _SummaryCard(
        title: 'Trailing 12 months',
        values: projection.trailingTwelveMonths,
        net: taxes.forPeriod(
          DateTime(
            projection.asOf.year - 1,
            projection.asOf.month,
            projection.asOf.day,
          ),
          projection.asOf,
        ),
        suffix: 'confirmed gross',
      ),
      for (final DividendIncomePeriod year in projection.years)
        _SummaryCard(
          title: '${year.start.year} forecast',
          values: <Currency, Money>{
            for (final MapEntry<Currency, DividendIncomeBreakdown> entry
                in year.byCurrency.entries)
              entry.key: entry.value.total,
          },
          net: taxes.forPeriod(year.start, year.end),
          suffix: 'confirmed + estimated',
        ),
      if (projection.yearOverYearChange.isNotEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('TTM year over year'),
                for (final MapEntry<Currency, Percentage> entry
                    in projection.yearOverYearChange.entries)
                  Text(
                    '${entry.key.code} ${entry.value.format(withSign: true)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.values,
    required this.suffix,
    required this.net,
  });
  final String title;
  final Map<Currency, Money> values;
  final String suffix;
  final _NetTotal net;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title),
          if (values.isEmpty)
            const Text('Not available')
          else
            for (final Money value in values.values)
              Text(
                'Gross ${value.format(withSymbol: true)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
          Text(
            'Net (estimated) ${net.netEur.format(withSymbol: true)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (net.unsupportedCount > 0)
            Text('${net.unsupportedCount} payment(s) need FX/country data'),
          Text(suffix, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    ),
  );
}

class _CurrentMonth extends StatelessWidget {
  const _CurrentMonth({required this.period, required this.taxes});
  final DividendIncomePeriod period;
  final _ForecastTaxProjection taxes;

  @override
  Widget build(BuildContext context) {
    final _NetTotal net = taxes.forPeriod(period.start, period.end);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('This month', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (period.byCurrency.isEmpty)
              const Text('No payments expected this month.')
            else
              for (final DividendIncomeBreakdown value
                  in period.byCurrency.values)
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: <Widget>[
                    Text('✓ Paid ${value.paid.format(withSymbol: true)}'),
                    Text(
                      '● Confirmed ${value.confirmedUpcoming.format(withSymbol: true)}',
                    ),
                    Text(
                      'E Estimated ${value.estimated.format(withSymbol: true)}',
                    ),
                  ],
                ),
            if (period.byCurrency.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Text('Net (estimated) ${net.label}'),
            ],
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: 16,
    children: <Widget>[
      Text('✓ Paid'),
      Text('● Confirmed upcoming'),
      Text('E Estimated'),
    ],
  );
}

class _PeriodBar extends StatelessWidget {
  const _PeriodBar({
    required this.period,
    required this.view,
    required this.maximumByCurrency,
    required this.net,
  });
  final DividendIncomePeriod period;
  final _ForecastView view;
  final Map<Currency, Money> maximumByCurrency;
  final _NetTotal net;

  @override
  Widget build(BuildContext context) {
    final String label = switch (view) {
      _ForecastView.month =>
        '${_months[period.start.month - 1]} ${period.start.year}',
      _ForecastView.quarter =>
        'Q${((period.start.month - 1) ~/ 3) + 1} ${period.start.year}',
      _ForecastView.year => '${period.start.year}',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 82, child: Text(label)),
          Expanded(
            child: period.byCurrency.isEmpty
                ? const Divider(height: 20)
                : Column(
                    children: <Widget>[
                      for (final DividendIncomeBreakdown value
                          in period.byCurrency.values)
                        _StackedBar(
                          value: value,
                          share: period.shareOfYearByCurrency[value.currency],
                          maximum: maximumByCurrency[value.currency]!,
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Net (estimated) ${net.label}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({
    required this.value,
    required this.share,
    required this.maximum,
  });
  final DividendIncomeBreakdown value;
  final Percentage? share;
  final Money maximum;

  @override
  Widget build(BuildContext context) {
    final double total = double.tryParse(value.total.amount.toString()) ?? 0;
    final double maximumAmount =
        double.tryParse(maximum.amount.toString()) ?? total;
    double flex(Money amount) => total == 0
        ? 0
        : math
              .max(
                1,
                ((double.parse(amount.amount.toString()) / total) * 100)
                    .round(),
              )
              .toDouble();
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Semantics(
      label:
          '${value.currency.code}: ${value.total.format()}, paid ${value.paid.format()}, '
          'confirmed ${value.confirmedUpcoming.format()}, estimated ${value.estimated.format()}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: maximumAmount <= 0
                      ? 0
                      : math.max(0.02, total / maximumAmount),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(
                      height: 18,
                      child: Row(
                        children: <Widget>[
                          if (!value.paid.isZero)
                            Expanded(
                              flex: flex(value.paid).round(),
                              child: ColoredBox(color: colors.primary),
                            ),
                          if (!value.confirmedUpcoming.isZero)
                            Expanded(
                              flex: flex(value.confirmedUpcoming).round(),
                              child: ColoredBox(color: colors.secondary),
                            ),
                          if (!value.estimated.isZero)
                            Expanded(
                              flex: flex(value.estimated).round(),
                              child: ColoredBox(
                                color: colors.tertiaryContainer,
                                child: const Center(
                                  child: Text(
                                    'E',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 112,
              child: Text(
                '${value.total.format(withSymbol: true)}${share == null ? '' : ' · ${share!.format()}'}',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CumulativeCharts extends StatelessWidget {
  const _CumulativeCharts({required this.months, required this.taxes});
  final List<DividendIncomePeriod> months;
  final _ForecastTaxProjection taxes;

  @override
  Widget build(BuildContext context) {
    final Set<(int, Currency)> series = <(int, Currency)>{
      for (final DividendIncomePeriod month in months)
        for (final Currency currency in month.cumulativeByCurrency.keys)
          (month.start.year, currency),
    };
    if (series.isEmpty) return const Text('No projected income to chart.');
    return Column(
      children: <Widget>[
        for (final (int, Currency) item in series)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${item.$1} · ${item.$2.code}'),
                  Text(
                    item.$2 == Currency.eur
                        ? 'Gross and net (estimated)'
                        : 'Gross; net needs dated EUR FX',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _CurvePainter(
                        <Money>[
                          for (final DividendIncomePeriod month in months.where(
                            (month) => month.start.year == item.$1,
                          ))
                            month.cumulativeByCurrency[item.$2] ??
                                Money.zero(item.$2),
                        ],
                        item.$2 == Currency.eur
                            ? <Money>[
                                for (final DividendIncomePeriod month
                                    in months.where(
                                      (month) => month.start.year == item.$1,
                                    ))
                                  taxes
                                      .forPeriod(DateTime(item.$1), month.end)
                                      .netEur,
                              ]
                            : null,
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CurvePainter extends CustomPainter {
  const _CurvePainter(this.values, this.netValues, this.color, this.netColor);
  final List<Money> values;
  final List<Money>? netValues;
  final Color color;
  final Color netColor;

  @override
  void paint(Canvas canvas, Size size) {
    final List<double> numbers = values
        .map((Money value) => double.tryParse(value.amount.toString()) ?? 0)
        .toList();
    final List<double> netNumbers =
        netValues
            ?.map(
              (Money value) => double.tryParse(value.amount.toString()) ?? 0,
            )
            .toList() ??
        const <double>[];
    final double maximum = <double>[
      ...numbers,
      ...netNumbers,
    ].fold<double>(0, math.max);
    if (maximum <= 0 || numbers.length < 2) return;
    void draw(List<double> points, Color lineColor) {
      if (points.length < 2) return;
      final Path path = Path();
      for (int index = 0; index < points.length; index++) {
        final double x = size.width * index / (points.length - 1);
        final double y =
            size.height - (points[index] / maximum * (size.height - 8)) - 4;
        index == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }

    draw(numbers, color);
    draw(netNumbers, netColor);
  }

  @override
  bool shouldRepaint(_CurvePainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.netValues != netValues ||
      oldDelegate.color != color ||
      oldDelegate.netColor != netColor;
}

class _PayoutTable extends StatelessWidget {
  const _PayoutTable({required this.months, required this.taxes});
  final List<DividendIncomePeriod> months;
  final _ForecastTaxProjection taxes;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      columns: const <DataColumn>[
        DataColumn(label: Text('Month')),
        DataColumn(label: Text('Currency')),
        DataColumn(label: Text('Paid'), numeric: true),
        DataColumn(label: Text('Confirmed'), numeric: true),
        DataColumn(label: Text('Estimated'), numeric: true),
        DataColumn(label: Text('Total'), numeric: true),
        DataColumn(label: Text('Net estimated'), numeric: true),
        DataColumn(label: Text('Annual share'), numeric: true),
      ],
      rows: <DataRow>[
        for (final DividendIncomePeriod month in months)
          for (final DividendIncomeBreakdown value in month.byCurrency.values)
            DataRow(
              cells: <DataCell>[
                DataCell(
                  Text('${_months[month.start.month - 1]} ${month.start.year}'),
                ),
                DataCell(Text(value.currency.code)),
                DataCell(Text(value.paid.format())),
                DataCell(Text(value.confirmedUpcoming.format())),
                DataCell(Text(value.estimated.format())),
                DataCell(Text(value.total.format())),
                DataCell(
                  Text(
                    value.currency == Currency.eur
                        ? taxes.forPeriod(month.start, month.end).label
                        : 'Unavailable—needs dated EUR FX',
                  ),
                ),
                DataCell(
                  Text(
                    month.shareOfYearByCurrency[value.currency]?.format() ??
                        '—',
                  ),
                ),
              ],
            ),
      ],
    ),
  );
}

final class _NetTotal {
  const _NetTotal({required this.netEur, required this.unsupportedCount});
  final Money netEur;
  final int unsupportedCount;

  String get label => unsupportedCount == 0
      ? netEur.format(withSymbol: true)
      : '${netEur.format(withSymbol: true)} + $unsupportedCount unavailable';
}

final class _ForecastTaxProjection {
  const _ForecastTaxProjection(this._events, this._estimates);
  final List<DividendEvent> _events;
  final Map<String, TaxEventEstimate> _estimates;

  factory _ForecastTaxProjection.calculate({
    required List<DividendEvent> historicalEvents,
    required List<DividendForecast> forecasts,
    required List<Holding> holdings,
    required Map<String, Instrument> instruments,
    required TaxSettings settings,
  }) {
    final Map<String, DividendEvent> unique = <String, DividendEvent>{
      for (final DividendEvent event in historicalEvents)
        if (event.paymentDate != null && event.status.isConfirmedByCompany)
          dividendTaxEventKey(event): event,
      for (final DividendForecast forecast in forecasts)
        for (final DividendEvent event in forecast.events)
          if (event.paymentDate != null) dividendTaxEventKey(event): event,
    };
    final Set<int> years = <int>{
      for (final DividendEvent event in unique.values) event.paymentDate!.year,
    };
    final Map<String, TaxEventEstimate> estimates =
        <String, TaxEventEstimate>{};
    for (final int year in years) {
      estimates.addAll(
        PortfolioTaxEstimator.calculate(
          year: year,
          events: unique.values,
          holdings: holdings,
          instruments: instruments,
          settings: settings,
        ).byEventKey,
      );
    }
    return _ForecastTaxProjection(
      List<DividendEvent>.unmodifiable(unique.values),
      Map<String, TaxEventEstimate>.unmodifiable(estimates),
    );
  }

  _NetTotal forPeriod(DateTime start, DateTime end) {
    Money net = Money.zero(Currency.eur);
    int unsupported = 0;
    for (final DividendEvent event in _events) {
      final DateTime date = event.paymentDate!;
      if (date.isBefore(start) || !date.isBefore(end)) continue;
      switch (_estimates[dividendTaxEventKey(event)]?.result) {
        case DividendTaxBreakdown(net: final Money payment):
          net += payment;
        case UnsupportedTaxCalculation():
          unsupported++;
        case null:
          break;
      }
    }
    return _NetTotal(netEur: net, unsupportedCount: unsupported);
  }
}

Map<Currency, Money> _maxTotals(Iterable<DividendIncomePeriod> periods) {
  final Map<Currency, Money> maximum = <Currency, Money>{};
  for (final DividendIncomePeriod period in periods) {
    for (final DividendIncomeBreakdown value in period.byCurrency.values) {
      final Money? current = maximum[value.currency];
      if (current == null || value.total > current) {
        maximum[value.currency] = value.total;
      }
    }
  }
  return maximum;
}

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
