import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:dividendendackel/domain/value_objects/value_objects.dart';

/// One exact daily reference exchange rate.
///
/// A rate answers “one [base] equals [rate] [quote]”. It is reference data,
/// not an executable market price.
final class FxRate implements HasProvenance {
  /// Creates a positive reference rate.
  FxRate({
    required this.base,
    required this.quote,
    required this.rate,
    required this.observedAt,
    required this.provenance,
  }) {
    if (rate <= Decimal.zero) {
      throw ArgumentError.value(rate, 'rate', 'must be positive');
    }
    if (base == quote && rate != Decimal.one) {
      throw ArgumentError.value(
        rate,
        'rate',
        'an identity currency pair must have rate 1',
      );
    }
    final DateTime utc = observedAt.toUtc();
    if (!observedAt.isUtc ||
        utc.hour != 0 ||
        utc.minute != 0 ||
        utc.second != 0 ||
        utc.millisecond != 0 ||
        utc.microsecond != 0) {
      throw ArgumentError.value(
        observedAt,
        'observedAt',
        'must be a UTC calendar date',
      );
    }
  }

  /// Currency being converted from.
  final Currency base;

  /// Currency being converted to.
  final Currency quote;

  /// Units of [quote] for one unit of [base].
  final Decimal rate;

  /// Reference-rate date in UTC.
  final DateTime observedAt;

  @override
  final Provenance provenance;

  /// Converts [money] exactly, without intermediate display rounding.
  Money convert(Money money) {
    if (money.currency != base) {
      throw CurrencyMismatchError('FX conversion', base, money.currency);
    }
    return Money(money.amount * rate, quote);
  }

  /// The reciprocal pair, retaining 16 decimal places for non-terminating
  /// rates. Conversion totals round only at the final display boundary.
  FxRate get inverse => FxRate(
    base: quote,
    quote: base,
    rate: (Decimal.one / rate).toDecimal(scaleOnInfinitePrecision: 16),
    observedAt: observedAt,
    provenance: provenance.copyWith(reportedCurrency: base),
  );

  /// Stable identity for persistence and cache keys.
  String get key =>
      '${base.code}:${quote.code}:${observedAt.toIso8601String()}';

  @override
  bool operator ==(Object other) =>
      other is FxRate &&
      other.base == base &&
      other.quote == quote &&
      other.rate == rate &&
      other.observedAt == observedAt;

  @override
  int get hashCode => Object.hash(base, quote, rate, observedAt);

  @override
  String toString() => 'FxRate(${base.code}/${quote.code} $rate, $observedAt)';
}
