import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Annual dividend total used as an input and explanation for growth metrics.
final class AnnualDividendTotal {
  /// Creates an annual total.
  const AnnualDividendTotal({required this.year, required this.amount});

  /// Calendar year represented by [amount].
  final int year;

  /// Reported gross dividend per share across the year.
  final Money amount;
}

/// A period-labelled compound annual dividend growth rate.
final class DividendCagr {
  /// Creates a CAGR result with enough context to explain it.
  const DividendCagr({
    required this.periodYears,
    required this.startYear,
    required this.endYear,
    required this.beginningAnnualDividend,
    required this.endingAnnualDividend,
    required this.rate,
  });

  /// Requested and calculated period, in whole calendar years.
  final int periodYears;

  /// Beginning comparison year.
  final int startYear;

  /// Ending comparison year.
  final int endYear;

  /// Annual dividend per share in [startYear].
  final Money beginningAnnualDividend;

  /// Annual dividend per share in [endYear].
  final Money endingAnnualDividend;

  /// Compound annual rate.
  final Percentage rate;

  /// Complete label in canonical English; a CAGR is never shown without its
  /// period, because a growth rate without the years it covers means nothing.
  String format({int decimals = 1}) =>
      '${periodYears}Y dividend CAGR: '
      '${rate.format(decimals: decimals, withSign: true)} p.a.';

  /// The same label as a message pattern and its values.
  ///
  /// The domain holds no catalog and stays independent of widgets (Vision.md
  /// §53), so it supplies the sentence and the numbers and lets the
  /// presentation layer render them in the live locale.
  (String, Map<String, Object?>) message({int decimals = 1}) => (
    '{years}Y dividend CAGR: {rate} p.a.',
    <String, Object?>{
      'years': periodYears,
      'rate': rate.format(decimals: decimals, withSign: true),
    },
  );
}

/// Direction of a year-over-year annual dividend change.
enum DividendChangeDirection { increase, decrease }

/// Latest annual increase or decrease, with both values for explanation.
final class AnnualDividendChange {
  /// Creates an annual change.
  const AnnualDividendChange({
    required this.direction,
    required this.previousYear,
    required this.currentYear,
    required this.previousAnnualDividend,
    required this.currentAnnualDividend,
    required this.rate,
  });

  /// Whether this was an increase or a cut.
  final DividendChangeDirection direction;

  /// Earlier year in the comparison.
  final int previousYear;

  /// Later year in the comparison.
  final int currentYear;

  /// Earlier annual dividend per share.
  final Money previousAnnualDividend;

  /// Later annual dividend per share.
  final Money currentAnnualDividend;

  /// Year-over-year change, or `null` when the earlier value was zero.
  final Percentage? rate;
}

/// Explainable dividend-growth assessment for one instrument.
final class DividendGrowthAnalysis {
  /// Creates an assessment.
  const DividendGrowthAnalysis({
    required this.instrumentId,
    required this.currency,
    required this.annualTotals,
    required this.cagrs,
    required this.yearsWithoutCut,
    required this.latestIncrease,
    required this.latestDecrease,
  });

  /// Assessed instrument.
  final String instrumentId;

  /// Currency shared by every annual total.
  final Currency currency;

  /// Completed calendar-year totals, oldest first.
  final List<AnnualDividendTotal> annualTotals;

  /// Available standard periods, keyed by 3, 5 or 10 years.
  final Map<int, DividendCagr> cagrs;

  /// Consecutive year-over-year comparisons without a decrease, counting back
  /// from the newest completed year. Missing years stop the streak.
  final int yearsWithoutCut;

  /// Most recent strict increase between consecutive completed years.
  final AnnualDividendChange? latestIncrease;

  /// Most recent strict decrease between consecutive completed years.
  final AnnualDividendChange? latestDecrease;
}

/// Deterministic dividend CAGR and cut-history calculator (Vision.md §12).
final class DividendGrowthCalculator {
  /// Creates a stateless calculator.
  const DividendGrowthCalculator();

  /// Standard periods required by the product specification.
  static const List<int> standardPeriods = <int>[3, 5, 10];

  /// Aggregates reported events into completed calendar years and analyses them.
  ///
  /// Estimated/unknown events and the incomplete [asOf] calendar year are
  /// excluded. A reporting-period end takes precedence over event dates so SEC
  /// annual facts are assigned to the period they actually describe.
  DividendGrowthAnalysis calculate({
    required String instrumentId,
    required Currency currency,
    required List<DividendEvent> events,
    required DateTime asOf,
  }) {
    if (instrumentId.trim().isEmpty) {
      throw ArgumentError.value(
        instrumentId,
        'instrumentId',
        'must not be empty',
      );
    }

    final Map<int, Money> totals = <int, Money>{};
    for (final DividendEvent event in events) {
      if (event.instrumentId != instrumentId ||
          !event.status.isConfirmedByCompany) {
        continue;
      }
      if (event.amountPerShare.currency != currency) {
        throw ArgumentError(
          'Dividend currency ${event.amountPerShare.currency.code} does not '
          'match ${currency.code} for $instrumentId.',
        );
      }
      if (event.amountPerShare.isNegative) {
        throw ArgumentError(
          'Dividend amounts cannot be negative for $instrumentId.',
        );
      }
      final DateTime? effectiveDate =
          event.reportedPeriodEnd ?? event.exDate ?? event.paymentDate;
      if (effectiveDate == null || effectiveDate.year >= asOf.year) {
        continue;
      }
      final int year = effectiveDate.year;
      totals[year] =
          (totals[year] ?? Money.zero(currency)) + event.amountPerShare;
    }

    final List<int> years = totals.keys.toList()..sort();
    final List<AnnualDividendTotal> annualTotals = years
        .map(
          (int year) => AnnualDividendTotal(year: year, amount: totals[year]!),
        )
        .toList(growable: false);
    if (years.isEmpty) {
      return DividendGrowthAnalysis(
        instrumentId: instrumentId,
        currency: currency,
        annualTotals: const <AnnualDividendTotal>[],
        cagrs: const <int, DividendCagr>{},
        yearsWithoutCut: 0,
        latestIncrease: null,
        latestDecrease: null,
      );
    }

    final int endYear = years.last;
    final Map<int, DividendCagr> cagrs = <int, DividendCagr>{};
    for (final int period in standardPeriods) {
      final int startYear = endYear - period;
      if (!_hasEveryYear(totals, startYear, endYear)) {
        continue;
      }
      final Money beginning = totals[startYear]!;
      final Money ending = totals[endYear]!;
      if (!beginning.isPositive || !ending.isPositive) {
        continue;
      }
      cagrs[period] = DividendCagr(
        periodYears: period,
        startYear: startYear,
        endYear: endYear,
        beginningAnnualDividend: beginning,
        endingAnnualDividend: ending,
        rate: _cagr(beginning.amount, ending.amount, period),
      );
    }

    AnnualDividendChange? latestIncrease;
    AnnualDividendChange? latestDecrease;
    for (int index = 1; index < years.length; index++) {
      final int previousYear = years[index - 1];
      final int currentYear = years[index];
      if (currentYear != previousYear + 1) {
        continue;
      }
      final Money previous = totals[previousYear]!;
      final Money current = totals[currentYear]!;
      final int comparison = current.compareTo(previous);
      if (comparison == 0) {
        continue;
      }
      final AnnualDividendChange change = AnnualDividendChange(
        direction: comparison > 0
            ? DividendChangeDirection.increase
            : DividendChangeDirection.decrease,
        previousYear: previousYear,
        currentYear: currentYear,
        previousAnnualDividend: previous,
        currentAnnualDividend: current,
        rate: previous.isZero
            ? null
            : Percentage.fromRate(
                (current.amount / previous.amount).toDecimal(
                      scaleOnInfinitePrecision: 12,
                    ) -
                    Decimal.one,
              ),
      );
      if (comparison > 0) {
        latestIncrease = change;
      } else {
        latestDecrease = change;
      }
    }

    int yearsWithoutCut = 0;
    for (int index = years.length - 1; index > 0; index--) {
      final int currentYear = years[index];
      final int previousYear = years[index - 1];
      if (currentYear != previousYear + 1 ||
          totals[currentYear]!.compareTo(totals[previousYear]!) < 0) {
        break;
      }
      yearsWithoutCut++;
    }

    return DividendGrowthAnalysis(
      instrumentId: instrumentId,
      currency: currency,
      annualTotals: List<AnnualDividendTotal>.unmodifiable(annualTotals),
      cagrs: Map<int, DividendCagr>.unmodifiable(cagrs),
      yearsWithoutCut: yearsWithoutCut,
      latestIncrease: latestIncrease,
      latestDecrease: latestDecrease,
    );
  }

  static bool _hasEveryYear(Map<int, Money> totals, int start, int end) {
    for (int year = start; year <= end; year++) {
      if (!totals.containsKey(year)) {
        return false;
      }
    }
    return true;
  }

  static Percentage _cagr(Decimal beginning, Decimal ending, int years) {
    // Decimal keeps all annual money aggregation exact. A fractional root is
    // necessarily approximate; constrain that approximation to 12 rate digits
    // before returning to the Decimal-backed Percentage value object.
    final double rate =
        math.pow((ending / beginning).toDouble(), 1 / years).toDouble() - 1;
    if (!rate.isFinite) {
      throw StateError('Dividend CAGR is outside the supported numeric range.');
    }
    return Percentage.fromRate(Decimal.parse(rate.toStringAsFixed(12)));
  }
}
