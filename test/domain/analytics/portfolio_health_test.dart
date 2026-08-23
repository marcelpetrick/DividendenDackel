import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23);

  PortfolioPositionSummary position({
    required String id,
    required String name,
    required String value,
    required String income,
    Currency currency = Currency.eur,
    String? sector,
    String? country,
  }) {
    final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
    return PortfolioPositionSummary(
      holding: Holding(
        instrumentId: id,
        quantity: Decimal.one,
        provenance: provenance,
      ),
      instrument: Instrument(
        internalId: id,
        symbol: id,
        name: name,
        currency: currency,
        sector: sector,
        country: country,
      ),
      quote: null,
      value: Money.parse(value, currency),
      dayChange: null,
      dayChangePercent: null,
      allocation: null,
      forecastAnnualDividend: Money.parse(income, currency),
      forwardYield: null,
      nextDividend: null,
    );
  }

  test('calculates position, metadata and dividend-income concentration', () {
    final PortfolioHealth health = PortfolioHealthCalculator.calculate(
      overview: PortfolioOverview(
        positions: <PortfolioPositionSummary>[
          position(
            id: 'a',
            name: 'Alpha',
            value: '50',
            income: '30',
            sector: 'Technology',
            country: 'US',
          ),
          position(
            id: 'b',
            name: 'Beta',
            value: '30',
            income: '20',
            sector: 'Technology',
            country: 'US',
          ),
          position(
            id: 'c',
            name: 'Gamma',
            value: '20',
            income: '10',
            sector: 'Financials',
            country: 'DE',
          ),
        ],
        byCurrency: const <Currency, PortfolioCurrencySummary>{},
      ),
      displayCurrency: Currency.eur,
      rates: FxRateBook(const <FxRate>[]),
      asOf: now,
    );

    expect(health.coveredValue, Money.parse('100', Currency.eur));
    expect(health.positions.first.label, 'Alpha');
    expect(health.positions.first.share, Percentage.parsePercent('50'));
    expect(health.sectors.first.label, 'Technology');
    expect(health.sectors.first.share, Percentage.parsePercent('80'));
    expect(health.countries.first.label, 'US');
    expect(health.currencies.single.label, 'EUR');
    expect(health.topFiveShare, Percentage.parsePercent('100'));
    expect(
      health.insights,
      contains('83.3% of expected dividend income comes from 2 companies.'),
    );
  });

  test(
    'labels missing classifications as unknown instead of inventing them',
    () {
      final PortfolioHealth health = PortfolioHealthCalculator.calculate(
        overview: PortfolioOverview(
          positions: <PortfolioPositionSummary>[
            position(id: 'a', name: 'Alpha', value: '10', income: '1'),
          ],
          byCurrency: const <Currency, PortfolioCurrencySummary>{},
        ),
        displayCurrency: Currency.eur,
        rates: FxRateBook(const <FxRate>[]),
        asOf: now,
      );

      expect(health.sectors.single.label, 'Unknown');
      expect(health.countries.single.label, 'Unknown');
    },
  );

  test('excludes unconvertible values and reports incomplete coverage', () {
    final PortfolioHealth health = PortfolioHealthCalculator.calculate(
      overview: PortfolioOverview(
        positions: <PortfolioPositionSummary>[
          position(id: 'eur', name: 'Euro', value: '10', income: '1'),
          position(
            id: 'usd',
            name: 'Dollar',
            value: '20',
            income: '2',
            currency: Currency.usd,
          ),
        ],
        byCurrency: const <Currency, PortfolioCurrencySummary>{},
      ),
      displayCurrency: Currency.eur,
      rates: FxRateBook(const <FxRate>[]),
      asOf: now,
    );

    expect(health.pricedPositionCount, 1);
    expect(health.positionCount, 2);
    expect(health.valueCoverageComplete, isFalse);
    expect(health.missingValueCurrencies, <Currency>{Currency.usd});
    expect(health.missingIncomeCurrencies, <Currency>{Currency.usd});
    expect(health.coveredValue, Money.parse('10', Currency.eur));
  });
}
