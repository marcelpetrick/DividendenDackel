import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:dividendendackel/features/currency/fx_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  test(
    'refresh fetches tracked quotes and persists successful rates',
    () async {
      final DateTime now = DateTime.utc(2026, 8, 23, 12);
      final _FxRepository repository = _FxRepository();
      Set<Currency>? requested;
      final FxRate rate = FxRate(
        base: Currency.eur,
        quote: Currency.usd,
        rate: Decimal.parse('1.2'),
        observedAt: DateTime.utc(2026, 8, 21),
        provenance: Provenance(source: 'ecb', fetchedAt: now),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          clockProvider.overrideWithValue(FakeClock(now)),
          trackedCurrenciesProvider.overrideWith(
            (Ref ref) async => <Currency>{Currency.eur, Currency.usd},
          ),
          fxRateRepositoryProvider.overrideWithValue(repository),
          fxRateFetcherProvider.overrideWithValue((base, quotes, range) async {
            expect(base, Currency.eur);
            expect(range.contains(DateTime.utc(2026, 8, 21)), isTrue);
            requested = quotes;
            return Result<List<FxRate>>.success(<FxRate>[rate]);
          }),
        ],
      );
      addTearDown(container.dispose);

      await container.read(fxRefreshProvider.notifier).refresh();

      expect(requested, <Currency>{Currency.usd});
      expect(repository.saved, <FxRate>[rate]);
      expect(container.read(fxRefreshProvider).errorMessage, isNull);
    },
  );
}

final class _FxRepository implements FxRateRepository {
  List<FxRate> saved = const <FxRate>[];

  @override
  Future<Result<void>> saveAll(List<FxRate> rates) async {
    saved = rates;
    return const Result<void>.success(null);
  }

  @override
  Stream<List<FxRate>> watchInRange(
    Currency base,
    Set<Currency> quotes,
    DateRange range,
  ) => Stream<List<FxRate>>.value(saved);

  @override
  Stream<Map<Currency, FxRate>> watchLatest(
    Currency base,
    Set<Currency> quotes,
  ) => Stream<Map<Currency, FxRate>>.value(<Currency, FxRate>{});
}
