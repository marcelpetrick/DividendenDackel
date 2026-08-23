import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/analytics/dividend_forecast.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Gross dividend income split by certainty for one currency and period.
final class DividendIncomeBreakdown {
  /// Creates a breakdown. Every amount must use [currency].
  const DividendIncomeBreakdown({
    required this.currency,
    required this.paid,
    required this.confirmedUpcoming,
    required this.estimated,
  });

  /// Currency shared by every component.
  final Currency currency;

  /// Confirmed payments whose payment date has passed in the current month.
  final Money paid;

  /// Company-confirmed or announced future payments.
  final Money confirmedUpcoming;

  /// Expected, historically estimated or unknown future payments.
  final Money estimated;

  /// Gross total. UI must still render the certainty split alongside it.
  Money get total => paid + confirmedUpcoming + estimated;
}

/// One month, quarter or year in the 24-month portfolio forecast.
final class DividendIncomePeriod {
  /// Creates an income period.
  const DividendIncomePeriod({
    required this.start,
    required this.end,
    required this.byCurrency,
    this.cumulativeByCurrency = const <Currency, Money>{},
    this.shareOfYearByCurrency = const <Currency, Percentage>{},
  });

  /// Inclusive period start.
  final DateTime start;

  /// Exclusive period end.
  final DateTime end;

  /// Certainty-separated gross payments, never mixed across currencies.
  final Map<Currency, DividendIncomeBreakdown> byCurrency;

  /// Running total within the calendar year, used by the cumulative curve.
  final Map<Currency, Money> cumulativeByCurrency;

  /// This period's share of its calendar-year income.
  final Map<Currency, Percentage> shareOfYearByCurrency;
}

/// Portfolio-level income projection and historical comparisons.
final class PortfolioDividendIncomeForecast {
  /// Creates a complete projection.
  const PortfolioDividendIncomeForecast({
    required this.asOf,
    required this.horizonEnd,
    required this.months,
    required this.quarters,
    required this.years,
    required this.trailingTwelveMonths,
    required this.previousTrailingTwelveMonths,
    required this.yearOverYearChange,
  });

  /// Forecast calculation day.
  final DateTime asOf;

  /// Exclusive 24-month boundary.
  final DateTime horizonEnd;

  /// Exactly 24 calendar-month buckets, starting with the current month.
  final List<DividendIncomePeriod> months;

  /// Calendar-quarter buckets intersecting [months].
  final List<DividendIncomePeriod> quarters;

  /// Calendar-year buckets intersecting [months].
  final List<DividendIncomePeriod> years;

  /// Confirmed gross payments in the twelve months before [asOf].
  final Map<Currency, Money> trailingTwelveMonths;

  /// Same measure for the preceding twelve months.
  final Map<Currency, Money> previousTrailingTwelveMonths;

  /// TTM change by currency; absent when the prior baseline is zero.
  final Map<Currency, Percentage> yearOverYearChange;
}

/// Aggregates per-instrument deterministic forecasts into portfolio income.
final class DividendIncomeForecastCalculator {
  /// Creates the stateless calculator.
  const DividendIncomeForecastCalculator();

  /// Builds the required 24-month, quarterly, annual and TTM views.
  ///
  /// Current holdings are applied to every event in this forward-looking view.
  /// Historical actual cash is reconciled separately from the activity ledger;
  /// it is never inferred from today's quantity.
  PortfolioDividendIncomeForecast calculate({
    required List<Holding> holdings,
    required List<DividendEvent> historicalEvents,
    required List<DividendForecast> forecasts,
    required DateTime asOf,
  }) {
    final DateTime day = DateTime(asOf.year, asOf.month, asOf.day);
    final DateTime horizonStart = DateTime(day.year, day.month);
    final DateTime horizonEnd = _addMonths(horizonStart, 24);
    final Map<String, Holding> held = <String, Holding>{
      for (final Holding holding in holdings.where((h) => !h.isEmpty))
        holding.instrumentId: holding,
    };

    final List<_Payment> timeline = <_Payment>[];
    for (final DividendEvent event in historicalEvents) {
      final DateTime? date = event.paymentDate;
      final Holding? holding = held[event.instrumentId];
      if (date != null &&
          holding != null &&
          !date.isBefore(horizonStart) &&
          date.isBefore(day) &&
          event.status.isConfirmedByCompany) {
        timeline.add(
          _Payment(date, event.grossPaymentFor(holding.quantity), _Kind.paid),
        );
      }
    }
    for (final DividendForecast forecast in forecasts) {
      final Holding? holding = held[forecast.instrumentId];
      if (holding == null) continue;
      for (final DividendEvent event in forecast.events) {
        final DateTime? date = event.paymentDate;
        if (date == null ||
            date.isBefore(day) ||
            date.isBefore(horizonStart) ||
            !date.isBefore(horizonEnd)) {
          continue;
        }
        timeline.add(
          _Payment(
            date,
            event.grossPaymentFor(holding.quantity),
            event.status.isConfirmedByCompany
                ? _Kind.confirmedUpcoming
                : _Kind.estimated,
          ),
        );
      }
    }

    final List<DividendIncomePeriod> rawMonths = <DividendIncomePeriod>[
      for (int index = 0; index < 24; index++)
        _period(
          _addMonths(horizonStart, index),
          _addMonths(horizonStart, index + 1),
          timeline,
        ),
    ];
    final List<DividendIncomePeriod> years = _calendarPeriods(
      rawMonths,
      quarter: false,
    );
    final Map<int, Map<Currency, Money>> annualTotals =
        <int, Map<Currency, Money>>{
          for (final DividendIncomePeriod year in years)
            year.start.year: <Currency, Money>{
              for (final MapEntry<Currency, DividendIncomeBreakdown> entry
                  in year.byCurrency.entries)
                entry.key: entry.value.total,
            },
        };
    final Map<int, Map<Currency, Money>> running =
        <int, Map<Currency, Money>>{};
    final List<DividendIncomePeriod> months = <DividendIncomePeriod>[];
    for (final DividendIncomePeriod month in rawMonths) {
      final Map<Currency, Money> cumulative = running.putIfAbsent(
        month.start.year,
        () => <Currency, Money>{},
      );
      final Map<Currency, Percentage> shares = <Currency, Percentage>{};
      for (final MapEntry<Currency, DividendIncomeBreakdown> entry
          in month.byCurrency.entries) {
        cumulative[entry.key] =
            (cumulative[entry.key] ?? Money.zero(entry.key)) +
            entry.value.total;
        final Money? annual = annualTotals[month.start.year]?[entry.key];
        if (annual != null && annual.isPositive) {
          shares[entry.key] = Percentage.fromRate(
            (entry.value.total.amount / annual.amount).toDecimal(
              scaleOnInfinitePrecision: 10,
            ),
          );
        }
      }
      months.add(
        DividendIncomePeriod(
          start: month.start,
          end: month.end,
          byCurrency: month.byCurrency,
          cumulativeByCurrency: Map<Currency, Money>.unmodifiable(cumulative),
          shareOfYearByCurrency: Map<Currency, Percentage>.unmodifiable(shares),
        ),
      );
    }

    final DateTime ttmStart = _addMonths(day, -12);
    final DateTime previousStart = _addMonths(day, -24);
    final Map<Currency, Money> ttm = _historicalTotal(
      historicalEvents,
      held,
      ttmStart,
      day,
    );
    final Map<Currency, Money> previous = _historicalTotal(
      historicalEvents,
      held,
      previousStart,
      ttmStart,
    );
    final Map<Currency, Percentage> change = <Currency, Percentage>{};
    for (final MapEntry<Currency, Money> entry in ttm.entries) {
      final Money? baseline = previous[entry.key];
      if (baseline != null && baseline.isPositive) {
        change[entry.key] = Percentage.fromRate(
          ((entry.value.amount - baseline.amount) / baseline.amount).toDecimal(
            scaleOnInfinitePrecision: 10,
          ),
        );
      }
    }

    return PortfolioDividendIncomeForecast(
      asOf: day,
      horizonEnd: horizonEnd,
      months: List<DividendIncomePeriod>.unmodifiable(months),
      quarters: List<DividendIncomePeriod>.unmodifiable(
        _calendarPeriods(rawMonths, quarter: true),
      ),
      years: List<DividendIncomePeriod>.unmodifiable(years),
      trailingTwelveMonths: Map<Currency, Money>.unmodifiable(ttm),
      previousTrailingTwelveMonths: Map<Currency, Money>.unmodifiable(previous),
      yearOverYearChange: Map<Currency, Percentage>.unmodifiable(change),
    );
  }

  static DividendIncomePeriod _period(
    DateTime start,
    DateTime end,
    Iterable<_Payment> payments,
  ) {
    final Map<Currency, _MutableBreakdown> totals =
        <Currency, _MutableBreakdown>{};
    for (final _Payment payment in payments) {
      if (!payment.date.isBefore(start) && payment.date.isBefore(end)) {
        totals
            .putIfAbsent(
              payment.amount.currency,
              () => _MutableBreakdown(payment.amount.currency),
            )
            .add(payment);
      }
    }
    return DividendIncomePeriod(
      start: start,
      end: end,
      byCurrency: <Currency, DividendIncomeBreakdown>{
        for (final MapEntry<Currency, _MutableBreakdown> entry
            in totals.entries)
          entry.key: entry.value.freeze(),
      },
    );
  }

  static List<DividendIncomePeriod> _calendarPeriods(
    List<DividendIncomePeriod> months, {
    required bool quarter,
  }) {
    final Map<(int, int), List<_Payment>> grouped =
        <(int, int), List<_Payment>>{};
    for (final DividendIncomePeriod month in months) {
      final int slot = quarter ? ((month.start.month - 1) ~/ 3) + 1 : 1;
      final List<_Payment> target = grouped.putIfAbsent((
        month.start.year,
        slot,
      ), () => <_Payment>[]);
      for (final DividendIncomeBreakdown value in month.byCurrency.values) {
        if (!value.paid.isZero) {
          target.add(_Payment(month.start, value.paid, _Kind.paid));
        }
        if (!value.confirmedUpcoming.isZero) {
          target.add(
            _Payment(
              month.start,
              value.confirmedUpcoming,
              _Kind.confirmedUpcoming,
            ),
          );
        }
        if (!value.estimated.isZero) {
          target.add(_Payment(month.start, value.estimated, _Kind.estimated));
        }
      }
    }
    return <DividendIncomePeriod>[
      for (final MapEntry<(int, int), List<_Payment>> entry in grouped.entries)
        _period(
          quarter
              ? DateTime(entry.key.$1, (entry.key.$2 - 1) * 3 + 1)
              : DateTime(entry.key.$1),
          quarter
              ? DateTime(entry.key.$1, entry.key.$2 * 3 + 1)
              : DateTime(entry.key.$1 + 1),
          entry.value,
        ),
    ];
  }

  static Map<Currency, Money> _historicalTotal(
    Iterable<DividendEvent> events,
    Map<String, Holding> holdings,
    DateTime start,
    DateTime end,
  ) {
    final Map<Currency, Money> totals = <Currency, Money>{};
    for (final DividendEvent event in events) {
      final DateTime? date = event.paymentDate;
      final Holding? holding = holdings[event.instrumentId];
      if (date != null &&
          holding != null &&
          event.status.isConfirmedByCompany &&
          !date.isBefore(start) &&
          date.isBefore(end)) {
        final Money payment = event.grossPaymentFor(holding.quantity);
        totals[payment.currency] =
            (totals[payment.currency] ?? Money.zero(payment.currency)) +
            payment;
      }
    }
    return totals;
  }

  static DateTime _addMonths(DateTime date, int months) =>
      DateTime(date.year, date.month + months, date.day);
}

enum _Kind { paid, confirmedUpcoming, estimated }

final class _Payment {
  const _Payment(this.date, this.amount, this.kind);
  final DateTime date;
  final Money amount;
  final _Kind kind;
}

final class _MutableBreakdown {
  _MutableBreakdown(this.currency);
  final Currency currency;
  Decimal paid = Decimal.zero;
  Decimal confirmed = Decimal.zero;
  Decimal estimated = Decimal.zero;

  void add(_Payment payment) {
    switch (payment.kind) {
      case _Kind.paid:
        paid += payment.amount.amount;
      case _Kind.confirmedUpcoming:
        confirmed += payment.amount.amount;
      case _Kind.estimated:
        estimated += payment.amount.amount;
    }
  }

  DividendIncomeBreakdown freeze() => DividendIncomeBreakdown(
    currency: currency,
    paid: Money(paid, currency),
    confirmedUpcoming: Money(confirmed, currency),
    estimated: Money(estimated, currency),
  );
}
