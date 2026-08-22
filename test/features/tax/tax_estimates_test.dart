import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/settings/tax_settings.dart';
import 'package:dividendendackel/features/tax/tax_estimates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final WithholdingRateTable table = WithholdingRateTable(
    version: 1,
    asOf: DateTime.utc(2024),
    source: 'test',
    sourceUrl: 'https://example.invalid',
    rates: <String, WithholdingRule>{
      'DE': WithholdingRule(
        country: 'DE',
        statutoryRate: Percentage.zero,
        treatyRateWithForms: Percentage.zero,
        creditableCap: Percentage.zero,
      ),
    },
  );
  final Provenance provenance = Provenance(
    source: 'test',
    fetchedAt: DateTime.utc(2026),
  );
  final Holding holding = Holding(
    instrumentId: 'de',
    quantity: Decimal.one,
    provenance: provenance,
  );
  const Instrument instrument = Instrument(
    internalId: 'de',
    symbol: 'DE',
    name: 'German share',
    currency: Currency.eur,
    country: 'DE',
  );

  DividendEvent event(String amount, DateTime date) => DividendEvent(
    instrumentId: 'de',
    amountPerShare: Money.parse(amount, Currency.eur),
    status: DividendStatus.confirmed,
    paymentDate: date,
    provenance: provenance,
  );

  test('orders payments before consuming the annual allowance', () {
    final DividendEvent later = event('100', DateTime.utc(2026, 8));
    final DividendEvent earlier = event('100', DateTime.utc(2026, 2));
    final PortfolioTaxEstimates result = PortfolioTaxEstimator.calculate(
      year: 2026,
      events: <DividendEvent>[later, earlier],
      holdings: <Holding>[holding],
      instruments: const <String, Instrument>{'de': instrument},
      settings: TaxSettings(
        profile: DividendTaxProfile(
          annualAllowance: Money.parse('150', Currency.eur),
        ),
        table: table,
      ),
    );

    final DividendTaxBreakdown first =
        result.byEventKey[dividendTaxEventKey(earlier)]!.result
            as DividendTaxBreakdown;
    final DividendTaxBreakdown second =
        result.byEventKey[dividendTaxEventKey(later)]!.result
            as DividendTaxBreakdown;
    expect(first.allowanceApplied, Money.parse('100', Currency.eur));
    expect(first.net, Money.parse('100', Currency.eur));
    expect(second.allowanceApplied, Money.parse('50', Currency.eur));
    expect(second.net, Money.parse('86.81', Currency.eur));
  });

  test('does not relabel a foreign-currency gross amount as EUR', () {
    final Holding foreignHolding = Holding(
      instrumentId: 'us',
      quantity: Decimal.one,
      provenance: provenance,
    );
    final DividendEvent foreign = DividendEvent(
      instrumentId: 'us',
      amountPerShare: Money.parse('10', Currency.usd),
      status: DividendStatus.confirmed,
      paymentDate: DateTime.utc(2026, 2),
      provenance: provenance,
    );
    final PortfolioTaxEstimates result = PortfolioTaxEstimator.calculate(
      year: 2026,
      events: <DividendEvent>[foreign],
      holdings: <Holding>[foreignHolding],
      instruments: const <String, Instrument>{},
      settings: TaxSettings(profile: DividendTaxProfile(), table: table),
    );

    final TaxEventEstimate estimate =
        result.byEventKey[dividendTaxEventKey(foreign)]!;
    expect(estimate.gross, Money.parse('10', Currency.usd));
    expect(estimate.result, isA<UnsupportedTaxCalculation>());
  });
}
