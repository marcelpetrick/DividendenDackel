import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WithholdingRule rule(
    String country,
    String statutory,
    String treaty,
    String cap,
  ) => WithholdingRule(
    country: country,
    statutoryRate: Percentage.parsePercent(statutory),
    treatyRateWithForms: Percentage.parsePercent(treaty),
    creditableCap: Percentage.parsePercent(cap),
  );
  final WithholdingRateTable table = WithholdingRateTable(
    version: 1,
    asOf: DateTime.utc(2024),
    source: 'test',
    sourceUrl: 'https://example.test',
    rates: <String, WithholdingRule>{
      'DE': rule('DE', '0', '0', '0'),
      'US': rule('US', '30', '15', '15'),
      'CH': rule('CH', '35', '35', '15'),
      'GB': rule('GB', '0', '0', '0'),
      'NL': rule('NL', '15', '15', '15'),
    },
  );
  final DividendTaxCalculator calculator = DividendTaxCalculator(table);

  TaxableDividend dividend(String country, String gross, {int day = 1}) =>
      TaxableDividend(
        instrumentId: 'asset-$country',
        sourceCountry: country,
        paymentDate: DateTime.utc(2026, 5, day),
        grossEur: Money.parse(gross, Currency.eur),
      );
  DividendTaxProfile profile({
    ChurchTaxRate church = ChurchTaxRate.none,
    String allowance = '0',
    Map<String, bool> forms = const <String, bool>{},
    Map<String, WithholdingRule> overrides = const <String, WithholdingRule>{},
  }) => DividendTaxProfile(
    churchTaxRate: church,
    annualAllowance: Money.parse(allowance, Currency.eur),
    treatyFormsFiled: forms,
    countryRuleOverrides: overrides,
  );

  DividendTaxBreakdown calculate(
    String country, {
    String gross = '100',
    DividendTaxProfile? taxProfile,
  }) =>
      calculator
              .calculateYear(
                dividends: <TaxableDividend>[dividend(country, gross)],
                profile: taxProfile ?? profile(),
              )
              .results
              .single
          as DividendTaxBreakdown;

  test('calculates a German dividend without foreign withholding', () {
    final DividendTaxBreakdown result = calculate('DE');

    expect(result.withheldAtSource, Money.zero(Currency.eur));
    expect(result.kapitalertragsteuer, Money.parse('25', Currency.eur));
    expect(result.solidaritaetszuschlag, Money.parse('1.38', Currency.eur));
    expect(result.net, Money.parse('73.62', Currency.eur));
  });

  test('credits US treaty withholding against German tax', () {
    final DividendTaxBreakdown result = calculate('US');

    expect(result.withheldAtSource, Money.parse('15', Currency.eur));
    expect(result.creditableWithholding, Money.parse('15', Currency.eur));
    expect(result.withholdingCreditApplied, Money.parse('15', Currency.eur));
    expect(result.kapitalertragsteuer, Money.parse('10', Currency.eur));
    expect(result.net, Money.parse('74.45', Currency.eur));
  });

  test('covers zero-rate UK and 15% Dutch country rules', () {
    final DividendTaxBreakdown uk = calculate('GB');
    final DividendTaxBreakdown netherlands = calculate('NL');

    expect(uk.withheldAtSource, Money.zero(Currency.eur));
    expect(uk.net, Money.parse('73.62', Currency.eur));
    expect(netherlands.withheldAtSource, Money.parse('15', Currency.eur));
    expect(netherlands.net, Money.parse('74.45', Currency.eur));
  });

  test('keeps excess Swiss withholding reclaimable but outside net', () {
    final DividendTaxBreakdown result = calculate('CH');

    expect(result.withheldAtSource, Money.parse('35', Currency.eur));
    expect(result.creditableWithholding, Money.parse('15', Currency.eur));
    expect(result.reclaimableWithholding, Money.parse('20', Currency.eur));
    expect(result.net, Money.parse('54.45', Currency.eur));
    expect(
      result.assumptions,
      contains('Reclaimable withholding is not added back to net cash.'),
    );
  });

  test('applies the official church-tax-adjusted formula', () {
    final DividendTaxBreakdown result = calculate(
      'US',
      taxProfile: profile(church: ChurchTaxRate.ninePercent),
    );

    expect(result.kapitalertragsteuer, Money.parse('9.78', Currency.eur));
    expect(result.solidaritaetszuschlag, Money.parse('0.54', Currency.eur));
    expect(result.kirchensteuer, Money.parse('0.88', Currency.eur));
    expect(result.net, Money.parse('73.80', Currency.eur));
  });

  test('tracks the savings allowance once in payment order', () {
    final AnnualDividendTaxResult annual = calculator.calculateYear(
      dividends: <TaxableDividend>[
        dividend('DE', '100', day: 20),
        dividend('DE', '100', day: 10),
      ],
      profile: profile(allowance: '150'),
    );

    final DividendTaxBreakdown first =
        annual.results.first as DividendTaxBreakdown;
    final DividendTaxBreakdown second =
        annual.results.last as DividendTaxBreakdown;
    expect(first.allowanceApplied, Money.parse('100', Currency.eur));
    expect(first.net, Money.parse('100', Currency.eur));
    expect(second.allowanceApplied, Money.parse('50', Currency.eur));
    expect(second.net, Money.parse('86.81', Currency.eur));
    expect(annual.allowanceRemaining, Money.zero(Currency.eur));
  });

  test('uses statutory withholding when treaty forms are not filed', () {
    final DividendTaxBreakdown result = calculate(
      'US',
      taxProfile: profile(forms: const <String, bool>{'US': false}),
    );

    expect(result.withheldAtSource, Money.parse('30', Currency.eur));
    expect(result.reclaimableWithholding, Money.parse('15', Currency.eur));
    expect(result.net, Money.parse('59.45', Currency.eur));
  });

  test(
    'supports user country overrides without changing the bundled table',
    () {
      final WithholdingRule edited = rule('US', '30', '10', '10');
      final DividendTaxBreakdown result = calculate(
        'US',
        taxProfile: profile(overrides: <String, WithholdingRule>{'US': edited}),
      );

      expect(result.withheldAtSource, Money.parse('10', Currency.eur));
      expect(table['US']!.treatyRateWithForms.format(), '15.0%');
    },
  );

  test('refuses unsupported residence and unknown source country', () {
    final DividendTaxResult residence = calculator
        .calculateYear(
          dividends: <TaxableDividend>[dividend('DE', '100')],
          profile: DividendTaxProfile(taxResidenceCountry: 'AT'),
        )
        .results
        .single;
    final DividendTaxResult country = calculator
        .calculateYear(
          dividends: <TaxableDividend>[dividend('XX', '100')],
          profile: profile(),
        )
        .results
        .single;

    expect(residence, isA<UnsupportedTaxCalculation>());
    expect(country, isA<UnsupportedTaxCalculation>());
  });

  test('refuses to consume one allowance across mixed calendar years', () {
    expect(
      () => calculator.calculateYear(
        dividends: <TaxableDividend>[
          dividend('DE', '10'),
          TaxableDividend(
            instrumentId: 'a',
            sourceCountry: 'DE',
            paymentDate: DateTime.utc(2027),
            grossEur: Money.parse('10', Currency.eur),
          ),
        ],
        profile: profile(),
      ),
      throwsArgumentError,
    );
  });
}
