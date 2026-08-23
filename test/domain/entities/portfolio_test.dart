import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23);
  final Provenance user = Provenance.user(now);

  test('portfolio requires a stable identity and visible name', () {
    expect(
      () => InvestmentPortfolio(
        id: '',
        name: 'Income',
        createdAt: now,
        updatedAt: now,
      ),
      throwsArgumentError,
    );
    expect(
      () => InvestmentPortfolio(
        id: 'income',
        name: '  ',
        createdAt: now,
        updatedAt: now,
      ),
      throwsArgumentError,
    );
  });

  test('purchase requires an instrument and positive quantity', () {
    expect(
      () => PortfolioActivity(
        portfolioId: 'income',
        type: PortfolioActivityType.purchase,
        occurredAt: now,
        quantity: Decimal.one,
        provenance: user,
      ),
      throwsArgumentError,
    );
    expect(
      () => PortfolioActivity(
        portfolioId: 'income',
        type: PortfolioActivityType.purchase,
        occurredAt: now,
        instrumentId: 'asset',
        quantity: Decimal.parse('-1'),
        provenance: user,
      ),
      throwsArgumentError,
    );
  });

  test('activity exposes its signed share impact', () {
    PortfolioActivity activity(PortfolioActivityType type) => PortfolioActivity(
      portfolioId: 'income',
      type: type,
      occurredAt: now,
      instrumentId: 'asset',
      quantity: Decimal.parse('2.5'),
      provenance: user,
    );

    expect(
      activity(PortfolioActivityType.purchase).shareDelta,
      Decimal.parse('2.5'),
    );
    expect(
      activity(PortfolioActivityType.sale).shareDelta,
      Decimal.parse('-2.5'),
    );
  });

  test('cash activity requires a positive absolute amount', () {
    expect(
      () => PortfolioActivity(
        portfolioId: 'income',
        type: PortfolioActivityType.dividend,
        occurredAt: now,
        provenance: user,
      ),
      throwsArgumentError,
    );
    expect(
      PortfolioActivity(
        portfolioId: 'income',
        type: PortfolioActivityType.dividend,
        occurredAt: now,
        cashAmount: Money.parse('12.34', Currency.eur),
        provenance: user,
      ).cashAmount,
      Money.parse('12.34', Currency.eur),
    );
  });
}
