import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:dividendendackel/domain/value_objects/money.dart';

/// How certain a dividend payment is (Vision.md §9.4).
///
/// Estimated values must be visually distinguishable from confirmed ones, and
/// a forecast must never be displayed as if it were guaranteed — so the status
/// is part of the entity, not a UI afterthought.
enum DividendStatus {
  /// The company confirmed the payment, with dates.
  confirmed,

  /// The company announced it, but details may still change.
  announced,

  /// A provider expects it, e.g. from company guidance.
  expected,

  /// The app derived it from the historical payment pattern.
  historicallyEstimated,

  /// Nothing is known about its certainty.
  unknown;

  /// Whether this value is an estimate rather than a reported fact.
  bool get isEstimate =>
      this == DividendStatus.expected ||
      this == DividendStatus.historicallyEstimated ||
      this == DividendStatus.unknown;

  /// Whether the company itself has stated the payment.
  bool get isConfirmedByCompany =>
      this == DividendStatus.confirmed || this == DividendStatus.announced;
}

/// How often an instrument pays a dividend (Vision.md §11).
enum DividendFrequency {
  /// Twelve payments a year.
  monthly(12),

  /// Four payments a year.
  quarterly(4),

  /// Two payments a year.
  semiAnnual(2),

  /// One payment a year, the norm for most German companies.
  annual(1),

  /// Pays, but on no regular schedule.
  irregular(null),

  /// Not enough history to tell.
  unknown(null);

  const DividendFrequency(this.paymentsPerYear);

  /// Expected payments per year, or `null` when no rate can be assumed.
  final int? paymentsPerYear;

  /// Infers a frequency from a number of payments observed in one year.
  ///
  /// Anything that does not match a standard schedule is [irregular] rather
  /// than being forced into the nearest one.
  static DividendFrequency fromPaymentsPerYear(int payments) =>
      switch (payments) {
        12 => DividendFrequency.monthly,
        4 => DividendFrequency.quarterly,
        2 => DividendFrequency.semiAnnual,
        1 => DividendFrequency.annual,
        <= 0 => DividendFrequency.unknown,
        _ => DividendFrequency.irregular,
      };
}

/// A single dividend payment, past, announced or estimated.
///
/// The calendar shows these by either their ex-date or their payment date
/// (Vision.md §9.2), so both are modelled and both may legitimately be absent —
/// "Payment date not yet confirmed" is a real state the UI must render rather
/// than a gap to be filled in (Vision.md §79).
final class DividendEvent implements HasProvenance {
  /// Creates a dividend event.
  const DividendEvent({
    required this.instrumentId,
    required this.amountPerShare,
    required this.status,
    required this.provenance,
    this.exDate,
    this.paymentDate,
    this.declarationDate,
    this.recordDate,
    this.reportedPeriodStart,
    this.reportedPeriodEnd,
    this.frequency = DividendFrequency.unknown,
  });

  /// The paying instrument, by its app-internal id.
  final String instrumentId;

  /// Gross dividend per share, in the instrument's currency.
  final Money amountPerShare;

  /// How certain this payment is.
  final DividendStatus status;

  /// The entitlement date: buy before it to receive the payment.
  final DateTime? exDate;

  /// When the money is expected to arrive.
  final DateTime? paymentDate;

  /// When the company announced the dividend.
  final DateTime? declarationDate;

  /// The shareholder-of-record date.
  final DateTime? recordDate;

  /// Start of the provider's reporting period for this dividend fact.
  ///
  /// This is deliberately separate from the event dates. SEC company facts,
  /// for example, report a period but do not report the ex- or payment date.
  final DateTime? reportedPeriodStart;

  /// End of the provider's reporting period for this dividend fact.
  final DateTime? reportedPeriodEnd;

  /// The payment schedule this event belongs to.
  final DividendFrequency frequency;

  @override
  final Provenance provenance;

  /// Whether this payment is estimated rather than reported.
  bool get isEstimate => status.isEstimate;

  /// Whether the payment date is still open (Vision.md §79).
  bool get hasUnconfirmedPaymentDate => paymentDate == null;

  /// The date the calendar should sort this event by, in the requested mode.
  ///
  /// Returns `null` when that date is not known, so the caller decides how to
  /// present an event it cannot place.
  DateTime? dateFor(DividendDateMode mode) => switch (mode) {
    DividendDateMode.exDate => exDate,
    DividendDateMode.paymentDate => paymentDate,
  };

  /// Gross payment for a holding of [quantity] shares.
  ///
  /// Vision.md §9.3: "Expected payment for your holding: €276.00". This is the
  /// gross figure — the MVP is not a tax application (Vision.md §50).
  Money grossPaymentFor(Decimal quantity) => amountPerShare * quantity;

  /// Returns a copy with the given fields replaced.
  DividendEvent copyWith({
    String? instrumentId,
    Money? amountPerShare,
    DividendStatus? status,
    DateTime? exDate,
    DateTime? paymentDate,
    DateTime? declarationDate,
    DateTime? recordDate,
    DateTime? reportedPeriodStart,
    DateTime? reportedPeriodEnd,
    DividendFrequency? frequency,
    Provenance? provenance,
  }) => DividendEvent(
    instrumentId: instrumentId ?? this.instrumentId,
    amountPerShare: amountPerShare ?? this.amountPerShare,
    status: status ?? this.status,
    exDate: exDate ?? this.exDate,
    paymentDate: paymentDate ?? this.paymentDate,
    declarationDate: declarationDate ?? this.declarationDate,
    recordDate: recordDate ?? this.recordDate,
    reportedPeriodStart: reportedPeriodStart ?? this.reportedPeriodStart,
    reportedPeriodEnd: reportedPeriodEnd ?? this.reportedPeriodEnd,
    frequency: frequency ?? this.frequency,
    provenance: provenance ?? this.provenance,
  );

  @override
  String toString() =>
      'DividendEvent($instrumentId, $amountPerShare, ${status.name})';

  @override
  bool operator ==(Object other) =>
      other is DividendEvent &&
      other.instrumentId == instrumentId &&
      other.amountPerShare == amountPerShare &&
      other.status == status &&
      other.exDate == exDate &&
      other.paymentDate == paymentDate &&
      other.declarationDate == declarationDate &&
      other.recordDate == recordDate &&
      other.reportedPeriodStart == reportedPeriodStart &&
      other.reportedPeriodEnd == reportedPeriodEnd &&
      other.frequency == frequency;

  @override
  int get hashCode => Object.hash(
    instrumentId,
    amountPerShare,
    status,
    exDate,
    paymentDate,
    declarationDate,
    recordDate,
    reportedPeriodStart,
    reportedPeriodEnd,
    frequency,
  );
}

/// Which date the dividend calendar is organised by (Vision.md §9.2).
enum DividendDateMode {
  /// The entitlement date.
  exDate,

  /// The expected or confirmed payout date.
  paymentDate,
}
