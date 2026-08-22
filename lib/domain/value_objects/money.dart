import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/value_objects/currency.dart';

/// An exact monetary amount in a single [Currency].
///
/// Money is stored as an arbitrary-precision decimal, never as a binary
/// floating-point number: dividends per share are routinely quoted with four
/// decimal places, and `0.1 + 0.2 != 0.3` in `double`. The vision forbids
/// fabricating values (Vision.md §79), and silent rounding drift is exactly
/// that.
///
/// Amounts in different currencies cannot be combined; doing so throws a
/// [CurrencyMismatchError] rather than producing a meaningless total.
final class Money implements Comparable<Money> {
  /// Creates an amount of [currency].
  const Money(this.amount, this.currency);

  /// Parses a decimal string such as `'13.80'`.
  ///
  /// Throws [FormatException] when [amount] is not a valid decimal.
  factory Money.parse(String amount, Currency currency) =>
      Money(Decimal.parse(amount), currency);

  /// A whole number of currency units.
  factory Money.fromInt(int amount, Currency currency) =>
      Money(Decimal.fromInt(amount), currency);

  /// Zero in [currency].
  factory Money.zero(Currency currency) => Money(Decimal.zero, currency);

  /// The exact amount.
  final Decimal amount;

  /// The currency the amount is denominated in.
  final Currency currency;

  /// Whether the amount is exactly zero.
  bool get isZero => amount == Decimal.zero;

  /// Whether the amount is greater than zero.
  bool get isPositive => amount > Decimal.zero;

  /// Whether the amount is less than zero.
  bool get isNegative => amount < Decimal.zero;

  /// The magnitude of the amount.
  Money get absolute => Money(amount.abs(), currency);

  /// Adds two amounts of the same currency.
  Money operator +(Money other) {
    _assertSameCurrency('+', other);
    return Money(amount + other.amount, currency);
  }

  /// Subtracts an amount of the same currency.
  Money operator -(Money other) {
    _assertSameCurrency('-', other);
    return Money(amount - other.amount, currency);
  }

  /// Negates the amount.
  Money operator -() => Money(-amount, currency);

  /// Scales the amount, e.g. dividend per share times a holding quantity.
  Money operator *(Decimal factor) => Money(amount * factor, currency);

  /// Divides the amount, rounding to [scale] digits when the result does not
  /// terminate.
  ///
  /// Division is explicit about its scale because an exact decimal cannot
  /// represent, say, a third — the caller must decide how much precision the
  /// result keeps.
  Money dividedBy(Decimal divisor, {int scale = 10}) {
    if (divisor == Decimal.zero) {
      throw ArgumentError.value(divisor, 'divisor', 'Cannot divide by zero');
    }
    return Money(
      (amount / divisor).toDecimal(scaleOnInfinitePrecision: scale),
      currency,
    );
  }

  /// Rounds to the number of decimal digits the currency conventionally uses.
  ///
  /// Use this for display and for final totals — not between intermediate
  /// steps, where rounding accumulates.
  Money roundedToCurrency() =>
      Money(amount.round(scale: currency.decimalDigits), currency);

  /// Sums [amounts], which must all share [currency].
  ///
  /// Requires the currency explicitly so an empty list still yields a
  /// well-defined zero.
  static Money sum(Iterable<Money> amounts, Currency currency) {
    Money total = Money.zero(currency);
    for (final Money amount in amounts) {
      total += amount;
    }
    return total;
  }

  /// Renders the amount with the currency's conventional number of decimals.
  ///
  /// This is a plain, locale-independent rendering for logs, tests and
  /// fallbacks; user-facing screens format according to the device locale.
  String format({bool withSymbol = false}) {
    final Decimal rounded = amount.round(scale: currency.decimalDigits);
    final String digits = rounded.abs().toStringAsFixed(currency.decimalDigits);
    final String sign = rounded.sign < 0 ? '-' : '';
    final String? symbol = currency.symbol;
    if (withSymbol && symbol != null) {
      return '$sign$symbol$digits';
    }
    return '$sign$digits ${currency.code}';
  }

  void _assertSameCurrency(String operation, Money other) {
    if (other.currency != currency) {
      throw CurrencyMismatchError(operation, currency, other.currency);
    }
  }

  /// Orders by amount. Both operands must share a currency.
  @override
  int compareTo(Money other) {
    _assertSameCurrency('compareTo', other);
    return amount.compareTo(other.amount);
  }

  /// Whether this amount is less than [other].
  bool operator <(Money other) => compareTo(other) < 0;

  /// Whether this amount is less than or equal to [other].
  bool operator <=(Money other) => compareTo(other) <= 0;

  /// Whether this amount is greater than [other].
  bool operator >(Money other) => compareTo(other) > 0;

  /// Whether this amount is greater than or equal to [other].
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  String toString() => format();

  /// Two amounts are equal when they are numerically equal in the same
  /// currency, so `2.50 EUR` equals `2.5 EUR`.
  @override
  bool operator ==(Object other) =>
      other is Money && other.currency == currency && other.amount == amount;

  @override
  int get hashCode => Object.hash(currency, amount);
}
