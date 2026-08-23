import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates shares, income, yield and concentration impact', () {
    final DividendSimulation result = DividendSimulator.calculate(
      additionalInvestment: Money.parse('1000', Currency.eur),
      sharePrice: Money.parse('100', Currency.eur),
      existingQuantity: Decimal.fromInt(20),
      existingPositionValue: Money.parse('2000', Currency.eur),
      portfolioValue: Money.parse('10000', Currency.eur),
      annualDividendPerShare: Money.parse('5', Currency.eur),
    );

    expect(result.additionalShares, Decimal.fromInt(10));
    expect(result.additionalAnnualDividend, Money.parse('50', Currency.eur));
    expect(
      result.averageMonthlyDividend.roundedToCurrency(),
      Money.parse('4.17', Currency.eur),
    );
    expect(result.newPositionQuantity, Decimal.fromInt(30));
    expect(result.previousWeight, Percentage.parsePercent('20'));
    expect(result.newWeight.format(), '27.3%');
    expect(result.weightChange.format(withSign: true), '+7.3%');
    expect(result.newForwardYield, Percentage.parsePercent('5'));
  });

  test('keeps fractional shares at explicit precision', () {
    final DividendSimulation result = DividendSimulator.calculate(
      additionalInvestment: Money.parse('100', Currency.usd),
      sharePrice: Money.parse('30', Currency.usd),
      existingQuantity: Decimal.one,
      existingPositionValue: Money.parse('30', Currency.usd),
      portfolioValue: Money.parse('60', Currency.usd),
      annualDividendPerShare: Money.parse('1.5', Currency.usd),
    );

    expect(result.additionalShares, Decimal.parse('3.33333333'));
    expect(
      result.additionalAnnualDividend,
      Money.parse('4.999999995', Currency.usd),
    );
  });

  test('rejects non-positive and mixed-currency inputs', () {
    expect(
      () => DividendSimulator.calculate(
        additionalInvestment: Money.zero(Currency.eur),
        sharePrice: Money.parse('100', Currency.eur),
        existingQuantity: Decimal.one,
        existingPositionValue: Money.parse('100', Currency.eur),
        portfolioValue: Money.parse('100', Currency.eur),
        annualDividendPerShare: Money.parse('5', Currency.eur),
      ),
      throwsArgumentError,
    );
    expect(
      () => DividendSimulator.calculate(
        additionalInvestment: Money.parse('100', Currency.usd),
        sharePrice: Money.parse('100', Currency.eur),
        existingQuantity: Decimal.one,
        existingPositionValue: Money.parse('100', Currency.eur),
        portfolioValue: Money.parse('100', Currency.eur),
        annualDividendPerShare: Money.parse('5', Currency.eur),
      ),
      throwsA(isA<CurrencyMismatchError>()),
    );
  });
}
