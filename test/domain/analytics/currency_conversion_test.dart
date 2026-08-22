import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Provenance provenance = Provenance(
    source: 'ecb',
    fetchedAt: DateTime.utc(2026, 8, 24),
  );
  FxRate rate(Currency quote, String value, DateTime day) => FxRate(
    base: Currency.eur,
    quote: quote,
    rate: Decimal.parse(value),
    observedAt: day,
    provenance: provenance,
  );

  test('uses the newest rate on or before the requested date', () {
    final FxRateBook book = FxRateBook(<FxRate>[
      rate(Currency.usd, '1.10', DateTime.utc(2026, 8, 20)),
      rate(Currency.usd, '1.20', DateTime.utc(2026, 8, 22)),
      rate(Currency.usd, '1.30', DateTime.utc(2026, 8, 25)),
    ]);

    final FxConversion conversion = book.convert(
      Money.parse('120', Currency.usd),
      Currency.eur,
      asOf: DateTime.utc(2026, 8, 23),
    )!;

    expect(conversion.converted, Money.parse('100', Currency.eur));
    expect(conversion.rates.single.observedAt, DateTime.utc(2026, 8, 22));
    expect(conversion.isStale, isFalse);
  });

  test('crosses between non-EUR currencies without intermediate rounding', () {
    final FxRateBook book = FxRateBook(<FxRate>[
      rate(Currency.usd, '1.20', DateTime.utc(2026, 8, 22)),
      rate(Currency.gbp, '0.80', DateTime.utc(2026, 8, 22)),
    ]);

    final FxConversion conversion = book.convert(
      Money.parse('120', Currency.usd),
      Currency.gbp,
      asOf: DateTime.utc(2026, 8, 23),
    )!;

    expect(conversion.converted, Money.parse('80', Currency.gbp));
    expect(conversion.rates, hasLength(2));
  });

  test('returns null instead of relabelling when a leg is missing', () {
    final FxRateBook book = FxRateBook(const <FxRate>[]);
    expect(
      book.convert(
        Money.parse('10', Currency.usd),
        Currency.eur,
        asOf: DateTime.utc(2026, 8, 23),
      ),
      isNull,
    );
  });

  test('marks old rates stale and calculates only supported exposure', () {
    final FxRateBook book = FxRateBook(<FxRate>[
      rate(Currency.usd, '2', DateTime.utc(2026, 8, 1)),
    ]);
    final PortfolioCurrencyExposure exposure =
        CurrencyExposureCalculator.calculate(
          nativeValues: <Currency, Money>{
            Currency.eur: Money.parse('50', Currency.eur),
            Currency.usd: Money.parse('100', Currency.usd),
            Currency.gbp: Money.parse('10', Currency.gbp),
          },
          displayCurrency: Currency.eur,
          rates: book,
          asOf: DateTime.utc(2026, 8, 23),
        );

    expect(exposure.total, Money.parse('100', Currency.eur));
    expect(exposure.slices, hasLength(2));
    expect(exposure.slices.first.share, Percentage.parsePercent('50'));
    expect(
      exposure.slices.first.conversion.isStale ||
          exposure.slices.last.conversion.isStale,
      isTrue,
    );
    expect(exposure.missingCurrencies, <Currency>{Currency.gbp});
    expect(exposure.isComplete, isFalse);
  });
}
