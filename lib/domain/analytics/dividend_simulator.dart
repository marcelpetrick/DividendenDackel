import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Deterministic before/after result for an additional holding investment.
final class DividendSimulation {
  /// Creates a simulation result.
  const DividendSimulation({
    required this.additionalInvestment,
    required this.sharePrice,
    required this.additionalShares,
    required this.additionalAnnualDividend,
    required this.averageMonthlyDividend,
    required this.newPositionQuantity,
    required this.previousWeight,
    required this.newWeight,
    required this.weightChange,
    required this.newForwardYield,
  });

  final Money additionalInvestment;
  final Money sharePrice;
  final Decimal additionalShares;
  final Money additionalAnnualDividend;
  final Money averageMonthlyDividend;
  final Decimal newPositionQuantity;
  final Percentage previousWeight;
  final Percentage newWeight;
  final Percentage weightChange;
  final Percentage newForwardYield;
}

/// Currency-safe additional-investment simulator (Vision.md §21).
abstract final class DividendSimulator {
  /// Calculates fractional shares and gross income from cached facts.
  static DividendSimulation calculate({
    required Money additionalInvestment,
    required Money sharePrice,
    required Decimal existingQuantity,
    required Money existingPositionValue,
    required Money portfolioValue,
    required Money annualDividendPerShare,
  }) {
    final Currency currency = sharePrice.currency;
    for (final Money amount in <Money>[
      additionalInvestment,
      existingPositionValue,
      portfolioValue,
      annualDividendPerShare,
    ]) {
      if (amount.currency != currency) {
        throw CurrencyMismatchError(
          'dividend simulation',
          currency,
          amount.currency,
        );
      }
    }
    if (!additionalInvestment.isPositive) {
      throw ArgumentError.value(
        additionalInvestment,
        'additionalInvestment',
        'must be greater than zero',
      );
    }
    if (!sharePrice.isPositive) {
      throw ArgumentError.value(
        sharePrice,
        'sharePrice',
        'must be greater than zero',
      );
    }
    if (existingQuantity < Decimal.zero ||
        existingPositionValue.isNegative ||
        portfolioValue.isNegative ||
        annualDividendPerShare.isNegative) {
      throw ArgumentError('Existing simulation inputs must not be negative.');
    }
    if (existingPositionValue > portfolioValue) {
      throw ArgumentError(
        'Existing position value must not exceed portfolio value.',
      );
    }

    final Decimal shares = (additionalInvestment.amount / sharePrice.amount)
        .toDecimal(scaleOnInfinitePrecision: 8);
    final Money addedIncome = annualDividendPerShare * shares;
    final Money newPositionValue = existingPositionValue + additionalInvestment;
    final Money newPortfolioValue = portfolioValue + additionalInvestment;
    final Money newAnnualIncome =
        annualDividendPerShare * (existingQuantity + shares);
    final Percentage previousWeight = portfolioValue.isZero
        ? Percentage.zero
        : _ratio(existingPositionValue.amount, portfolioValue.amount);
    final Percentage newWeight = _ratio(
      newPositionValue.amount,
      newPortfolioValue.amount,
    );

    return DividendSimulation(
      additionalInvestment: additionalInvestment,
      sharePrice: sharePrice,
      additionalShares: shares,
      additionalAnnualDividend: addedIncome,
      averageMonthlyDividend: addedIncome.dividedBy(Decimal.fromInt(12)),
      newPositionQuantity: existingQuantity + shares,
      previousWeight: previousWeight,
      newWeight: newWeight,
      weightChange: Percentage.fromRate(newWeight.rate - previousWeight.rate),
      newForwardYield: newPositionValue.isZero
          ? Percentage.zero
          : _ratio(newAnnualIncome.amount, newPositionValue.amount),
    );
  }

  static Percentage _ratio(Decimal part, Decimal whole) => Percentage.fromRate(
    (part / whole).toDecimal(scaleOnInfinitePrecision: 10),
  );
}
