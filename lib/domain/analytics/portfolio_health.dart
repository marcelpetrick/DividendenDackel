import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/currency_conversion.dart';
import 'package:dividendendackel/domain/analytics/portfolio_overview.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// One explainable share of a portfolio-health distribution.
final class PortfolioHealthSlice {
  /// Creates a slice.
  const PortfolioHealthSlice({
    required this.label,
    required this.value,
    required this.share,
  });

  /// Instrument name or normalized category.
  final String label;

  /// Covered value in the selected display currency.
  final Money value;

  /// Share of the covered total.
  final Percentage share;
}

/// Concentration and exposure facts with explicit data coverage.
final class PortfolioHealth {
  /// Creates a health result.
  const PortfolioHealth({
    required this.displayCurrency,
    required this.coveredValue,
    required this.coveredIncome,
    required this.positionCount,
    required this.pricedPositionCount,
    required this.incomePositionCount,
    required this.missingValueCurrencies,
    required this.missingIncomeCurrencies,
    required this.positions,
    required this.sectors,
    required this.countries,
    required this.currencies,
    required this.dividendIncome,
    required this.topFiveShare,
    required this.insights,
  });

  final Currency displayCurrency;
  final Money coveredValue;
  final Money coveredIncome;
  final int positionCount;
  final int pricedPositionCount;
  final int incomePositionCount;
  final Set<Currency> missingValueCurrencies;
  final Set<Currency> missingIncomeCurrencies;
  final List<PortfolioHealthSlice> positions;
  final List<PortfolioHealthSlice> sectors;
  final List<PortfolioHealthSlice> countries;
  final List<PortfolioHealthSlice> currencies;
  final List<PortfolioHealthSlice> dividendIncome;
  final Percentage? topFiveShare;
  final List<String> insights;

  /// Whether every non-empty holding has a priced, convertible value.
  bool get valueCoverageComplete => pricedPositionCount == positionCount;
}

/// Calculates transparent portfolio-health facts without assigning a verdict.
abstract final class PortfolioHealthCalculator {
  /// Calculates value and income concentration in [displayCurrency].
  static PortfolioHealth calculate({
    required PortfolioOverview overview,
    required Currency displayCurrency,
    required FxRateBook rates,
    required DateTime asOf,
  }) {
    final List<_CoveredPosition> coveredValues = <_CoveredPosition>[];
    final List<_CoveredPosition> coveredIncome = <_CoveredPosition>[];
    final Set<Currency> missingValueCurrencies = <Currency>{};
    final Set<Currency> missingIncomeCurrencies = <Currency>{};
    final int positionCount = overview.positions
        .where((PortfolioPositionSummary item) => !item.holding.isEmpty)
        .length;

    for (final PortfolioPositionSummary position in overview.positions) {
      final Money? value = position.value;
      if (value != null && !value.isZero) {
        final FxConversion? conversion = rates.convert(
          value,
          displayCurrency,
          asOf: asOf,
        );
        if (conversion == null) {
          missingValueCurrencies.add(value.currency);
        } else {
          coveredValues.add(
            _CoveredPosition(position: position, value: conversion.converted),
          );
        }
      }
      final Money? income = position.forecastAnnualDividend;
      if (income != null && !income.isZero) {
        final FxConversion? conversion = rates.convert(
          income,
          displayCurrency,
          asOf: asOf,
        );
        if (conversion == null) {
          missingIncomeCurrencies.add(income.currency);
        } else {
          coveredIncome.add(
            _CoveredPosition(position: position, value: conversion.converted),
          );
        }
      }
    }

    final Money valueTotal = _total(coveredValues, displayCurrency);
    final Money incomeTotal = _total(coveredIncome, displayCurrency);
    final List<PortfolioHealthSlice> positions = _positionSlices(
      coveredValues,
      valueTotal,
    );
    final List<PortfolioHealthSlice> sectors = _groupedSlices(
      coveredValues,
      valueTotal,
      (_CoveredPosition item) => item.position.instrument?.sector ?? 'Unknown',
    );
    final List<PortfolioHealthSlice> countries = _groupedSlices(
      coveredValues,
      valueTotal,
      (_CoveredPosition item) => item.position.instrument?.country ?? 'Unknown',
    );
    final List<PortfolioHealthSlice> currencies = _groupedSlices(
      coveredValues,
      valueTotal,
      (_CoveredPosition item) =>
          item.position.instrument?.currency.code ??
          item.position.value?.currency.code ??
          'Unknown',
    );
    final List<PortfolioHealthSlice> income = _positionSlices(
      coveredIncome,
      incomeTotal,
    );
    final Percentage? topFive = valueTotal.isZero
        ? null
        : _percentage(
            positions
                .take(5)
                .fold<Decimal>(
                  Decimal.zero,
                  (sum, item) => sum + item.value.amount,
                ),
            valueTotal.amount,
          );

    return PortfolioHealth(
      displayCurrency: displayCurrency,
      coveredValue: valueTotal,
      coveredIncome: incomeTotal,
      positionCount: positionCount,
      pricedPositionCount: coveredValues.length,
      incomePositionCount: coveredIncome.length,
      missingValueCurrencies: Set<Currency>.unmodifiable(
        missingValueCurrencies,
      ),
      missingIncomeCurrencies: Set<Currency>.unmodifiable(
        missingIncomeCurrencies,
      ),
      positions: positions,
      sectors: sectors,
      countries: countries,
      currencies: currencies,
      dividendIncome: income,
      topFiveShare: topFive,
      insights: List<String>.unmodifiable(
        _insights(
          positions: positions,
          sectors: sectors,
          countries: countries,
          currencies: currencies,
          income: income,
          incomeTotal: incomeTotal,
        ),
      ),
    );
  }

  static Money _total(List<_CoveredPosition> values, Currency currency) =>
      values.fold<Money>(
        Money.zero(currency),
        (Money total, _CoveredPosition item) => total + item.value,
      );

  static List<PortfolioHealthSlice> _positionSlices(
    List<_CoveredPosition> values,
    Money total,
  ) => _sort(<PortfolioHealthSlice>[
    for (final _CoveredPosition item in values)
      PortfolioHealthSlice(
        label:
            item.position.instrument?.name ??
            item.position.holding.instrumentId,
        value: item.value,
        share: total.isZero
            ? Percentage.zero
            : _percentage(item.value.amount, total.amount),
      ),
  ]);

  static List<PortfolioHealthSlice> _groupedSlices(
    List<_CoveredPosition> values,
    Money total,
    String Function(_CoveredPosition item) categoryOf,
  ) {
    final Map<String, Money> grouped = <String, Money>{};
    for (final _CoveredPosition item in values) {
      final String category = categoryOf(item).trim();
      final String label = category.isEmpty ? 'Unknown' : category;
      grouped[label] =
          (grouped[label] ?? Money.zero(total.currency)) + item.value;
    }
    return _sort(<PortfolioHealthSlice>[
      for (final MapEntry<String, Money> entry in grouped.entries)
        PortfolioHealthSlice(
          label: entry.key,
          value: entry.value,
          share: total.isZero
              ? Percentage.zero
              : _percentage(entry.value.amount, total.amount),
        ),
    ]);
  }

  static List<PortfolioHealthSlice> _sort(List<PortfolioHealthSlice> values) =>
      List<PortfolioHealthSlice>.unmodifiable(
        values..sort((a, b) => b.value.compareTo(a.value)),
      );

  static Percentage _percentage(Decimal part, Decimal total) =>
      Percentage.fromRate(
        (part / total).toDecimal(scaleOnInfinitePrecision: 10),
      );

  static List<String> _insights({
    required List<PortfolioHealthSlice> positions,
    required List<PortfolioHealthSlice> sectors,
    required List<PortfolioHealthSlice> countries,
    required List<PortfolioHealthSlice> currencies,
    required List<PortfolioHealthSlice> income,
    required Money incomeTotal,
  }) {
    final List<String> result = <String>[];
    if (positions.firstOrNull case final PortfolioHealthSlice largest) {
      result.add(
        '${largest.label} is the largest priced position at '
        '${largest.share.format()}.',
      );
    }
    for (final (String, List<PortfolioHealthSlice>) category
        in <(String, List<PortfolioHealthSlice>)>[
          ('sector', sectors),
          ('country', countries),
          ('currency', currencies),
        ]) {
      if (category.$2.firstOrNull case final PortfolioHealthSlice largest) {
        result.add(
          'Largest ${category.$1} exposure: ${largest.label} at '
          '${largest.share.format()}.',
        );
      }
    }
    if (!incomeTotal.isZero) {
      Decimal accumulated = Decimal.zero;
      int contributors = 0;
      for (final PortfolioHealthSlice item in income) {
        accumulated += item.value.amount;
        contributors++;
        if (accumulated >= incomeTotal.amount * Decimal.parse('0.6')) break;
      }
      result.add(
        '${_percentage(accumulated, incomeTotal.amount).format()} of expected '
        'dividend income comes from $contributors '
        '${contributors == 1 ? 'company' : 'companies'}.',
      );
    }
    return result;
  }
}

final class _CoveredPosition {
  const _CoveredPosition({required this.position, required this.value});
  final PortfolioPositionSummary position;
  final Money value;
}
