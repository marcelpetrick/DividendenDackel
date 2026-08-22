import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// A converted amount together with every reference rate that produced it.
final class FxConversion {
  /// Creates a traceable conversion.
  const FxConversion({
    required this.original,
    required this.converted,
    required this.rates,
    required this.asOf,
    required this.isStale,
  });

  /// Native amount before conversion.
  final Money original;

  /// Amount in the requested display currency, without intermediate rounding.
  final Money converted;

  /// One direct rate, or two rates for a cross through EUR.
  final List<FxRate> rates;

  /// Valuation/payment date for which the conversion was requested.
  final DateTime asOf;

  /// Whether at least one selected rate exceeds the accepted age.
  final bool isStale;

  /// Oldest reference date used by the conversion.
  DateTime? get oldestRateDate => rates.isEmpty
      ? null
      : rates
            .map((FxRate rate) => rate.observedAt)
            .reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b);
}

/// Selects explicit daily rates and converts via the ECB's EUR reference base.
///
/// No amount is relabelled when a rate is missing. Rates after the requested
/// date are never used, which keeps historical dividend tax reproducible.
final class FxRateBook {
  /// Creates a book from cached daily reference rates.
  FxRateBook(
    Iterable<FxRate> rates, {
    this.referenceCurrency = Currency.eur,
    this.maximumAge = const Duration(days: 7),
  }) : _rates = List<FxRate>.unmodifiable(rates) {
    for (final FxRate rate in _rates) {
      if (rate.base != referenceCurrency) {
        throw ArgumentError(
          'FX book expects ${referenceCurrency.code}-based rates, got '
          '${rate.base.code}/${rate.quote.code}.',
        );
      }
    }
  }

  /// Common base used to derive cross rates.
  final Currency referenceCurrency;

  /// Maximum accepted reference-rate age before UI marks it stale.
  final Duration maximumAge;

  final List<FxRate> _rates;

  /// Converts [amount] using rates observed on or before [asOf].
  ///
  /// Returns `null` when any required leg is unavailable.
  FxConversion? convert(
    Money amount,
    Currency target, {
    required DateTime asOf,
  }) {
    final DateTime day = DateTime.utc(asOf.year, asOf.month, asOf.day);
    if (amount.currency == target) {
      return FxConversion(
        original: amount,
        converted: amount,
        rates: const <FxRate>[],
        asOf: day,
        isStale: false,
      );
    }

    final List<FxRate> selected = <FxRate>[];
    Money value = amount;
    if (value.currency != referenceCurrency) {
      final FxRate? source = latest(referenceCurrency, value.currency, day);
      if (source == null) return null;
      selected.add(source);
      value = Money(
        (value.amount / source.rate).toDecimal(scaleOnInfinitePrecision: 16),
        referenceCurrency,
      );
    }
    if (target != referenceCurrency) {
      final FxRate? destination = latest(referenceCurrency, target, day);
      if (destination == null) return null;
      selected.add(destination);
      value = destination.convert(value);
    }
    return FxConversion(
      original: amount,
      converted: value,
      rates: List<FxRate>.unmodifiable(selected),
      asOf: day,
      isStale: selected.any(
        (FxRate rate) => day.difference(rate.observedAt) > maximumAge,
      ),
    );
  }

  /// Newest matching rate on or before [asOf].
  FxRate? latest(Currency base, Currency quote, DateTime asOf) {
    final DateTime day = DateTime.utc(asOf.year, asOf.month, asOf.day);
    FxRate? selected;
    for (final FxRate rate in _rates) {
      if (rate.base != base ||
          rate.quote != quote ||
          rate.observedAt.isAfter(day)) {
        continue;
      }
      if (selected == null || rate.observedAt.isAfter(selected.observedAt)) {
        selected = rate;
      }
    }
    return selected;
  }
}

/// One native-currency slice expressed in the selected display currency.
final class CurrencyExposureSlice {
  /// Creates a slice.
  const CurrencyExposureSlice({
    required this.nativeCurrency,
    required this.convertedValue,
    required this.share,
    required this.conversion,
  });
  final Currency nativeCurrency;
  final Money convertedValue;
  final Percentage share;
  final FxConversion conversion;
}

/// Currency exposure with explicit omissions rather than a false total.
final class PortfolioCurrencyExposure {
  /// Creates an exposure result.
  const PortfolioCurrencyExposure({
    required this.displayCurrency,
    required this.total,
    required this.slices,
    required this.missingCurrencies,
  });
  final Currency displayCurrency;
  final Money total;
  final List<CurrencyExposureSlice> slices;
  final Set<Currency> missingCurrencies;

  /// Whether every native total could be converted.
  bool get isComplete => missingCurrencies.isEmpty;
}

/// Converts native portfolio totals and calculates their currency exposure.
abstract final class CurrencyExposureCalculator {
  /// Calculates exposure without ever mixing unconverted currencies.
  static PortfolioCurrencyExposure calculate({
    required Map<Currency, Money> nativeValues,
    required Currency displayCurrency,
    required FxRateBook rates,
    required DateTime asOf,
  }) {
    final Map<Currency, FxConversion> converted = <Currency, FxConversion>{};
    final Set<Currency> missing = <Currency>{};
    Money total = Money.zero(displayCurrency);
    for (final MapEntry<Currency, Money> entry in nativeValues.entries) {
      if (entry.value.isZero) continue;
      final FxConversion? conversion = rates.convert(
        entry.value,
        displayCurrency,
        asOf: asOf,
      );
      if (conversion == null) {
        missing.add(entry.key);
        continue;
      }
      converted[entry.key] = conversion;
      total += conversion.converted;
    }
    final List<CurrencyExposureSlice> slices =
        <CurrencyExposureSlice>[
          for (final MapEntry<Currency, FxConversion> entry
              in converted.entries)
            CurrencyExposureSlice(
              nativeCurrency: entry.key,
              convertedValue: entry.value.converted,
              share: total.isZero
                  ? Percentage.zero
                  : Percentage.fromRate(
                      (entry.value.converted.amount / total.amount).toDecimal(
                        scaleOnInfinitePrecision: 10,
                      ),
                    ),
              conversion: entry.value,
            ),
        ]..sort(
          (CurrencyExposureSlice a, CurrencyExposureSlice b) =>
              b.convertedValue.compareTo(a.convertedValue),
        );
    return PortfolioCurrencyExposure(
      displayCurrency: displayCurrency,
      total: total,
      slices: List<CurrencyExposureSlice>.unmodifiable(slices),
      missingCurrencies: Set<Currency>.unmodifiable(missing),
    );
  }
}
