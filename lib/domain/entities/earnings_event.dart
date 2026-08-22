import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:dividendendackel/domain/value_objects/money.dart';

/// When during the trading day a company reports (Vision.md §7).
enum EarningsTiming {
  /// Before the market opens.
  beforeMarketOpen,

  /// After the market closes.
  afterMarketClose,

  /// During trading hours.
  duringMarketHours,

  /// The provider did not say.
  unspecified,
}

/// How firm an earnings date is.
enum EarningsStatus {
  /// A provisional date, often inferred from prior years.
  estimated,

  /// The company confirmed the date.
  confirmed,

  /// The results are out.
  reported,
}

/// A scheduled or reported earnings release.
final class EarningsEvent implements HasProvenance {
  /// Creates an earnings event.
  const EarningsEvent({
    required this.instrumentId,
    required this.scheduledFor,
    required this.status,
    required this.provenance,
    this.timing = EarningsTiming.unspecified,
    this.fiscalPeriod,
    this.epsEstimate,
    this.epsActual,
    this.revenueEstimate,
    this.revenueActual,
  });

  /// The reporting instrument, by its app-internal id.
  final String instrumentId;

  /// The date of the release.
  final DateTime scheduledFor;

  /// How firm the date is.
  final EarningsStatus status;

  /// When during the day the release happens.
  final EarningsTiming timing;

  /// Fiscal period label, e.g. `Q2 2026`.
  final String? fiscalPeriod;

  /// Consensus earnings per share, when available.
  final Money? epsEstimate;

  /// Reported earnings per share, once published.
  final Money? epsActual;

  /// Consensus revenue, when available.
  final Money? revenueEstimate;

  /// Reported revenue, once published.
  final Money? revenueActual;

  @override
  final Provenance provenance;

  /// Whether results have been published.
  bool get isReported => status == EarningsStatus.reported;

  /// Difference between reported and expected EPS, when both are known.
  ///
  /// Deliberately not turned into a verdict: the vision forbids presenting
  /// conclusions as commands (Vision.md §2.2), so the UI describes the number
  /// rather than calling it good or bad.
  Money? get epsSurprise {
    final Money? actual = epsActual;
    final Money? estimate = epsEstimate;
    return (actual == null || estimate == null) ? null : actual - estimate;
  }

  @override
  String toString() =>
      'EarningsEvent($instrumentId, $scheduledFor, ${status.name})';

  @override
  bool operator ==(Object other) =>
      other is EarningsEvent &&
      other.instrumentId == instrumentId &&
      other.scheduledFor == scheduledFor &&
      other.status == status &&
      other.timing == timing &&
      other.fiscalPeriod == fiscalPeriod &&
      other.epsEstimate == epsEstimate &&
      other.epsActual == epsActual &&
      other.revenueEstimate == revenueEstimate &&
      other.revenueActual == revenueActual;

  @override
  int get hashCode => Object.hash(
    instrumentId,
    scheduledFor,
    status,
    timing,
    fiscalPeriod,
    epsEstimate,
    epsActual,
    revenueEstimate,
    revenueActual,
  );
}
