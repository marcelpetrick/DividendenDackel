import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:dividendendackel/domain/value_objects/money.dart';

/// A user-owned, locally stored portfolio.
final class InvestmentPortfolio {
  /// Stable identifier used when upgrading the original single portfolio.
  static const String defaultId = 'default';

  /// Creates a portfolio.
  InvestmentPortfolio({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.isDemo = false,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'A portfolio id cannot be empty');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'A portfolio name cannot be empty',
      );
    }
  }

  /// Stable local identifier.
  final String id;

  /// User-visible name.
  final String name;

  /// When the portfolio was created.
  final DateTime createdAt;

  /// When its metadata last changed.
  final DateTime updatedAt;

  /// Whether this portfolio was explicitly created as an example.
  final bool isDemo;

  /// Returns a copy with selected values changed.
  InvestmentPortfolio copyWith({String? name, DateTime? updatedAt}) =>
      InvestmentPortfolio(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDemo: isDemo,
      );

  @override
  bool operator ==(Object other) =>
      other is InvestmentPortfolio &&
      other.id == id &&
      other.name == name &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.isDemo == isDemo;

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt, isDemo);

  @override
  String toString() => 'InvestmentPortfolio($id, $name)';
}

/// Immutable activity kinds retained in the local portfolio ledger.
enum PortfolioActivityType {
  openingBalance,
  purchase,
  sale,
  deposit,
  withdrawal,
  dividend,
  tax,
  fee,
  holdingAdjustment,
  reversal,
}

/// One immutable portfolio activity.
///
/// Corrections append a replacement activity and a
/// [PortfolioActivityType.reversal] referring to the superseded row. Imported
/// rows retain an external identity for duplicate detection without exposing
/// portfolio contents to logs.
final class PortfolioActivity implements HasProvenance {
  /// Creates and validates an activity.
  PortfolioActivity({
    required this.portfolioId,
    required this.type,
    required this.occurredAt,
    required this.provenance,
    this.id,
    this.instrumentId,
    this.quantity,
    this.unitPrice,
    this.cashAmount,
    this.externalId,
    this.importBatchId,
    this.reversesActivityId,
    this.notes,
  }) {
    if (portfolioId.trim().isEmpty) {
      throw ArgumentError.value(portfolioId, 'portfolioId', 'cannot be empty');
    }
    if (quantity == Decimal.zero) {
      throw ArgumentError.value(quantity, 'quantity', 'cannot be zero');
    }
    if (unitPrice?.isNegative ?? false) {
      throw ArgumentError.value(unitPrice, 'unitPrice', 'cannot be negative');
    }
    if (cashAmount?.isNegative ?? false) {
      throw ArgumentError.value(cashAmount, 'cashAmount', 'cannot be negative');
    }

    switch (type) {
      case PortfolioActivityType.openingBalance:
      case PortfolioActivityType.purchase:
      case PortfolioActivityType.sale:
        if (instrumentId == null ||
            quantity == null ||
            quantity! <= Decimal.zero) {
          throw ArgumentError(
            '${type.name} requires an instrument and positive quantity',
          );
        }
      case PortfolioActivityType.holdingAdjustment:
        if (instrumentId == null || quantity == null) {
          throw ArgumentError(
            'holdingAdjustment requires an instrument and quantity',
          );
        }
      case PortfolioActivityType.deposit:
      case PortfolioActivityType.withdrawal:
      case PortfolioActivityType.dividend:
      case PortfolioActivityType.tax:
      case PortfolioActivityType.fee:
        if (cashAmount == null || cashAmount!.isZero) {
          throw ArgumentError('${type.name} requires a positive cash amount');
        }
      case PortfolioActivityType.reversal:
        if (reversesActivityId == null) {
          throw ArgumentError('reversal requires a target activity');
        }
    }
  }

  /// Local database identity. `null` until persisted.
  final int? id;

  /// Owning portfolio.
  final String portfolioId;

  /// Economic meaning of this row.
  final PortfolioActivityType type;

  /// Effective time of the activity.
  final DateTime occurredAt;

  /// Related instrument for security and dividend activities.
  final String? instrumentId;

  /// Share quantity. Adjustments may be negative; trades are positive.
  final Decimal? quantity;

  /// Price per share when supplied.
  final Money? unitPrice;

  /// Absolute cash amount. The activity type defines inflow or outflow.
  final Money? cashAmount;

  /// Stable source identity, such as a broker transaction id.
  final String? externalId;

  /// Import batch used for atomic undo.
  final String? importBatchId;

  /// Original activity neutralized by this reversal.
  final int? reversesActivityId;

  /// User note. Never included in logs.
  final String? notes;

  @override
  final Provenance provenance;

  /// Signed impact on share quantity, if this is a security activity.
  Decimal? get shareDelta => switch (type) {
    PortfolioActivityType.openingBalance ||
    PortfolioActivityType.purchase ||
    PortfolioActivityType.holdingAdjustment => quantity,
    PortfolioActivityType.sale => quantity == null ? null : -quantity!,
    _ => null,
  };

  /// Returns a persisted copy.
  PortfolioActivity withId(int value) => PortfolioActivity(
    id: value,
    portfolioId: portfolioId,
    type: type,
    occurredAt: occurredAt,
    instrumentId: instrumentId,
    quantity: quantity,
    unitPrice: unitPrice,
    cashAmount: cashAmount,
    externalId: externalId,
    importBatchId: importBatchId,
    reversesActivityId: reversesActivityId,
    notes: notes,
    provenance: provenance,
  );

  @override
  String toString() => 'PortfolioActivity(${id ?? 'new'}, ${type.name})';
}

/// One persisted local import batch, derived from its immutable activities.
final class PortfolioImportBatch {
  /// Creates a batch summary.
  const PortfolioImportBatch({
    required this.id,
    required this.portfolioId,
    required this.source,
    required this.importedAt,
    required this.activityCount,
    required this.isUndone,
  });

  /// Stable batch identity used for precise undo.
  final String id;

  /// Portfolio that received the rows.
  final String portfolioId;

  /// Import adapter identifier, never a source filename.
  final String source;

  /// When the batch was applied.
  final DateTime importedAt;

  /// Number of original activities in the batch.
  final int activityCount;

  /// Whether every original activity has an appended reversal.
  final bool isUndone;
}
