import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/utils/clock.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';

/// Search results plus a recoverable warning from one search tier.
final class InstrumentSearchOutcome {
  /// Creates an outcome.
  const InstrumentSearchOutcome({required this.instruments, this.warning});

  /// Deduplicated local and live matches.
  final List<Instrument> instruments;

  /// Failure from local or live search when the other tier still succeeded.
  final Failure? warning;
}

/// User-facing portfolio and watchlist mutation boundary.
abstract interface class PortfolioEditor {
  /// Searches local data and enabled live providers.
  Future<Result<InstrumentSearchOutcome>> search(String query);

  /// Saves an instrument and adds or replaces its holding.
  Future<Result<void>> addHolding({
    required Instrument instrument,
    required Decimal quantity,
    Money? averagePurchasePrice,
  });

  /// Saves an instrument and adds it to the watchlist.
  Future<Result<void>> addToWatchlist(Instrument instrument);
}

/// Injectable live-search boundary used alongside the local repository.
typedef LiveInstrumentSearch = Future<Result<List<Instrument>>> Function(
  String query,
);

/// Repository/provider-backed [PortfolioEditor].
final class DefaultPortfolioEditor implements PortfolioEditor {
  /// Creates the editor.
  const DefaultPortfolioEditor({
    required this.instruments,
    required this.portfolio,
    required this.liveSearch,
    required this.clock,
  });

  /// Local instrument store.
  final InstrumentRepository instruments;

  /// User portfolio store.
  final PortfolioRepository portfolio;

  /// Enabled provider fallback search.
  final LiveInstrumentSearch liveSearch;

  /// User-action timestamp source.
  final Clock clock;

  @override
  Future<Result<InstrumentSearchOutcome>> search(String query) async {
    final String normalized = query.trim();
    if (normalized.isEmpty) {
      return const Success<InstrumentSearchOutcome>(
        InstrumentSearchOutcome(instruments: <Instrument>[]),
      );
    }

    final Result<List<Instrument>> local = await instruments.search(normalized);
    final Result<List<Instrument>> live = await liveSearch(normalized);
    final List<Instrument>? localItems = local.valueOrNull;
    final List<Instrument>? liveItems = live.valueOrNull;
    if (localItems == null && liveItems == null) {
      return Failed<InstrumentSearchOutcome>(live.failureOrNull!);
    }

    final Map<String, Instrument> merged = <String, Instrument>{
      for (final Instrument instrument in localItems ?? const <Instrument>[])
        instrument.internalId: instrument,
      // A fresh provider result may contain richer metadata and mappings.
      for (final Instrument instrument in liveItems ?? const <Instrument>[])
        instrument.internalId: instrument,
    };
    final List<Instrument> sorted = merged.values.toList()
      ..sort((Instrument left, Instrument right) {
        final int bySymbol = left.symbol.compareTo(right.symbol);
        return bySymbol != 0 ? bySymbol : left.name.compareTo(right.name);
      });
    return Success<InstrumentSearchOutcome>(
      InstrumentSearchOutcome(
        instruments: List<Instrument>.unmodifiable(sorted),
        warning: local.failureOrNull ?? live.failureOrNull,
      ),
    );
  }

  @override
  Future<Result<void>> addHolding({
    required Instrument instrument,
    required Decimal quantity,
    Money? averagePurchasePrice,
  }) => Result.guardAsync<void>(() async {
    if (quantity <= Decimal.zero) {
      throw const InvalidInstrumentFailure(
        message: 'Enter a quantity greater than zero.',
      );
    }
    if (averagePurchasePrice != null &&
        averagePurchasePrice.currency != instrument.currency) {
      throw InvalidInstrumentFailure(
        message: 'The purchase price must use ${instrument.currency.code}.',
      );
    }
    if (averagePurchasePrice?.isNegative ?? false) {
      throw const InvalidInstrumentFailure(
        message: 'The purchase price cannot be negative.',
      );
    }
    _rethrow(await instruments.save(instrument));
    _rethrow(
      await portfolio.saveHolding(
        Holding(
          instrumentId: instrument.internalId,
          quantity: quantity,
          averagePurchasePrice: averagePurchasePrice,
          provenance: Provenance.user(clock.now()),
        ),
      ),
    );
  });

  @override
  Future<Result<void>> addToWatchlist(Instrument instrument) =>
      Result.guardAsync<void>(() async {
        _rethrow(await instruments.save(instrument));
        final DateTime now = clock.now();
        _rethrow(
          await portfolio.addToWatchlist(
            WatchlistEntry(
              instrumentId: instrument.internalId,
              addedAt: now,
              provenance: Provenance.user(now),
            ),
          ),
        );
      });

  static void _rethrow(Result<void> result) {
    final Failure? failure = result.failureOrNull;
    if (failure != null) {
      throw failure;
    }
  }
}
