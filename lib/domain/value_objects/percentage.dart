import 'package:decimal/decimal.dart';

/// A rate expressed as a percentage.
///
/// Stored as a *rate* (`0.074`), rendered as a *percent* (`7.4%`). Keeping the
/// two apart in the type system prevents the classic yield bug where a value is
/// multiplied or divided by 100 one time too many or too few.
final class Percentage implements Comparable<Percentage> {
  /// Creates a percentage from a rate, e.g. `0.074` for 7.4%.
  const Percentage.fromRate(this.rate);

  /// Creates a percentage from a percent value, e.g. `7.4` for 7.4%.
  factory Percentage.fromPercent(Decimal percent) =>
      // Dividing by 100 always terminates, so no precision is lost here.
      Percentage.fromRate((percent / _hundred).toDecimal());

  /// Creates a percentage from a percent string, e.g. `'7.4'` for 7.4%.
  factory Percentage.parsePercent(String percent) =>
      Percentage.fromPercent(Decimal.parse(percent));

  /// A rate of zero.
  static final Percentage zero = Percentage.fromRate(Decimal.zero);

  static final Decimal _hundred = Decimal.fromInt(100);

  /// The rate, where `0.074` means 7.4%.
  final Decimal rate;

  /// The value as a percent, where 7.4% yields `7.4`.
  Decimal get percent => rate * _hundred;

  /// Whether the rate is above zero.
  bool get isPositive => rate > Decimal.zero;

  /// Whether the rate is below zero.
  bool get isNegative => rate < Decimal.zero;

  /// Whether the rate is exactly zero.
  bool get isZero => rate == Decimal.zero;

  /// Renders as a percent with [decimals] digits, e.g. `7.4%`.
  ///
  /// Set [withSign] to prefix a `+` on positive values, which is how changes
  /// and growth rates are shown.
  String format({int decimals = 1, bool withSign = false}) {
    final Decimal rounded = percent.round(scale: decimals);
    final String digits = rounded.abs().toStringAsFixed(decimals);
    final String sign = switch (rounded.sign) {
      < 0 => '-',
      > 0 when withSign => '+',
      _ => '',
    };
    return '$sign$digits%';
  }

  @override
  int compareTo(Percentage other) => rate.compareTo(other.rate);

  @override
  String toString() => format();

  @override
  bool operator ==(Object other) => other is Percentage && other.rate == rate;

  @override
  int get hashCode => rate.hashCode;
}
