import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/value_objects/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Currency', () {
    test('resolves known codes with their conventions', () {
      expect(Currency.parse('eur'), Currency.eur);
      expect(Currency.parse(' usd '), Currency.usd);
      expect(Currency.parse('JPY').decimalDigits, 0);
      expect(Currency.parse('KRW').decimalDigits, 0);
      expect(Currency.parse('EUR').decimalDigits, 2);
    });

    test('accepts an unknown code with conventional defaults', () {
      final Currency zar = Currency.parse('ZAR');

      expect(zar.code, 'ZAR');
      expect(zar.decimalDigits, 2);
      expect(zar.isKnown, isFalse);
      expect(Currency.eur.isKnown, isTrue);
    });

    test('rejects an empty code', () {
      expect(() => Currency.parse('  '), throwsArgumentError);
    });
  });

  group('Money', () {
    test('keeps exact decimal precision', () {
      // 0.1 + 0.2 == 0.30000000000000004 in binary floating point.
      final Money sum =
          Money.parse('0.1', Currency.eur) + Money.parse('0.2', Currency.eur);

      expect(sum, Money.parse('0.3', Currency.eur));
    });

    test('multiplies a per-share dividend by a holding quantity', () {
      // Vision.md §9.3: €13.80 per share on 20 shares is €276.00.
      final Money perShare = Money.parse('13.80', Currency.eur);

      expect(perShare * Decimal.fromInt(20), Money.parse('276', Currency.eur));
    });

    test('keeps four-decimal per-share amounts exact', () {
      final Money perShare = Money.parse('0.1725', Currency.usd);

      expect(
        perShare * Decimal.fromInt(1600),
        Money.parse('276', Currency.usd),
      );
    });

    test('supports fractional share quantities', () {
      final Money perShare = Money.parse('2.50', Currency.eur);

      expect(
        perShare * Decimal.parse('1.5'),
        Money.parse('3.75', Currency.eur),
      );
    });

    test('adds, subtracts and negates', () {
      final Money ten = Money.fromInt(10, Currency.eur);
      final Money three = Money.fromInt(3, Currency.eur);

      expect(ten + three, Money.fromInt(13, Currency.eur));
      expect(ten - three, Money.fromInt(7, Currency.eur));
      expect(-ten, Money.parse('-10', Currency.eur));
      expect((-ten).absolute, ten);
    });

    test('reports its sign', () {
      expect(Money.zero(Currency.eur).isZero, isTrue);
      expect(Money.fromInt(1, Currency.eur).isPositive, isTrue);
      expect(Money.fromInt(-1, Currency.eur).isNegative, isTrue);
    });

    group('currency safety', () {
      test('refuses to add different currencies', () {
        expect(
          () => Money.fromInt(1, Currency.eur) + Money.fromInt(1, Currency.usd),
          throwsA(isA<CurrencyMismatchError>()),
        );
      });

      test('refuses to subtract different currencies', () {
        expect(
          () => Money.fromInt(1, Currency.eur) - Money.fromInt(1, Currency.usd),
          throwsA(isA<CurrencyMismatchError>()),
        );
      });

      test('refuses to compare different currencies', () {
        expect(
          () => Money.fromInt(1, Currency.eur) < Money.fromInt(1, Currency.usd),
          throwsA(isA<CurrencyMismatchError>()),
        );
      });

      test('names both currencies in the error', () {
        final CurrencyMismatchError error = CurrencyMismatchError(
          '+',
          Currency.eur,
          Currency.usd,
        );

        expect(error.toString(), contains('EUR'));
        expect(error.toString(), contains('USD'));
      });
    });

    group('division', () {
      test('divides exactly when the result terminates', () {
        expect(
          Money.fromInt(10, Currency.eur).dividedBy(Decimal.fromInt(4)),
          Money.parse('2.5', Currency.eur),
        );
      });

      test('rounds to the requested scale when it does not terminate', () {
        expect(
          Money.fromInt(
            10,
            Currency.eur,
          ).dividedBy(Decimal.fromInt(3), scale: 4),
          Money.parse('3.3333', Currency.eur),
        );
      });

      test('refuses to divide by zero', () {
        expect(
          () => Money.fromInt(10, Currency.eur).dividedBy(Decimal.zero),
          throwsArgumentError,
        );
      });
    });

    group('rounding', () {
      test('rounds to the currency conventions', () {
        expect(
          Money.parse('1.005', Currency.eur).roundedToCurrency(),
          Money.parse('1.01', Currency.eur),
        );
        expect(
          Money.parse('1234.56', Currency.jpy).roundedToCurrency(),
          Money.parse('1235', Currency.jpy),
        );
      });
    });

    group('sum', () {
      test('adds every amount', () {
        expect(
          Money.sum(<Money>[
            Money.parse('1.10', Currency.eur),
            Money.parse('2.20', Currency.eur),
            Money.parse('3.30', Currency.eur),
          ], Currency.eur),
          Money.parse('6.60', Currency.eur),
        );
      });

      test('yields a typed zero for an empty list', () {
        expect(
          Money.sum(const <Money>[], Currency.usd),
          Money.zero(Currency.usd),
        );
      });

      test('refuses to mix currencies', () {
        expect(
          () => Money.sum(<Money>[
            Money.fromInt(1, Currency.eur),
            Money.fromInt(1, Currency.usd),
          ], Currency.eur),
          throwsA(isA<CurrencyMismatchError>()),
        );
      });
    });

    group('formatting', () {
      test('pads to the currency decimal digits', () {
        expect(Money.parse('2.5', Currency.eur).format(), '2.50 EUR');
        expect(Money.parse('276', Currency.eur).format(), '276.00 EUR');
        expect(Money.parse('1234', Currency.jpy).format(), '1234 JPY');
      });

      test('uses the symbol when asked and one exists', () {
        expect(
          Money.parse('13.8', Currency.eur).format(withSymbol: true),
          '€13.80',
        );
        expect(
          Money.parse('13.8', Currency.chf).format(withSymbol: true),
          '13.80 CHF',
        );
      });

      test('places the sign before the symbol', () {
        expect(
          Money.parse('-13.8', Currency.eur).format(withSymbol: true),
          '-€13.80',
        );
      });
    });

    group('equality and ordering', () {
      test('compares numerically, ignoring trailing zeros', () {
        expect(
          Money.parse('2.50', Currency.eur),
          Money.parse('2.5', Currency.eur),
        );
        expect(
          Money.parse('2.50', Currency.eur).hashCode,
          Money.parse('2.5', Currency.eur).hashCode,
        );
      });

      test('the same amount in another currency is not equal', () {
        expect(
          Money.fromInt(1, Currency.eur),
          isNot(Money.fromInt(1, Currency.usd)),
        );
      });

      test('orders by amount', () {
        final List<Money> amounts = <Money>[
          Money.fromInt(3, Currency.eur),
          Money.fromInt(1, Currency.eur),
          Money.fromInt(2, Currency.eur),
        ]..sort();

        expect(amounts.map((Money m) => m.amount.toString()), <String>[
          '1',
          '2',
          '3',
        ]);
        expect(
          Money.fromInt(1, Currency.eur) < Money.fromInt(2, Currency.eur),
          isTrue,
        );
        expect(
          Money.fromInt(2, Currency.eur) >= Money.fromInt(2, Currency.eur),
          isTrue,
        );
      });
    });
  });

  group('Percentage', () {
    test('separates rate from percent', () {
      final Percentage yield = Percentage.fromRate(Decimal.parse('0.074'));

      expect(yield.rate, Decimal.parse('0.074'));
      expect(yield.percent, Decimal.parse('7.4'));
    });

    test('builds from a percent value', () {
      expect(
        Percentage.fromPercent(Decimal.parse('7.4')),
        Percentage.fromRate(Decimal.parse('0.074')),
      );
      expect(
        Percentage.parsePercent('7.4'),
        Percentage.fromRate(Decimal.parse('0.074')),
      );
    });

    test('formats with a period-appropriate sign', () {
      // Vision.md §12: "5Y dividend CAGR: +7.4% p.a."
      expect(Percentage.parsePercent('7.4').format(withSign: true), '+7.4%');
      expect(Percentage.parsePercent('7.4').format(), '7.4%');
      expect(
        Percentage.parsePercent('-3.25').format(decimals: 2, withSign: true),
        '-3.25%',
      );
      expect(Percentage.zero.format(withSign: true), '0.0%');
    });

    test('reports its sign', () {
      expect(Percentage.parsePercent('1').isPositive, isTrue);
      expect(Percentage.parsePercent('-1').isNegative, isTrue);
      expect(Percentage.zero.isZero, isTrue);
    });

    test('orders by rate', () {
      final List<Percentage> rates = <Percentage>[
        Percentage.parsePercent('8'),
        Percentage.parsePercent('-2'),
        Percentage.parsePercent('3'),
      ]..sort();

      expect(rates.map((Percentage p) => p.format()), <String>[
        '-2.0%',
        '3.0%',
        '8.0%',
      ]);
    });
  });
}
