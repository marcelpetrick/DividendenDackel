import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/portfolio_overview.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Calendar granularity for cash-flow detail.
enum PerformanceGrouping { monthly, quarterly, annual }

/// Exact cash-flow detail for one half-open calendar period and currency.
final class PerformancePeriodBreakdown {
  /// Creates an explainable period line.
  const PerformancePeriodBreakdown({
    required this.start,
    required this.end,
    required this.currency,
    required this.purchases,
    required this.sales,
    required this.dividends,
    required this.taxes,
    required this.fees,
    required this.deposits,
    required this.withdrawals,
    required this.unsupportedActivityCount,
  });

  /// Inclusive calendar-period start.
  final DateTime start;

  /// Exclusive calendar-period end.
  final DateTime end;

  /// Currency shared by every amount.
  final Currency currency;

  /// Opening balances and purchases valued at recorded unit prices.
  final Money purchases;

  /// Sales valued at recorded unit prices.
  final Money sales;

  /// Actual gross dividends recorded in the ledger.
  final Money dividends;

  /// Actual taxes recorded in the ledger.
  final Money taxes;

  /// Actual fees recorded in the ledger.
  final Money fees;

  /// Cash deposits, disclosed but excluded from security-only returns.
  final Money deposits;

  /// Cash withdrawals, disclosed but excluded from security-only returns.
  final Money withdrawals;

  /// Adjustments or trades that could not be valued without guessing.
  final int unsupportedActivityCount;

  /// Capital committed to securities after sales and distributions.
  Money get netInvested => purchases + taxes + fees - sales - dividends;

  /// Whether the security cash-flow line is fully valued.
  bool get isComplete => unsupportedActivityCount == 0;

  /// Whether this period contains any recorded economic activity.
  bool get isEmpty =>
      purchases.isZero &&
      sales.isZero &&
      dividends.isZero &&
      taxes.isZero &&
      fees.isZero &&
      deposits.isZero &&
      withdrawals.isZero &&
      unsupportedActivityCount == 0;
}

/// One return value with its actual calculation window and formula.
final class PortfolioReturnMetric {
  /// Creates an available return metric.
  const PortfolioReturnMetric({
    required this.rate,
    required this.start,
    required this.end,
    required this.formula,
  });

  /// Calculated return rate.
  final Percentage rate;

  /// First covered date.
  final DateTime start;

  /// Last covered date.
  final DateTime end;

  /// Plain-language formula/cash-flow convention.
  final String formula;
}

/// Explainable performance for one currency; currencies are never combined.
final class PortfolioCurrencyPerformance {
  /// Creates a currency performance assessment.
  const PortfolioCurrencyPerformance({
    required this.currency,
    required this.currentValue,
    required this.currentValueComplete,
    required this.xirr,
    required this.ttwror,
    required this.periods,
    required this.limitations,
  });

  /// Currency of every amount and valuation.
  final Currency currency;

  /// Current covered holdings value.
  final Money currentValue;

  /// Whether [currentValue] includes every current position.
  final bool currentValueComplete;

  /// Money-weighted annualized return since the first valued cash flow.
  final PortfolioReturnMetric? xirr;

  /// Time-weighted return across locally retained complete valuations.
  final PortfolioReturnMetric? ttwror;

  /// Newest-first cash-flow period details.
  final List<PerformancePeriodBreakdown> periods;

  /// Reasons a value is partial or unavailable.
  final List<String> limitations;
}

/// Currency-separated portfolio performance report.
final class PortfolioPerformanceReport {
  /// Creates a report.
  const PortfolioPerformanceReport({required this.byCurrency});

  /// Assessments keyed by native currency.
  final Map<Currency, PortfolioCurrencyPerformance> byCurrency;
}

/// Ledger-based XIRR, TTWROR and calendar-period cash-flow calculator.
abstract final class PortfolioPerformanceCalculator {
  static const String xirrFormula =
      'XIRR solves the annual rate where dated security cash flows plus the '
      'current covered value have a net present value of zero.';
  static const String ttwrorFormula =
      'TTWROR chains valuation-to-valuation returns. Purchases and costs are '
      'capital in; sales and dividends are capital out.';

  /// Calculates native-currency results without inventing FX or valuations.
  static PortfolioPerformanceReport calculate({
    required List<PortfolioActivity> activities,
    required Map<String, Currency> instrumentCurrencies,
    required List<PortfolioValuationSnapshot> valuations,
    required Map<Currency, Money> currentValues,
    required Set<Currency> completeValueCurrencies,
    required Map<Currency, DateTime> currentValuationDates,
    required DateTime asOf,
    required PerformanceGrouping grouping,
    int periodCount = 12,
  }) {
    final DateTime endDay = _day(asOf);
    final List<PortfolioActivity> active = _activeActivities(activities)
        .where((PortfolioActivity item) => !item.occurredAt.isAfter(asOf))
        .toList(growable: false);
    final Set<Currency> currencies = <Currency>{
      ...currentValues.keys,
      ...valuations.map((PortfolioValuationSnapshot item) => item.currency),
    };
    for (final PortfolioActivity activity in active) {
      final Currency? currency =
          activity.unitPrice?.currency ??
          activity.cashAmount?.currency ??
          (activity.instrumentId == null
              ? null
              : instrumentCurrencies[activity.instrumentId]);
      if (currency != null) currencies.add(currency);
    }

    final List<Currency> ordered = currencies.toList()
      ..sort(
        (Currency left, Currency right) => left.code.compareTo(right.code),
      );
    final Map<Currency, PortfolioCurrencyPerformance> results =
        <Currency, PortfolioCurrencyPerformance>{};
    for (final Currency currency in ordered) {
      final Money current = currentValues[currency] ?? Money.zero(currency);
      final bool currentComplete = completeValueCurrencies.contains(currency);
      final List<String> limitations = <String>[];
      final List<_DatedFlow> flows = <_DatedFlow>[];
      int unsupported = 0;
      bool hasCashBalanceMovements = false;
      for (final PortfolioActivity activity in active) {
        final _FlowResult result = _returnFlow(
          activity,
          currency,
          instrumentCurrencies,
        );
        if (result.flow case final _DatedFlow flow) flows.add(flow);
        unsupported += result.unsupported ? 1 : 0;
        hasCashBalanceMovements =
            hasCashBalanceMovements || result.cashBalanceMovement;
      }
      flows.sort(
        (_DatedFlow left, _DatedFlow right) => left.at.compareTo(right.at),
      );

      PortfolioReturnMetric? xirr;
      final DateTime? rawTerminalDate = currentValuationDates[currency];
      final DateTime? terminalDate = rawTerminalDate == null
          ? null
          : _day(rawTerminalDate);
      if (!currentComplete) {
        limitations.add(
          'XIRR unavailable: the current $currency value excludes unpriced positions.',
        );
      } else if (terminalDate == null) {
        limitations.add(
          'XIRR unavailable: current quotes do not form one defensible valuation date.',
        );
      } else if (unsupported > 0) {
        limitations.add(
          'XIRR unavailable: $unsupported trade or holding adjustment has no defensible cash value.',
        );
      } else if (flows.isEmpty) {
        limitations.add(
          'XIRR unavailable: no valued security cash flows exist.',
        );
      } else if (flows.any(
        (_DatedFlow flow) => flow.at.isAfter(terminalDate),
      )) {
        limitations.add(
          'XIRR unavailable: the latest complete valuation predates a recorded security cash flow.',
        );
      } else {
        final List<_DatedFlow> xirrFlows = <_DatedFlow>[
          ...flows,
          _DatedFlow(at: terminalDate, amount: current.amount),
        ];
        final _RateSolution solution = _xirr(xirrFlows);
        if (solution.ambiguous) {
          limitations.add(
            'XIRR unavailable: these cash flows have more than one mathematical solution.',
          );
        } else if (solution.rate case final double rate) {
          xirr = PortfolioReturnMetric(
            rate: _percentage(rate),
            start: flows.first.at,
            end: terminalDate,
            formula: xirrFormula,
          );
        } else {
          limitations.add(
            'XIRR unavailable: the dated cash flows do not contain a solvable positive and negative pair.',
          );
        }
      }

      final List<PortfolioValuationSnapshot> completeValuations = valuations
          .where(
            (PortfolioValuationSnapshot item) =>
                item.currency == currency &&
                item.isComplete &&
                !item.observedAt.isAfter(asOf),
          )
          .toList(growable: true);
      if (currentComplete && terminalDate != null) {
        completeValuations.add(
          PortfolioValuationSnapshot(
            scopeId: '__current__',
            currency: currency,
            value: current,
            observedAt: terminalDate,
            positionCount: 0,
            pricedPositionCount: 0,
          ),
        );
      }
      final List<PortfolioValuationSnapshot> daily = _deduplicateValuations(
        completeValuations,
      );
      PortfolioReturnMetric? ttwror;
      if (daily.length < 2) {
        limitations.add(
          'TTWROR unavailable: at least two complete end-of-day portfolio valuations are required.',
        );
      } else {
        final DateTime twrStart = daily.first.observedAt;
        final DateTime twrEnd = daily.last.observedAt;
        final bool unsupportedInside = active.any(
          (PortfolioActivity activity) =>
              activity.occurredAt.isAfter(twrStart) &&
              !activity.occurredAt.isAfter(twrEnd) &&
              _returnFlow(activity, currency, instrumentCurrencies).unsupported,
        );
        if (unsupportedInside) {
          limitations.add(
            'TTWROR unavailable: an unvalued adjustment occurs inside the valuation window.',
          );
        } else if (!_hasEveryFlowValuation(daily, flows)) {
          limitations.add(
            'TTWROR unavailable: every security cash-flow day needs a complete end-of-day valuation.',
          );
        } else if (_ttwror(daily, flows) case final double rate) {
          ttwror = PortfolioReturnMetric(
            rate: _percentage(rate),
            start: twrStart,
            end: twrEnd,
            formula: ttwrorFormula,
          );
        } else {
          limitations.add(
            'TTWROR unavailable: a valuation segment has no positive capital base.',
          );
        }
      }
      if (hasCashBalanceMovements) {
        limitations.add(
          'Deposits and withdrawals are shown below but excluded from returns because the app does not value a cash balance.',
        );
      }
      limitations.add(
        'Benchmark comparison unavailable: no like-for-like historical benchmark series is configured.',
      );

      results[currency] = PortfolioCurrencyPerformance(
        currency: currency,
        currentValue: current,
        currentValueComplete: currentComplete,
        xirr: xirr,
        ttwror: ttwror,
        periods: <PerformancePeriodBreakdown>[
          for (int index = 0; index < periodCount; index++)
            _period(
              active,
              instrumentCurrencies,
              currency,
              _periodRange(endDay, grouping, index),
            ),
        ],
        limitations: List<String>.unmodifiable(limitations),
      );
    }
    return PortfolioPerformanceReport(
      byCurrency: Map<Currency, PortfolioCurrencyPerformance>.unmodifiable(
        results,
      ),
    );
  }

  static List<PortfolioActivity> _activeActivities(
    List<PortfolioActivity> activities,
  ) {
    final Set<int> reversed = activities
        .where(
          (PortfolioActivity item) =>
              item.type == PortfolioActivityType.reversal,
        )
        .map((PortfolioActivity item) => item.reversesActivityId!)
        .toSet();
    return activities
        .where(
          (PortfolioActivity item) =>
              item.type != PortfolioActivityType.reversal &&
              (item.id == null || !reversed.contains(item.id)),
        )
        .toList(growable: false);
  }

  /// Builds current valuation evidence without backdating later holdings.
  static List<PortfolioValuationSnapshot> currentValuations({
    required String scopeId,
    required PortfolioOverview overview,
    required List<PortfolioActivity> activities,
    required Map<String, Currency> instrumentCurrencies,
  }) {
    final List<PortfolioValuationSnapshot> snapshots =
        <PortfolioValuationSnapshot>[];
    for (final PortfolioCurrencySummary summary in overview.byCurrency.values) {
      final Set<DateTime> quoteDays = <DateTime>{
        for (final PortfolioPositionSummary position in overview.positions)
          if (position.value?.currency == summary.currency &&
              position.quote != null)
            _day(position.quote!.asOf),
      };
      if (quoteDays.length != 1) continue;
      final DateTime quoteDay = quoteDays.single;
      final bool changedAfterQuote = activities.any((
        PortfolioActivity activity,
      ) {
        if (activity.shareDelta == null &&
            activity.type != PortfolioActivityType.reversal) {
          return false;
        }
        final String? instrumentId = activity.instrumentId;
        return instrumentId != null &&
            instrumentCurrencies[instrumentId] == summary.currency &&
            _day(activity.occurredAt).isAfter(quoteDay);
      });
      if (changedAfterQuote) continue;
      snapshots.add(
        PortfolioValuationSnapshot(
          scopeId: scopeId,
          currency: summary.currency,
          value: summary.totalValue,
          observedAt: quoteDay,
          positionCount: summary.positionCount,
          pricedPositionCount: summary.pricedPositionCount,
        ),
      );
    }
    return snapshots;
  }

  static PerformancePeriodBreakdown _period(
    List<PortfolioActivity> activities,
    Map<String, Currency> instrumentCurrencies,
    Currency currency,
    (DateTime, DateTime) range,
  ) {
    Money purchases = Money.zero(currency);
    Money sales = Money.zero(currency);
    Money dividends = Money.zero(currency);
    Money taxes = Money.zero(currency);
    Money fees = Money.zero(currency);
    Money deposits = Money.zero(currency);
    Money withdrawals = Money.zero(currency);
    int unsupported = 0;
    for (final PortfolioActivity activity in activities) {
      if (activity.occurredAt.isBefore(range.$1) ||
          !activity.occurredAt.isBefore(range.$2)) {
        continue;
      }
      final Currency? activityCurrency =
          activity.unitPrice?.currency ??
          activity.cashAmount?.currency ??
          (activity.instrumentId == null
              ? null
              : instrumentCurrencies[activity.instrumentId]);
      if (activityCurrency != currency) continue;
      switch (activity.type) {
        case PortfolioActivityType.openingBalance:
        case PortfolioActivityType.purchase:
          final Money? price = activity.unitPrice;
          final Decimal? quantity = activity.quantity;
          if (price == null || quantity == null) {
            unsupported++;
          } else {
            purchases += price * quantity.abs();
          }
        case PortfolioActivityType.sale:
          final Money? price = activity.unitPrice;
          final Decimal? quantity = activity.quantity;
          if (price == null || quantity == null) {
            unsupported++;
          } else {
            sales += price * quantity.abs();
          }
        case PortfolioActivityType.deposit:
          deposits += activity.cashAmount!;
        case PortfolioActivityType.withdrawal:
          withdrawals += activity.cashAmount!;
        case PortfolioActivityType.dividend:
          dividends += activity.cashAmount!;
        case PortfolioActivityType.tax:
          taxes += activity.cashAmount!;
        case PortfolioActivityType.fee:
          fees += activity.cashAmount!;
        case PortfolioActivityType.holdingAdjustment:
          unsupported++;
        case PortfolioActivityType.reversal:
          break;
      }
    }
    return PerformancePeriodBreakdown(
      start: range.$1,
      end: range.$2,
      currency: currency,
      purchases: purchases,
      sales: sales,
      dividends: dividends,
      taxes: taxes,
      fees: fees,
      deposits: deposits,
      withdrawals: withdrawals,
      unsupportedActivityCount: unsupported,
    );
  }

  static _FlowResult _returnFlow(
    PortfolioActivity activity,
    Currency currency,
    Map<String, Currency> instrumentCurrencies,
  ) {
    final Currency? activityCurrency =
        activity.unitPrice?.currency ??
        activity.cashAmount?.currency ??
        (activity.instrumentId == null
            ? null
            : instrumentCurrencies[activity.instrumentId]);
    if (activityCurrency != currency) return const _FlowResult();
    switch (activity.type) {
      case PortfolioActivityType.openingBalance:
      case PortfolioActivityType.purchase:
      case PortfolioActivityType.sale:
        final Money? price = activity.unitPrice;
        final Decimal? quantity = activity.quantity;
        if (price == null || quantity == null) {
          return const _FlowResult(unsupported: true);
        }
        final Decimal value = (price * quantity.abs()).amount;
        return _FlowResult(
          flow: _DatedFlow(
            at: _day(activity.occurredAt),
            amount: activity.type == PortfolioActivityType.sale
                ? value
                : -value,
          ),
        );
      case PortfolioActivityType.dividend:
        return _FlowResult(
          flow: _DatedFlow(
            at: _day(activity.occurredAt),
            amount: activity.cashAmount!.amount,
          ),
        );
      case PortfolioActivityType.tax:
      case PortfolioActivityType.fee:
        return _FlowResult(
          flow: _DatedFlow(
            at: _day(activity.occurredAt),
            amount: -activity.cashAmount!.amount,
          ),
        );
      case PortfolioActivityType.deposit:
      case PortfolioActivityType.withdrawal:
        return const _FlowResult(cashBalanceMovement: true);
      case PortfolioActivityType.holdingAdjustment:
        return const _FlowResult(unsupported: true);
      case PortfolioActivityType.reversal:
        return const _FlowResult();
    }
  }

  static (DateTime, DateTime) _periodRange(
    DateTime asOf,
    PerformanceGrouping grouping,
    int index,
  ) => switch (grouping) {
    PerformanceGrouping.monthly => (
      DateTime.utc(asOf.year, asOf.month - index),
      DateTime.utc(asOf.year, asOf.month - index + 1),
    ),
    PerformanceGrouping.quarterly => () {
      final int currentQuarterMonth = ((asOf.month - 1) ~/ 3) * 3 + 1;
      final DateTime start = DateTime.utc(
        asOf.year,
        currentQuarterMonth - index * 3,
      );
      return (start, DateTime.utc(start.year, start.month + 3));
    }(),
    PerformanceGrouping.annual => (
      DateTime.utc(asOf.year - index),
      DateTime.utc(asOf.year - index + 1),
    ),
  };

  static List<PortfolioValuationSnapshot> _deduplicateValuations(
    List<PortfolioValuationSnapshot> values,
  ) {
    values.sort(
      (PortfolioValuationSnapshot left, PortfolioValuationSnapshot right) =>
          left.observedAt.compareTo(right.observedAt),
    );
    final Map<DateTime, PortfolioValuationSnapshot> byDay =
        <DateTime, PortfolioValuationSnapshot>{};
    for (final PortfolioValuationSnapshot value in values) {
      byDay[_day(value.observedAt)] = value;
    }
    return byDay.entries
        .map(
          (MapEntry<DateTime, PortfolioValuationSnapshot> entry) =>
              PortfolioValuationSnapshot(
                scopeId: entry.value.scopeId,
                currency: entry.value.currency,
                value: entry.value.value,
                observedAt: entry.key,
                positionCount: entry.value.positionCount,
                pricedPositionCount: entry.value.pricedPositionCount,
              ),
        )
        .toList(growable: false);
  }

  static double? _ttwror(
    List<PortfolioValuationSnapshot> valuations,
    List<_DatedFlow> flows,
  ) {
    double chained = 1;
    for (int index = 1; index < valuations.length; index++) {
      final PortfolioValuationSnapshot beginning = valuations[index - 1];
      final PortfolioValuationSnapshot ending = valuations[index];
      Decimal contributions = Decimal.zero;
      Decimal distributions = Decimal.zero;
      for (final _DatedFlow flow in flows) {
        if (flow.at.isAfter(beginning.observedAt) &&
            !flow.at.isAfter(ending.observedAt)) {
          if (flow.amount < Decimal.zero) {
            contributions += flow.amount.abs();
          } else {
            distributions += flow.amount;
          }
        }
      }
      final Decimal denominator = beginning.value.amount + contributions;
      if (denominator <= Decimal.zero) return null;
      final Decimal numerator = ending.value.amount + distributions;
      final double segment = (numerator / denominator).toDouble() - 1;
      if (!segment.isFinite) return null;
      chained *= 1 + segment;
    }
    final double result = chained - 1;
    return result.isFinite ? result : null;
  }

  static bool _hasEveryFlowValuation(
    List<PortfolioValuationSnapshot> valuations,
    List<_DatedFlow> flows,
  ) {
    final DateTime start = valuations.first.observedAt;
    final DateTime end = valuations.last.observedAt;
    final Set<DateTime> valuationDays = valuations
        .map((PortfolioValuationSnapshot value) => _day(value.observedAt))
        .toSet();
    return flows.every((_DatedFlow flow) {
      final DateTime day = _day(flow.at);
      return !day.isAfter(start) ||
          day.isAfter(end) ||
          valuationDays.contains(day);
    });
  }

  static _RateSolution _xirr(List<_DatedFlow> flows) {
    if (flows.length < 2) return const _RateSolution();
    final bool hasNegative = flows.any(
      (_DatedFlow flow) => flow.amount < Decimal.zero,
    );
    final bool hasPositive = flows.any(
      (_DatedFlow flow) => flow.amount > Decimal.zero,
    );
    if (!hasNegative || !hasPositive) return const _RateSolution();
    final DateTime first = flows.first.at;
    if (!flows.last.at.isAfter(first)) return const _RateSolution();

    const List<double> probes = <double>[
      -0.9999,
      -0.99,
      -0.9,
      -0.75,
      -0.5,
      -0.25,
      0,
      0.1,
      0.25,
      0.5,
      1,
      2,
      5,
      10,
      25,
      100,
      1000,
    ];
    final List<(double, double)> brackets = <(double, double)>[];
    double previousRate = probes.first;
    double previousValue = _npv(flows, first, previousRate);
    if (previousValue == 0) {
      brackets.add((previousRate, previousRate));
    }
    for (final double rate in probes.skip(1)) {
      final double value = _npv(flows, first, rate);
      if (previousValue.isFinite && value.isFinite) {
        if (value == 0) {
          brackets.add((rate, rate));
        } else if (previousValue != 0 && previousValue.sign != value.sign) {
          brackets.add((previousRate, rate));
        }
      }
      previousRate = rate;
      previousValue = value;
    }
    if (brackets.length > 1) return const _RateSolution(ambiguous: true);
    if (brackets.isEmpty) return const _RateSolution();
    double low = brackets.single.$1;
    double high = brackets.single.$2;
    if (low == high) return _RateSolution(rate: low);
    double lowValue = _npv(flows, first, low);
    for (int iteration = 0; iteration < 200; iteration++) {
      final double middle = (low + high) / 2;
      final double value = _npv(flows, first, middle);
      if (value.abs() < 1e-9 || (high - low).abs() < 1e-12) {
        return _RateSolution(rate: middle);
      }
      if (lowValue.sign == value.sign) {
        low = middle;
        lowValue = value;
      } else {
        high = middle;
      }
    }
    return _RateSolution(rate: (low + high) / 2);
  }

  static double _npv(List<_DatedFlow> flows, DateTime first, double rate) {
    double value = 0;
    for (final _DatedFlow flow in flows) {
      final double years = flow.at.difference(first).inSeconds / 31536000;
      value += flow.amount.toDouble() / math.pow(1 + rate, years);
    }
    return value;
  }

  static Percentage _percentage(double rate) =>
      Percentage.fromRate(Decimal.parse(rate.toStringAsFixed(12)));

  static DateTime _day(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);
}

final class _DatedFlow {
  const _DatedFlow({required this.at, required this.amount});

  final DateTime at;
  final Decimal amount;
}

final class _FlowResult {
  const _FlowResult({
    this.flow,
    this.unsupported = false,
    this.cashBalanceMovement = false,
  });

  final _DatedFlow? flow;
  final bool unsupported;
  final bool cashBalanceMovement;
}

final class _RateSolution {
  const _RateSolution({this.rate, this.ambiguous = false});

  final double? rate;
  final bool ambiguous;
}
