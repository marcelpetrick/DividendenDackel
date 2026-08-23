import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/dividend_reconciliation.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 1, 1);
  final Provenance user = Provenance.user(now);

  PortfolioActivity activity({
    required int id,
    required PortfolioActivityType type,
    required DateTime date,
    String? instrumentId,
    String? quantity,
    String? cash,
    int? reverses,
  }) => PortfolioActivity(
    id: id,
    portfolioId: 'default',
    type: type,
    occurredAt: date,
    instrumentId: instrumentId,
    quantity: quantity == null ? null : Decimal.parse(quantity),
    cashAmount: cash == null ? null : Money.parse(cash, Currency.eur),
    reversesActivityId: reverses,
    provenance: user,
  );

  test('uses the quantity held on the payment date', () {
    final List<DividendReconciliationLine> result =
        DividendReconciliationCalculator.calculate(
          activities: <PortfolioActivity>[
            activity(
              id: 1,
              type: PortfolioActivityType.purchase,
              date: DateTime.utc(2026, 1, 5),
              instrumentId: 'asset',
              quantity: '10',
            ),
            activity(
              id: 2,
              type: PortfolioActivityType.sale,
              date: DateTime.utc(2026, 3, 1),
              instrumentId: 'asset',
              quantity: '4',
            ),
            activity(
              id: 3,
              type: PortfolioActivityType.dividend,
              date: DateTime.utc(2026, 2, 20),
              instrumentId: 'asset',
              cash: '11',
            ),
          ],
          expectedEvents: <DividendEvent>[
            DividendEvent(
              instrumentId: 'asset',
              amountPerShare: Money.parse('1', Currency.eur),
              status: DividendStatus.confirmed,
              paymentDate: DateTime.utc(2026, 2, 20),
              provenance: user,
            ),
          ],
          start: DateTime.utc(2026),
          end: DateTime.utc(2027),
        );

    expect(result.single.expectedGross, Money.parse('10', Currency.eur));
    expect(result.single.actualGross, Money.parse('11', Currency.eur));
    expect(result.single.variance, Money.parse('1', Currency.eur));
  });

  test('excludes reversed security and dividend activities', () {
    final List<DividendReconciliationLine> result =
        DividendReconciliationCalculator.calculate(
          activities: <PortfolioActivity>[
            activity(
              id: 1,
              type: PortfolioActivityType.purchase,
              date: now,
              instrumentId: 'asset',
              quantity: '10',
            ),
            activity(
              id: 2,
              type: PortfolioActivityType.reversal,
              date: now,
              instrumentId: 'asset',
              reverses: 1,
            ),
            activity(
              id: 3,
              type: PortfolioActivityType.dividend,
              date: DateTime.utc(2026, 2),
              cash: '20',
            ),
            activity(
              id: 4,
              type: PortfolioActivityType.reversal,
              date: DateTime.utc(2026, 2),
              reverses: 3,
            ),
          ],
          expectedEvents: <DividendEvent>[
            DividendEvent(
              instrumentId: 'asset',
              amountPerShare: Money.parse('1', Currency.eur),
              status: DividendStatus.confirmed,
              paymentDate: DateTime.utc(2026, 2),
              provenance: user,
            ),
          ],
          start: DateTime.utc(2026),
          end: DateTime.utc(2027),
        );

    expect(result, isEmpty);
  });
}
