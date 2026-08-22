import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:dividendendackel/domain/value_objects/money.dart';

/// A position the user owns.
///
/// Vision.md §8.1 keeps this deliberately simple: an instrument and a quantity
/// are required, everything else is optional, and the MVP does not attempt
/// broker-grade transaction accounting.
final class Holding implements HasProvenance {
  /// Creates a holding.
  Holding({
    required this.instrumentId,
    required this.quantity,
    required this.provenance,
    this.averagePurchasePrice,
    this.purchaseDate,
    this.notes,
  }) {
    if (quantity < Decimal.zero) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'A holding quantity cannot be negative',
      );
    }
  }

  /// The instrument held, by its app-internal id.
  final String instrumentId;

  /// Number of shares held. May be fractional.
  final Decimal quantity;

  /// Average price paid per share, when the user supplied it.
  final Money? averagePurchasePrice;

  /// When the position was opened, when the user supplied it.
  final DateTime? purchaseDate;

  /// Free-form user note. Never logged (see `LogRedactor`).
  final String? notes;

  @override
  final Provenance provenance;

  /// Whether the position is empty, e.g. fully sold but kept for history.
  bool get isEmpty => quantity == Decimal.zero;

  /// What the user paid in total, when an average price is known.
  Money? get costBasis {
    final Money? price = averagePurchasePrice;
    return price == null ? null : price * quantity;
  }

  /// Position value at [pricePerShare].
  Money valueAt(Money pricePerShare) => pricePerShare * quantity;

  /// Absolute gain or loss at [pricePerShare], when a cost basis is known.
  ///
  /// Returns `null` rather than guessing when the user never entered a
  /// purchase price — Vision.md §79 forbids fabricating missing values.
  Money? unrealizedGainAt(Money pricePerShare) {
    final Money? basis = costBasis;
    return basis == null ? null : valueAt(pricePerShare) - basis;
  }

  /// Returns a copy with the given fields replaced.
  Holding copyWith({
    String? instrumentId,
    Decimal? quantity,
    Money? averagePurchasePrice,
    DateTime? purchaseDate,
    String? notes,
    Provenance? provenance,
  }) => Holding(
    instrumentId: instrumentId ?? this.instrumentId,
    quantity: quantity ?? this.quantity,
    averagePurchasePrice: averagePurchasePrice ?? this.averagePurchasePrice,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    notes: notes ?? this.notes,
    provenance: provenance ?? this.provenance,
  );

  /// Renders without the quantity, which is user-sensitive (Vision.md §80).
  @override
  String toString() => 'Holding($instrumentId)';

  @override
  bool operator ==(Object other) =>
      other is Holding &&
      other.instrumentId == instrumentId &&
      other.quantity == quantity &&
      other.averagePurchasePrice == averagePurchasePrice &&
      other.purchaseDate == purchaseDate &&
      other.notes == notes;

  @override
  int get hashCode => Object.hash(
    instrumentId,
    quantity,
    averagePurchasePrice,
    purchaseDate,
    notes,
  );
}

/// An instrument the user follows without owning it (Vision.md §8.1).
final class WatchlistEntry implements HasProvenance {
  /// Creates a watchlist entry.
  const WatchlistEntry({
    required this.instrumentId,
    required this.addedAt,
    required this.provenance,
    this.notes,
  });

  /// The instrument followed, by its app-internal id.
  final String instrumentId;

  /// When the user added it.
  final DateTime addedAt;

  /// Free-form user note. Never logged.
  final String? notes;

  @override
  final Provenance provenance;

  @override
  String toString() => 'WatchlistEntry($instrumentId)';

  @override
  bool operator ==(Object other) =>
      other is WatchlistEntry &&
      other.instrumentId == instrumentId &&
      other.addedAt == addedAt &&
      other.notes == notes;

  @override
  int get hashCode => Object.hash(instrumentId, addedAt, notes);
}
