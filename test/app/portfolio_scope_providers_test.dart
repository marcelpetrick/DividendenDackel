import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/portfolio/portfolio_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('consolidates duplicate instruments using exact weighted cost', () {
    final DateTime now = DateTime.utc(2026, 8, 23);
    final Provenance user = Provenance.user(now);
    final List<Holding> consolidated =
        PortfolioScopeProjector.consolidateHoldings(<Holding>[
          Holding(
            instrumentId: 'asset',
            quantity: Decimal.parse('2'),
            averagePurchasePrice: Money.parse('100', Currency.eur),
            provenance: user,
          ),
          Holding(
            portfolioId: 'retirement',
            instrumentId: 'asset',
            quantity: Decimal.parse('3'),
            averagePurchasePrice: Money.parse('120', Currency.eur),
            provenance: user,
          ),
        ]);

    expect(consolidated, hasLength(1));
    expect(consolidated.single.portfolioId, InvestmentPortfolio.consolidatedId);
    expect(consolidated.single.quantity, Decimal.parse('5'));
    expect(
      consolidated.single.averagePurchasePrice,
      Money.parse('112', Currency.eur),
    );
  });

  test('does not invent a consolidated cost when one cost is unknown', () {
    final Provenance user = Provenance.user(DateTime.utc(2026, 8, 23));
    final Holding consolidated = PortfolioScopeProjector.consolidateHoldings(
      <Holding>[
        Holding(
          instrumentId: 'asset',
          quantity: Decimal.one,
          averagePurchasePrice: Money.parse('100', Currency.eur),
          provenance: user,
        ),
        Holding(
          portfolioId: 'retirement',
          instrumentId: 'asset',
          quantity: Decimal.one,
          provenance: user,
        ),
      ],
    ).single;

    expect(consolidated.averagePurchasePrice, isNull);
  });
}
