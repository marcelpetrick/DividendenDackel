import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime observedAt = DateTime.utc(2026, 8, 14);
  final Provenance provenance = Provenance(
    source: 'frankfurter',
    fetchedAt: DateTime.utc(2026, 8, 15),
  );

  FxRate rateOf(String value) => FxRate(
    base: Currency.eur,
    quote: Currency.usd,
    rate: Decimal.parse(value),
    observedAt: observedAt,
    provenance: provenance,
  );

  test('converts without binary floating-point or intermediate rounding', () {
    final Money converted = rateOf('1.1567')
        .convert(Money.parse('123.45', Currency.eur));

    expect(converted, Money.parse('142.794615', Currency.usd));
  });

  test('refuses to convert money in the wrong base currency', () {
    expect(
      () => rateOf('1.1567').convert(Money.parse('10', Currency.gbp)),
      throwsA(isA<CurrencyMismatchError>()),
    );
  });

  test('builds a useful reciprocal rate', () {
    final FxRate inverse = rateOf('2').inverse;

    expect(inverse.base, Currency.usd);
    expect(inverse.quote, Currency.eur);
    expect(inverse.rate, Decimal.parse('0.5'));
    expect(
      inverse.convert(Money.parse('10', Currency.usd)),
      Money.parse('5', Currency.eur),
    );
  });

  test('requires positive rates and exact identity rates', () {
    expect(() => rateOf('0'), throwsArgumentError);
    expect(
      () => FxRate(
        base: Currency.eur,
        quote: Currency.eur,
        rate: Decimal.parse('1.1'),
        observedAt: observedAt,
        provenance: provenance,
      ),
      throwsArgumentError,
    );
    expect(
      () => FxRate(
        base: Currency.eur,
        quote: Currency.usd,
        rate: Decimal.one,
        observedAt: DateTime.utc(2026, 8, 14, 12),
        provenance: provenance,
      ),
      throwsArgumentError,
    );
  });
}
