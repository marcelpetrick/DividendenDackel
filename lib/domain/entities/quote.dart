import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:dividendendackel/domain/value_objects/money.dart';
import 'package:dividendendackel/domain/value_objects/percentage.dart';

/// A price observation for an instrument.
///
/// Quotes are the most perishable data the app holds, and the Today screen must
/// stay useful when they are unavailable (Vision.md §7), so everything derived
/// from a previous close is nullable rather than defaulted to zero.
final class Quote implements HasProvenance {
  /// Creates a quote.
  const Quote({
    required this.instrumentId,
    required this.price,
    required this.asOf,
    required this.provenance,
    this.previousClose,
  });

  /// The quoted instrument, by its app-internal id.
  final String instrumentId;

  /// Last traded or last known price.
  final Money price;

  /// Previous session's closing price, when the provider reports it.
  final Money? previousClose;

  /// When the price was observed.
  final DateTime asOf;

  @override
  final Provenance provenance;

  /// Absolute change since the previous close, or `null` when unknown.
  Money? get change {
    final Money? close = previousClose;
    return close == null ? null : price - close;
  }

  /// Relative change since the previous close, or `null` when unknown.
  ///
  /// Returns `null` for a zero previous close rather than dividing by zero.
  Percentage? get changePercent {
    final Money? close = previousClose;
    final Money? absolute = change;
    if (close == null || absolute == null || close.isZero) {
      return null;
    }
    return Percentage.fromRate(
      (absolute.amount / close.amount).toDecimal(scaleOnInfinitePrecision: 10),
    );
  }

  /// Whether the price moved by at least [threshold] in either direction.
  ///
  /// Used to flag unusual movements (Vision.md §19) without asserting a cause.
  bool movedAtLeast(Percentage threshold) {
    final Percentage? actual = changePercent;
    return actual != null && actual.rate.abs() >= threshold.rate.abs();
  }

  @override
  String toString() => 'Quote($instrumentId, $price at $asOf)';

  @override
  bool operator ==(Object other) =>
      other is Quote &&
      other.instrumentId == instrumentId &&
      other.price == price &&
      other.previousClose == previousClose &&
      other.asOf == asOf;

  @override
  int get hashCode => Object.hash(instrumentId, price, previousClose, asOf);
}
