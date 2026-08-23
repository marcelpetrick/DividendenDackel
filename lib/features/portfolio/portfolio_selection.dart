import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for the non-sensitive active portfolio selection.
abstract interface class PortfolioSelectionStore {
  /// Loads a portfolio id, or `null` for the consolidated view.
  Future<String?> load();

  /// Persists [portfolioId], where `null` means consolidated.
  Future<void> save(String? portfolioId);
}

/// SharedPreferences implementation used on Android and Linux.
final class PlatformPortfolioSelectionStore implements PortfolioSelectionStore {
  /// Creates the platform store.
  PlatformPortfolioSelectionStore({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  static const String _key = 'portfolio.active.v1';
  static const String _consolidated = '__consolidated__';
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<String?> load() async {
    final String stored =
        (await _preferences()).getString(_key) ?? InvestmentPortfolio.defaultId;
    return stored == _consolidated ? null : stored;
  }

  @override
  Future<void> save(String? portfolioId) async {
    final bool saved = await (await _preferences()).setString(
      _key,
      portfolioId ?? _consolidated,
    );
    if (!saved) {
      throw StateError('The platform preference store rejected the write.');
    }
  }
}

/// Immediately usable portfolio scope plus persistence status.
final class PortfolioSelectionState {
  /// Creates selection state.
  const PortfolioSelectionState({
    this.portfolioId = InvestmentPortfolio.defaultId,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  /// Selected portfolio, or `null` for a consolidated read-only scope.
  final String? portfolioId;

  /// Whether the saved selection is being loaded.
  final bool isLoading;

  /// Whether a new selection is being persisted.
  final bool isSaving;

  /// Recoverable persistence warning.
  final String? errorMessage;
}

/// Loads, applies immediately and persists the selected portfolio scope.
final class PortfolioSelectionController
    extends Notifier<PortfolioSelectionState> {
  bool _disposed = false;
  int _revision = 0;

  @override
  PortfolioSelectionState build() {
    ref.onDispose(() => _disposed = true);
    unawaited(_load(_revision));
    return const PortfolioSelectionState(isLoading: true);
  }

  Future<void> _load(int revision) async {
    try {
      final String? portfolioId = await ref
          .read(portfolioSelectionStoreProvider)
          .load();
      if (!_disposed && revision == _revision) {
        state = PortfolioSelectionState(portfolioId: portfolioId);
      }
    } on Object {
      if (!_disposed && revision == _revision) {
        state = const PortfolioSelectionState(
          errorMessage: 'Could not load the saved portfolio selection.',
        );
      }
    }
  }

  /// Selects one portfolio, or the consolidated read-only view with `null`.
  Future<void> select(String? portfolioId) async {
    _revision++;
    state = PortfolioSelectionState(portfolioId: portfolioId, isSaving: true);
    try {
      await ref.read(portfolioSelectionStoreProvider).save(portfolioId);
      if (!_disposed) state = PortfolioSelectionState(portfolioId: portfolioId);
    } on Object {
      if (!_disposed) {
        state = PortfolioSelectionState(
          portfolioId: portfolioId,
          errorMessage:
              'Portfolio changed, but could not be saved for next time.',
        );
      }
    }
  }
}

/// Platform store, overridden in tests.
final Provider<PortfolioSelectionStore> portfolioSelectionStoreProvider =
    Provider<PortfolioSelectionStore>(
      (Ref ref) => PlatformPortfolioSelectionStore(),
    );

/// Current portfolio scope shared by every screen and refresh query.
final NotifierProvider<PortfolioSelectionController, PortfolioSelectionState>
portfolioSelectionProvider =
    NotifierProvider<PortfolioSelectionController, PortfolioSelectionState>(
      PortfolioSelectionController.new,
    );

/// Selected persisted portfolio id, or `null` for consolidated reads.
final Provider<String?> selectedPortfolioIdProvider = Provider<String?>(
  (Ref ref) => ref.watch(portfolioSelectionProvider).portfolioId,
);

/// Builds read-only combined projections without crossing write boundaries.
abstract final class PortfolioScopeProjector {
  /// Aggregates the same instrument across portfolios with exact weighted cost.
  static List<Holding> consolidateHoldings(List<Holding> holdings) {
    final Map<String, List<Holding>> grouped = <String, List<Holding>>{};
    for (final Holding holding in holdings) {
      grouped.putIfAbsent(holding.instrumentId, () => <Holding>[]).add(holding);
    }
    return <Holding>[
      for (final MapEntry<String, List<Holding>> entry in grouped.entries)
        _holding(entry.key, entry.value),
    ];
  }

  static Holding _holding(String instrumentId, List<Holding> holdings) {
    final Decimal quantity = holdings.fold<Decimal>(
      Decimal.zero,
      (Decimal total, Holding holding) => total + holding.quantity,
    );
    final List<Money> knownPrices = <Money>[
      for (final Holding holding in holdings)
        if (holding.averagePurchasePrice case final Money price) price,
    ];
    Money? averagePrice;
    if (quantity > Decimal.zero &&
        knownPrices.length == holdings.length &&
        knownPrices.map((Money price) => price.currency).toSet().length == 1) {
      final Currency currency = knownPrices.first.currency;
      final Decimal cost = holdings.fold<Decimal>(
        Decimal.zero,
        (Decimal total, Holding holding) =>
            total + holding.averagePurchasePrice!.amount * holding.quantity,
      );
      averagePrice = Money(
        (cost / quantity).toDecimal(scaleOnInfinitePrecision: 12),
        currency,
      );
    }
    final List<DateTime> purchaseDates = <DateTime>[
      for (final Holding holding in holdings)
        if (holding.purchaseDate case final DateTime date) date,
    ]..sort();
    final Holding newest = holdings.reduce(
      (Holding left, Holding right) =>
          left.provenance.fetchedAt.isAfter(right.provenance.fetchedAt)
          ? left
          : right,
    );
    return Holding(
      portfolioId: InvestmentPortfolio.consolidatedId,
      instrumentId: instrumentId,
      quantity: quantity,
      averagePurchasePrice: averagePrice,
      purchaseDate: purchaseDates.isEmpty ? null : purchaseDates.first,
      provenance: newest.provenance,
    );
  }

  /// Deduplicates watchlist instruments while retaining newest local metadata.
  static List<WatchlistEntry> consolidateWatchlist(
    List<WatchlistEntry> entries,
  ) {
    final Map<String, WatchlistEntry> newest = <String, WatchlistEntry>{};
    for (final WatchlistEntry entry in entries) {
      final WatchlistEntry? existing = newest[entry.instrumentId];
      if (existing == null || entry.addedAt.isAfter(existing.addedAt)) {
        newest[entry.instrumentId] = WatchlistEntry(
          portfolioId: InvestmentPortfolio.consolidatedId,
          instrumentId: entry.instrumentId,
          addedAt: entry.addedAt,
          notes: entry.notes,
          provenance: entry.provenance,
        );
      }
    }
    return newest.values.toList(growable: false);
  }
}
