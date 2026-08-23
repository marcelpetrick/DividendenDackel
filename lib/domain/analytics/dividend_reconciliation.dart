import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Actual broker-entered dividend cash compared with dated expected payments.
final class DividendReconciliationLine {
  /// Creates one currency-safe result line.
  const DividendReconciliationLine({
    required this.currency,
    required this.expectedGross,
    required this.actualGross,
  });

  /// Currency that is never mixed with another line.
  final Currency currency;

  /// Expected gross cash from known payment events and shares held that day.
  final Money expectedGross;

  /// Actual gross dividend cash entered or imported into the ledger.
  final Money actualGross;

  /// Actual less expected. Positive and negative values are both meaningful.
  Money get variance => actualGross - expectedGross;
}

/// Reconciles immutable activity history with provider dividend events.
abstract final class DividendReconciliationCalculator {
  /// Calculates the half-open interval from [start] to [end], keeping every
  /// currency separate.
  static List<DividendReconciliationLine> calculate({
    required List<PortfolioActivity> activities,
    required List<DividendEvent> expectedEvents,
    required DateTime start,
    required DateTime end,
  }) {
    bool contains(DateTime value) =>
        !value.isBefore(start) && value.isBefore(end);
    final Set<int> reversed = activities
        .where(
          (PortfolioActivity item) =>
              item.type == PortfolioActivityType.reversal,
        )
        .map((PortfolioActivity item) => item.reversesActivityId!)
        .toSet();
    final List<PortfolioActivity> effective = activities
        .where(
          (PortfolioActivity item) =>
              item.type != PortfolioActivityType.reversal &&
              !reversed.contains(item.id),
        )
        .toList(growable: false);
    final Map<Currency, Decimal> expected = <Currency, Decimal>{};
    final Map<Currency, Decimal> actual = <Currency, Decimal>{};

    for (final DividendEvent event in expectedEvents) {
      final DateTime? paidAt = event.paymentDate;
      if (paidAt == null || !contains(paidAt)) continue;
      Decimal quantity = Decimal.zero;
      for (final PortfolioActivity activity in effective) {
        if (activity.instrumentId == event.instrumentId &&
            !activity.occurredAt.isAfter(paidAt)) {
          quantity += activity.shareDelta ?? Decimal.zero;
        }
      }
      if (quantity <= Decimal.zero) continue;
      expected.update(
        event.amountPerShare.currency,
        (Decimal value) => value + event.amountPerShare.amount * quantity,
        ifAbsent: () => event.amountPerShare.amount * quantity,
      );
    }

    for (final PortfolioActivity activity in effective) {
      final Money? amount = activity.cashAmount;
      if (activity.type != PortfolioActivityType.dividend ||
          amount == null ||
          !contains(activity.occurredAt)) {
        continue;
      }
      actual.update(
        amount.currency,
        (Decimal value) => value + amount.amount,
        ifAbsent: () => amount.amount,
      );
    }

    final Set<Currency> currencies = <Currency>{
      ...expected.keys,
      ...actual.keys,
    };
    final List<DividendReconciliationLine> lines =
        <DividendReconciliationLine>[
          for (final Currency currency in currencies)
            DividendReconciliationLine(
              currency: currency,
              expectedGross: Money(
                expected[currency] ?? Decimal.zero,
                currency,
              ),
              actualGross: Money(actual[currency] ?? Decimal.zero, currency),
            ),
        ]..sort(
          (DividendReconciliationLine left, DividendReconciliationLine right) =>
              left.currency.code.compareTo(right.currency.code),
        );
    return List<DividendReconciliationLine>.unmodifiable(lines);
  }
}
