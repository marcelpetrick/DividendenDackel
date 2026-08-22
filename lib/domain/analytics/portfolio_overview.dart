import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Next known or estimated payment for one holding.
final class PositionDividend {
  /// Creates a position dividend.
  const PositionDividend({required this.event, required this.grossAmount});

  /// Per-share event.
  final DividendEvent event;

  /// Gross amount for the held quantity.
  final Money grossAmount;
}

/// Calculated overview values for one holding.
final class PortfolioPositionSummary {
  /// Creates a position summary.
  const PortfolioPositionSummary({
    required this.holding,
    required this.instrument,
    required this.quote,
    required this.value,
    required this.dayChange,
    required this.dayChangePercent,
    required this.allocation,
    required this.forecastAnnualDividend,
    required this.forwardYield,
    required this.nextDividend,
  });

  /// User-owned position.
  final Holding holding;

  /// Instrument metadata, when locally available.
  final Instrument? instrument;

  /// Latest cached quote, when available.
  final Quote? quote;

  /// Current position value.
  final Money? value;

  /// Absolute change since previous close.
  final Money? dayChange;

  /// Quote day change percentage.
  final Percentage? dayChangePercent;

  /// Weight among priced holdings in the same currency.
  final Percentage? allocation;

  /// Gross dividends scheduled over the next 365 days.
  final Money? forecastAnnualDividend;

  /// Gross forward dividend income divided by current position value.
  final Percentage? forwardYield;

  /// Earliest future dividend inside the forecast window.
  final PositionDividend? nextDividend;
}

/// Portfolio totals for one currency; currencies are never mixed silently.
final class PortfolioCurrencySummary {
  /// Creates a currency summary.
  const PortfolioCurrencySummary({
    required this.currency,
    required this.totalValue,
    required this.dayChange,
    required this.dayChangePercent,
    required this.forecastAnnualDividend,
    required this.forwardYield,
    required this.positionCount,
    required this.pricedPositionCount,
  });

  /// Currency represented by every amount.
  final Currency currency;

  /// Value of holdings with a cached quote.
  final Money totalValue;

  /// Complete portfolio day change, or `null` if any component is missing.
  final Money? dayChange;

  /// Complete day change percentage, or `null` if any component is missing.
  final Percentage? dayChangePercent;

  /// Gross scheduled dividends over the next 365 days.
  final Money forecastAnnualDividend;

  /// Gross forward yield, available only when every position is priced.
  final Percentage? forwardYield;

  /// Holdings denominated in this currency.
  final int positionCount;

  /// Holdings included in [totalValue].
  final int pricedPositionCount;

  /// Whether totals cover every position in this currency.
  bool get isComplete => positionCount == pricedPositionCount;
}

/// Multi-currency-safe portfolio overview.
final class PortfolioOverview {
  /// Creates an overview.
  const PortfolioOverview({required this.positions, required this.byCurrency});

  /// Position details in holding order.
  final List<PortfolioPositionSummary> positions;

  /// Totals kept separate by currency.
  final Map<Currency, PortfolioCurrencySummary> byCurrency;
}

/// Computes portfolio value, change, allocation, yield and next dividends.
final class PortfolioOverviewCalculator {
  /// Creates a stateless calculator.
  const PortfolioOverviewCalculator();

  /// Calculates an overview as of [asOf] using a 365-day income window.
  PortfolioOverview calculate({
    required List<Holding> holdings,
    required Map<String, Instrument> instruments,
    required Map<String, Quote> quotes,
    required List<DividendEvent> dividends,
    required DateTime asOf,
  }) {
    final DateTime start = DateTime.utc(asOf.year, asOf.month, asOf.day);
    final DateTime end = start.add(const Duration(days: 365));
    final Map<String, List<DividendEvent>> futureByInstrument =
        <String, List<DividendEvent>>{};
    final Set<String> heldIds = holdings
        .map((Holding holding) => holding.instrumentId)
        .toSet();

    for (final DividendEvent event in dividends) {
      if (!heldIds.contains(event.instrumentId)) {
        continue;
      }
      final DateTime? rawDate = event.paymentDate ?? event.exDate;
      if (rawDate == null) {
        continue;
      }
      final DateTime date = DateTime.utc(
        rawDate.year,
        rawDate.month,
        rawDate.day,
      );
      if (!date.isBefore(start) && date.isBefore(end)) {
        futureByInstrument
            .putIfAbsent(event.instrumentId, () => <DividendEvent>[])
            .add(event);
      }
    }
    for (final List<DividendEvent> events in futureByInstrument.values) {
      events.sort(
        (DividendEvent left, DividendEvent right) =>
            (left.paymentDate ?? left.exDate!).compareTo(
              right.paymentDate ?? right.exDate!,
            ),
      );
    }

    final Map<Currency, Money> values = <Currency, Money>{};
    final Map<Currency, Money> previousValues = <Currency, Money>{};
    final Map<Currency, int> positionsPerCurrency = <Currency, int>{};
    final Map<Currency, int> pricedPerCurrency = <Currency, int>{};
    final Map<Currency, bool> completeDayChange = <Currency, bool>{};
    final Map<Currency, Money> incomes = <Currency, Money>{};
    final List<_PartialPosition> partials = <_PartialPosition>[];

    for (final Holding holding in holdings.where(
      (Holding item) => !item.isEmpty,
    )) {
      final Instrument? instrument = instruments[holding.instrumentId];
      final Quote? quote = quotes[holding.instrumentId];
      final List<DividendEvent> events =
          futureByInstrument[holding.instrumentId] ?? const <DividendEvent>[];
      final Currency? currency =
          instrument?.currency ??
          quote?.price.currency ??
          holding.averagePurchasePrice?.currency ??
          (events.isEmpty ? null : events.first.amountPerShare.currency);
      if (currency == null) {
        partials.add(
          _PartialPosition(
            holding: holding,
            instrument: instrument,
            quote: quote,
          ),
        );
        continue;
      }
      if (quote != null && quote.price.currency != currency) {
        throw CurrencyMismatchError(
          'portfolio quote',
          currency,
          quote.price.currency,
        );
      }
      positionsPerCurrency[currency] =
          (positionsPerCurrency[currency] ?? 0) + 1;
      completeDayChange.putIfAbsent(currency, () => true);

      Money? value;
      Money? dayChange;
      if (quote != null) {
        value = holding.valueAt(quote.price);
        values[currency] = (values[currency] ?? Money.zero(currency)) + value;
        pricedPerCurrency[currency] = (pricedPerCurrency[currency] ?? 0) + 1;
        final Money? quoteChange = quote.change;
        if (quoteChange == null) {
          completeDayChange[currency] = false;
        } else {
          dayChange = quoteChange * holding.quantity;
          final Money previousValue = quote.previousClose! * holding.quantity;
          previousValues[currency] =
              (previousValues[currency] ?? Money.zero(currency)) +
              previousValue;
        }
      } else {
        completeDayChange[currency] = false;
      }

      Money income = Money.zero(currency);
      for (final DividendEvent event in events) {
        if (event.amountPerShare.currency != currency) {
          throw CurrencyMismatchError(
            'portfolio dividend',
            currency,
            event.amountPerShare.currency,
          );
        }
        income += event.grossPaymentFor(holding.quantity);
      }
      incomes[currency] = (incomes[currency] ?? Money.zero(currency)) + income;
      partials.add(
        _PartialPosition(
          holding: holding,
          instrument: instrument,
          quote: quote,
          value: value,
          dayChange: dayChange,
          annualIncome: income,
          nextDividend: events.isEmpty
              ? null
              : PositionDividend(
                  event: events.first,
                  grossAmount: events.first.grossPaymentFor(holding.quantity),
                ),
          currency: currency,
        ),
      );
    }

    final Map<Currency, PortfolioCurrencySummary> summaries =
        <Currency, PortfolioCurrencySummary>{};
    for (final Currency currency in positionsPerCurrency.keys) {
      final Money totalValue = values[currency] ?? Money.zero(currency);
      final Money annualIncome = incomes[currency] ?? Money.zero(currency);
      final int positionCount = positionsPerCurrency[currency]!;
      final int pricedCount = pricedPerCurrency[currency] ?? 0;
      final bool complete = pricedCount == positionCount;
      final bool dayComplete = complete && completeDayChange[currency]!;
      final Money? dayChange = dayComplete
          ? totalValue - previousValues[currency]!
          : null;
      summaries[currency] = PortfolioCurrencySummary(
        currency: currency,
        totalValue: totalValue,
        dayChange: dayChange,
        dayChangePercent: dayChange == null || previousValues[currency]!.isZero
            ? null
            : Percentage.fromRate(
                (dayChange.amount / previousValues[currency]!.amount).toDecimal(
                  scaleOnInfinitePrecision: 10,
                ),
              ),
        forecastAnnualDividend: annualIncome,
        forwardYield: !complete || totalValue.isZero
            ? null
            : Percentage.fromRate(
                (annualIncome.amount / totalValue.amount).toDecimal(
                  scaleOnInfinitePrecision: 10,
                ),
              ),
        positionCount: positionCount,
        pricedPositionCount: pricedCount,
      );
    }

    final List<PortfolioPositionSummary> positions = partials
        .map((_PartialPosition partial) {
          final Money? value = partial.value;
          final Money? income = partial.annualIncome;
          final Money? currencyTotal = partial.currency == null
              ? null
              : values[partial.currency!];
          return PortfolioPositionSummary(
            holding: partial.holding,
            instrument: partial.instrument,
            quote: partial.quote,
            value: value,
            dayChange: partial.dayChange,
            dayChangePercent: partial.quote?.changePercent,
            allocation:
                value == null || currencyTotal == null || currencyTotal.isZero
                ? null
                : Percentage.fromRate(
                    (value.amount / currencyTotal.amount).toDecimal(
                      scaleOnInfinitePrecision: 10,
                    ),
                  ),
            forecastAnnualDividend: income,
            forwardYield: value == null || value.isZero || income == null
                ? null
                : Percentage.fromRate(
                    (income.amount / value.amount).toDecimal(
                      scaleOnInfinitePrecision: 10,
                    ),
                  ),
            nextDividend: partial.nextDividend,
          );
        })
        .toList(growable: false);

    return PortfolioOverview(
      positions: List<PortfolioPositionSummary>.unmodifiable(positions),
      byCurrency: Map<Currency, PortfolioCurrencySummary>.unmodifiable(
        summaries,
      ),
    );
  }
}

final class _PartialPosition {
  const _PartialPosition({
    required this.holding,
    required this.instrument,
    required this.quote,
    this.value,
    this.dayChange,
    this.annualIncome,
    this.nextDividend,
    this.currency,
  });

  final Holding holding;
  final Instrument? instrument;
  final Quote? quote;
  final Money? value;
  final Money? dayChange;
  final Money? annualIncome;
  final PositionDividend? nextDividend;
  final Currency? currency;
}
