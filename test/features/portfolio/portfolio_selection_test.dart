import 'dart:async';

import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/portfolio/portfolio_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('defaults to the personal portfolio', () async {
    final PlatformPortfolioSelectionStore store =
        PlatformPortfolioSelectionStore();

    expect(await store.load(), InvestmentPortfolio.defaultId);
  });

  test('round-trips one portfolio and the consolidated scope', () async {
    final PlatformPortfolioSelectionStore store =
        PlatformPortfolioSelectionStore();

    await store.save('retirement');
    expect(await store.load(), 'retirement');

    await store.save(null);
    expect(await store.load(), isNull);
  });

  test(
    'a user selection wins a race with the initial persisted load',
    () async {
      final _DelayedStore store = _DelayedStore();
      final ProviderContainer container = ProviderContainer(
        overrides: [portfolioSelectionStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      container.read(portfolioSelectionProvider);
      await container
          .read(portfolioSelectionProvider.notifier)
          .select('retirement');
      store.loaded.complete(InvestmentPortfolio.defaultId);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(portfolioSelectionProvider).portfolioId,
        'retirement',
      );
    },
  );
}

final class _DelayedStore implements PortfolioSelectionStore {
  final Completer<String?> loaded = Completer<String?>();

  @override
  Future<String?> load() => loaded.future;

  @override
  Future<void> save(String? portfolioId) async {}
}
