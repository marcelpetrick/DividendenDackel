/// An ISO 4217 currency.
///
/// Instruments, dividends and quotes each carry their own currency; the app
/// must never add two amounts in different currencies together (Vision.md §45).
final class Currency implements Comparable<Currency> {
  /// Creates a currency. Prefer [Currency.parse] so known currencies get their
  /// correct number of decimal digits and symbol.
  const Currency({required this.code, this.decimalDigits = 2, this.symbol});

  /// ISO 4217 alphabetic code, e.g. `EUR`.
  final String code;

  /// Number of digits normally shown after the decimal separator.
  ///
  /// Most currencies use 2; the yen and the won use 0.
  final int decimalDigits;

  /// Display symbol, when one is commonly used.
  final String? symbol;

  /// Euro.
  static const Currency eur = Currency(code: 'EUR', symbol: '€');

  /// US dollar.
  static const Currency usd = Currency(code: 'USD', symbol: r'$');

  /// Pound sterling.
  static const Currency gbp = Currency(code: 'GBP', symbol: '£');

  /// Swiss franc.
  static const Currency chf = Currency(code: 'CHF');

  /// Japanese yen — zero decimal digits.
  static const Currency jpy = Currency(
    code: 'JPY',
    decimalDigits: 0,
    symbol: '¥',
  );

  /// Canadian dollar.
  static const Currency cad = Currency(code: 'CAD');

  /// Australian dollar.
  static const Currency aud = Currency(code: 'AUD');

  /// Swedish krona.
  static const Currency sek = Currency(code: 'SEK');

  /// Norwegian krone.
  static const Currency nok = Currency(code: 'NOK');

  /// Danish krone.
  static const Currency dkk = Currency(code: 'DKK');

  /// Hong Kong dollar.
  static const Currency hkd = Currency(code: 'HKD');

  /// Singapore dollar.
  static const Currency sgd = Currency(code: 'SGD');

  /// South Korean won — zero decimal digits.
  static const Currency krw = Currency(code: 'KRW', decimalDigits: 0);

  /// Currencies the app knows the conventions of, keyed by ISO code.
  static const Map<String, Currency> known = <String, Currency>{
    'EUR': eur,
    'USD': usd,
    'GBP': gbp,
    'CHF': chf,
    'JPY': jpy,
    'CAD': cad,
    'AUD': aud,
    'SEK': sek,
    'NOK': nok,
    'DKK': dkk,
    'HKD': hkd,
    'SGD': sgd,
    'KRW': krw,
  };

  /// Resolves [code] to a known currency, or builds a plain 2-digit one.
  ///
  /// Providers return codes the app has never seen; an unknown code is normal
  /// data, not an error, so it is accepted with conventional defaults rather
  /// than rejected.
  static Currency parse(String code) {
    final String normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw ArgumentError.value(
        code,
        'code',
        'Currency code must not be empty',
      );
    }
    return known[normalized] ?? Currency(code: normalized);
  }

  /// Whether this currency's conventions are known to the app.
  bool get isKnown => known.containsKey(code);

  @override
  int compareTo(Currency other) => code.compareTo(other.code);

  @override
  String toString() => code;

  @override
  bool operator ==(Object other) =>
      other is Currency &&
      other.code == code &&
      other.decimalDigits == decimalDigits;

  @override
  int get hashCode => Object.hash(code, decimalDigits);
}

/// Thrown when amounts in different currencies are combined.
///
/// This is a programming error rather than a recoverable data failure: the
/// vision requires that totals never silently mix currencies (Vision.md §45),
/// so the operation fails loudly instead of producing a meaningless number.
/// Code normalizing provider responses should convert this into a
/// `ParsingFailure` before it reaches the UI.
final class CurrencyMismatchError extends Error {
  /// Creates an error describing the attempted [operation].
  CurrencyMismatchError(this.operation, this.left, this.right);

  /// The operation that was attempted, e.g. `+`.
  final String operation;

  /// Currency of the left operand.
  final Currency left;

  /// Currency of the right operand.
  final Currency right;

  @override
  String toString() =>
      'CurrencyMismatchError: cannot apply "$operation" to $left and $right';
}
