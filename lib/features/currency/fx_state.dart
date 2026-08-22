import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/features/settings/currency_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Currencies needed by holdings plus the selected display currency.
final FutureProvider<Set<Currency>> trackedCurrenciesProvider =
    FutureProvider<Set<Currency>>((Ref ref) async {
      final Currency displayCurrency = ref
          .watch(displayCurrencyProvider)
          .currency;
      final Future<List<Holding>> holdingsFuture = ref.watch(
        holdingsProvider.future,
      );
      final Future<Map<String, Instrument>> instrumentsFuture = ref.watch(
        instrumentsByIdProvider.future,
      );
      final List<Holding> holdings = await holdingsFuture;
      final Map<String, Instrument> instruments = await instrumentsFuture;
      return <Currency>{
        displayCurrency,
        for (final Holding holding in holdings)
          if (instruments[holding.instrumentId] case final instrument?)
            instrument.currency,
      };
    });

/// Injectable coordinated fetch boundary used by the refresh controller.
final Provider<
  Future<Result<List<FxRate>>> Function(
    Currency base,
    Set<Currency> quotes,
    DateRange range,
  )
>
fxRateFetcherProvider = Provider((Ref ref) {
  return ref.watch(providerMarketDataServiceProvider).fxRates;
});

/// All cached ECB reference rates needed by analytics and dated tax.
final StreamProvider<List<FxRate>> cachedFxRatesProvider =
    StreamProvider<List<FxRate>>((Ref ref) {
      final DateTime now = ref.watch(clockProvider).now().toUtc();
      return ref
          .watch(fxRateRepositoryProvider)
          .watchInRange(
            Currency.eur,
            Currency.known.values
                .where((Currency currency) => currency != Currency.eur)
                .toSet(),
            DateRange(DateTime.utc(2000), DateTime.utc(now.year + 3)),
          );
    });

/// User-visible state of a coordinated ECB refresh.
final class FxRefreshState {
  /// Creates refresh state.
  const FxRefreshState({this.isRefreshing = false, this.errorMessage});
  final bool isRefreshing;
  final String? errorMessage;
}

/// Fetches and persists recent ECB rates through the shared coordinator.
final class FxRefreshController extends Notifier<FxRefreshState> {
  @override
  FxRefreshState build() => const FxRefreshState();

  /// Refreshes tracked non-EUR currencies and leaves cached data visible.
  Future<void> refresh() async {
    if (state.isRefreshing) return;
    state = const FxRefreshState(isRefreshing: true);
    try {
      final Set<Currency> quotes = <Currency>{
        ...await ref.read(trackedCurrenciesProvider.future),
      }..remove(Currency.eur);
      if (quotes.isEmpty) {
        state = const FxRefreshState();
        return;
      }
      final DateTime now = ref.read(clockProvider).now().toUtc();
      final Result<List<FxRate>> fetched =
          await ref.read(fxRateFetcherProvider)(
            Currency.eur,
            quotes,
            DateRange(
              now.subtract(const Duration(days: 14)),
              now.add(const Duration(days: 1)),
            ),
          );
      switch (fetched) {
        case Success<List<FxRate>>(:final List<FxRate> value):
          final Result<void> saved = await ref
              .read(fxRateRepositoryProvider)
              .saveAll(value);
          state = FxRefreshState(errorMessage: saved.failureOrNull?.message);
        case Failed<List<FxRate>>(:final failure):
          state = FxRefreshState(errorMessage: failure.message);
      }
    } on Object {
      state = const FxRefreshState(
        errorMessage: 'Could not determine which exchange rates to refresh.',
      );
    }
  }
}

/// Refresh action/state shared by settings and portfolio.
final NotifierProvider<FxRefreshController, FxRefreshState> fxRefreshProvider =
    NotifierProvider<FxRefreshController, FxRefreshState>(
      FxRefreshController.new,
    );
