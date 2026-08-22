import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
  const PortfolioOverviewCalculator calculator = PortfolioOverviewCalculator();

  Instrument instrument(String id, Currency currency) => Instrument(
    internalId: id,
    symbol: id.toUpperCase(),
    name: 'Company $id',
    currency: currency,
  );

  Holding holding(String id, String quantity) => Holding(
    instrumentId: id,
    quantity: Decimal.parse(quantity),
    provenance: provenance,
  );

  Quote quote(String id, String price, String? previous, Currency currency) =>
      Quote(
        instrumentId: id,
        price: Money.parse(price, currency),
        previousClose: previous == null
            ? null
            : Money.parse(previous, currency),
        asOf: now,
        provenance: provenance,
      );

  DividendEvent dividend(
    String id,
    String amount,
    DateTime date,
    Currency currency,
  ) => DividendEvent(
    instrumentId: id,
    amountPerShare: Money.parse(amount, currency),
    status: DividendStatus.announced,
    paymentDate: date,
    provenance: provenance,
  );

  test('calculates values, changes, allocations, yield and next dividend', () {
    final PortfolioOverview result = calculator.calculate(
      holdings: <Holding>[holding('a', '10'), holding('b', '5')],
      instruments: <String, Instrument>{
        'a': instrument('a', Currency.eur),
        'b': instrument('b', Currency.eur),
      },
      quotes: <String, Quote>{
        'a': quote('a', '100', '90', Currency.eur),
        'b': quote('b', '200', '190', Currency.eur),
      },
      dividends: <DividendEvent>[
        dividend('a', '1', now.add(const Duration(days: 30)), Currency.eur),
        dividend('a', '1', now.add(const Duration(days: 200)), Currency.eur),
        dividend('b', '2', now.add(const Duration(days: 60)), Currency.eur),
      ],
      asOf: now,
    );

    final PortfolioCurrencySummary eur = result.byCurrency[Currency.eur]!;
    expect(eur.totalValue, Money.parse('2000', Currency.eur));
    expect(eur.dayChange, Money.parse('150', Currency.eur));
    expect(eur.dayChangePercent?.format(decimals: 2), '8.11%');
    expect(eur.forecastAnnualDividend, Money.parse('30', Currency.eur));
    expect(eur.forwardYield?.format(decimals: 2), '1.50%');
    expect(eur.isComplete, isTrue);

    final PortfolioPositionSummary first = result.positions.first;
    expect(first.value, Money.parse('1000', Currency.eur));
    expect(first.dayChange, Money.parse('100', Currency.eur));
    expect(first.allocation?.format(), '50.0%');
    expect(first.forecastAnnualDividend, Money.parse('20', Currency.eur));
    expect(first.forwardYield?.format(), '2.0%');
    expect(first.nextDividend?.grossAmount, Money.parse('10', Currency.eur));
  });

  test('keeps currency totals separate', () {
    final PortfolioOverview result = calculator.calculate(
      holdings: <Holding>[holding('eur', '1'), holding('usd', '1')],
      instruments: <String, Instrument>{
        'eur': instrument('eur', Currency.eur),
        'usd': instrument('usd', Currency.usd),
      },
      quotes: <String, Quote>{
        'eur': quote('eur', '100', '99', Currency.eur),
        'usd': quote('usd', '200', '198', Currency.usd),
      },
      dividends: const <DividendEvent>[],
      asOf: now,
    );

    expect(result.byCurrency.keys, <Currency>{Currency.eur, Currency.usd});
    expect(
      result.byCurrency[Currency.eur]!.totalValue.amount,
      Decimal.fromInt(100),
    );
    expect(
      result.byCurrency[Currency.usd]!.totalValue.amount,
      Decimal.fromInt(200),
    );
  });

  test(
    'marks totals incomplete instead of treating missing quotes as zero',
    () {
      final PortfolioOverview result = calculator.calculate(
        holdings: <Holding>[holding('a', '10'), holding('b', '5')],
        instruments: <String, Instrument>{
          'a': instrument('a', Currency.eur),
          'b': instrument('b', Currency.eur),
        },
        quotes: <String, Quote>{'a': quote('a', '100', '90', Currency.eur)},
        dividends: <DividendEvent>[
          dividend('b', '2', now.add(const Duration(days: 30)), Currency.eur),
        ],
        asOf: now,
      );

      final PortfolioCurrencySummary summary = result.byCurrency[Currency.eur]!;
      expect(summary.totalValue, Money.parse('1000', Currency.eur));
      expect(summary.positionCount, 2);
      expect(summary.pricedPositionCount, 1);
      expect(summary.isComplete, isFalse);
      expect(summary.dayChange, isNull);
      expect(summary.forwardYield, isNull);
      expect(result.positions.last.value, isNull);
    },
  );

  test(
    'uses a half-open 365-day payment window and ignores empty holdings',
    () {
      final PortfolioOverview result = calculator.calculate(
        holdings: <Holding>[holding('a', '1'), holding('empty', '0')],
        instruments: <String, Instrument>{
          'a': instrument('a', Currency.eur),
          'empty': instrument('empty', Currency.eur),
        },
        quotes: <String, Quote>{'a': quote('a', '100', '100', Currency.eur)},
        dividends: <DividendEvent>[
          dividend(
            'a',
            '1',
            now.subtract(const Duration(days: 1)),
            Currency.eur,
          ),
          dividend('a', '2', now, Currency.eur),
          dividend('a', '4', now.add(const Duration(days: 365)), Currency.eur),
        ],
        asOf: now,
      );

      expect(result.positions, hasLength(1));
      expect(
        result.positions.single.forecastAnnualDividend,
        Money.parse('2', Currency.eur),
      );
    },
  );

  test('withholds day change when a previous close is missing', () {
    final PortfolioOverview result = calculator.calculate(
      holdings: <Holding>[holding('a', '1')],
      instruments: <String, Instrument>{'a': instrument('a', Currency.eur)},
      quotes: <String, Quote>{'a': quote('a', '100', null, Currency.eur)},
      dividends: const <DividendEvent>[],
      asOf: now,
    );

    expect(result.byCurrency[Currency.eur]!.dayChange, isNull);
    expect(result.positions.single.dayChange, isNull);
  });

  test('rejects mismatched quote and dividend currencies', () {
    expect(
      () => calculator.calculate(
        holdings: <Holding>[holding('a', '1')],
        instruments: <String, Instrument>{'a': instrument('a', Currency.eur)},
        quotes: <String, Quote>{'a': quote('a', '100', '99', Currency.usd)},
        dividends: const <DividendEvent>[],
        asOf: now,
      ),
      throwsA(isA<CurrencyMismatchError>()),
    );
    expect(
      () => calculator.calculate(
        holdings: <Holding>[holding('a', '1')],
        instruments: <String, Instrument>{'a': instrument('a', Currency.eur)},
        quotes: <String, Quote>{},
        dividends: <DividendEvent>[dividend('a', '1', now, Currency.usd)],
        asOf: now,
      ),
      throwsA(isA<CurrencyMismatchError>()),
    );
  });
}
