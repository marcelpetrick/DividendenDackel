import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/holding.dart';
import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:dividendendackel/domain/value_objects/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 22);
  final Provenance userProvenance = Provenance.user(now);

  Holding holdingOf(String quantity, {Money? averagePrice}) => Holding(
    instrumentId: 'isin:DE0008404005',
    quantity: Decimal.parse(quantity),
    averagePurchasePrice: averagePrice,
    provenance: userProvenance,
  );

  group('Holding', () {
    test('requires only an instrument and a quantity', () {
      final Holding holding = holdingOf('20');

      expect(holding.instrumentId, 'isin:DE0008404005');
      expect(holding.quantity, Decimal.fromInt(20));
      expect(holding.averagePurchasePrice, isNull);
      expect(holding.purchaseDate, isNull);
    });

    test('supports fractional quantities', () {
      expect(holdingOf('1.5').quantity, Decimal.parse('1.5'));
    });

    test('rejects a negative quantity', () {
      expect(
        () => Holding(
          instrumentId: 'x',
          quantity: Decimal.parse('-1'),
          provenance: userProvenance,
        ),
        throwsArgumentError,
      );
    });

    test('treats a zero quantity as empty', () {
      expect(holdingOf('0').isEmpty, isTrue);
      expect(holdingOf('1').isEmpty, isFalse);
    });

    test('computes the position value at a price', () {
      expect(
        holdingOf('20').valueAt(Money.parse('287.50', Currency.eur)),
        Money.parse('5750', Currency.eur),
      );
    });

    test('computes the cost basis when an average price is known', () {
      final Holding holding = holdingOf(
        '20',
        averagePrice: Money.parse('210.00', Currency.eur),
      );

      expect(holding.costBasis, Money.parse('4200', Currency.eur));
      expect(
        holding.unrealizedGainAt(Money.parse('287.50', Currency.eur)),
        Money.parse('1550', Currency.eur),
      );
    });

    test('returns null rather than guessing without a purchase price', () {
      final Holding holding = holdingOf('20');

      expect(holding.costBasis, isNull);
      expect(
        holding.unrealizedGainAt(Money.parse('287.50', Currency.eur)),
        isNull,
      );
    });

    test('reports a loss as a negative gain', () {
      final Holding holding = holdingOf(
        '10',
        averagePrice: Money.parse('300', Currency.eur),
      );

      expect(
        holding.unrealizedGainAt(Money.parse('287.50', Currency.eur)),
        Money.parse('-125', Currency.eur),
      );
    });

    test('keeps the quantity out of its string form', () {
      // Vision.md §80: portfolio content must not leak into logs.
      expect(holdingOf('1337').toString(), isNot(contains('1337')));
    });

    test('compares by value', () {
      expect(holdingOf('20'), holdingOf('20'));
      expect(holdingOf('20').hashCode, holdingOf('20').hashCode);
      expect(holdingOf('20'), isNot(holdingOf('21')));
    });
  });

  group('WatchlistEntry', () {
    test('records when the user started following an instrument', () {
      final WatchlistEntry entry = WatchlistEntry(
        instrumentId: 'sym:AAPL',
        addedAt: now,
        provenance: userProvenance,
      );

      expect(entry.instrumentId, 'sym:AAPL');
      expect(entry.addedAt, now);
      expect(entry.provenance.isUserProvided, isTrue);
    });

    test('compares by value', () {
      final WatchlistEntry a = WatchlistEntry(
        instrumentId: 'sym:AAPL',
        addedAt: now,
        provenance: userProvenance,
      );
      final WatchlistEntry b = WatchlistEntry(
        instrumentId: 'sym:AAPL',
        addedAt: now,
        provenance: userProvenance,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
