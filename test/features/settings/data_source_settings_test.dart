import 'package:dividendendackel/features/settings/data_source_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PlatformDataSourceSettingsStore', () {
    late _MemorySecretStore secrets;
    late PlatformDataSourceSettingsStore store;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      secrets = _MemorySecretStore();
      store = PlatformDataSourceSettingsStore(secrets: secrets);
    });

    test('uses keyless-on and optional-off defaults', () async {
      expect((await store.load(MarketDataSource.secEdgar)).enabled, isTrue);
      expect((await store.load(MarketDataSource.frankfurter)).enabled, isTrue);
      expect(
        (await store.load(MarketDataSource.financialModelingPrep)).enabled,
        isFalse,
      );
    });

    test('uses stable ids shared with provider mappings', () {
      expect(MarketDataSource.secEdgar.providerId, 'sec');
      expect(MarketDataSource.frankfurter.providerId, 'frankfurter');
      expect(MarketDataSource.financialModelingPrep.providerId, 'fmp');
      expect(MarketDataSource.finnhub.providerId, 'finnhub');
      expect(MarketDataSource.alphaVantage.providerId, 'alpha_vantage');
    });

    test('persists an explicit keyless-provider toggle', () async {
      await store.setEnabled(MarketDataSource.secEdgar, false);

      expect((await store.load(MarketDataSource.secEdgar)).enabled, isFalse);
    });

    test('never reports a keyed provider enabled without a key', () async {
      await store.setEnabled(MarketDataSource.finnhub, true);

      final DataSourceConfiguration configuration = await store.load(
        MarketDataSource.finnhub,
      );
      expect(configuration.enabled, isFalse);
      expect(configuration.hasApiKey, isFalse);
    });

    test('trims keys and keeps them out of plain preferences', () async {
      await store.setApiKey(MarketDataSource.alphaVantage, '  secret-123  ');

      expect(secrets.values.values, contains('secret-123'));
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      expect(
        preferences.getKeys().any((String key) => key.contains('apiKey')),
        isFalse,
      );
      expect(
        preferences.getKeys().any(
          (String key) => preferences.get(key) == 'secret-123',
        ),
        isFalse,
      );
    });

    test('rejects empty keys and keys for keyless providers', () async {
      await expectLater(
        store.setApiKey(MarketDataSource.finnhub, '   '),
        throwsArgumentError,
      );
      await expectLater(
        store.setApiKey(MarketDataSource.secEdgar, 'not-used'),
        throwsArgumentError,
      );
    });

    test('removes a saved credential', () async {
      await store.setApiKey(MarketDataSource.finnhub, 'secret');
      expect((await store.load(MarketDataSource.finnhub)).hasApiKey, isTrue);

      await store.removeApiKey(MarketDataSource.finnhub);

      expect((await store.load(MarketDataSource.finnhub)).hasApiKey, isFalse);
    });
  });

  group('DataSourceSettingsController', () {
    test('loads every provider configuration', () async {
      final _FakeDataSourceSettingsStore store = _FakeDataSourceSettingsStore();
      store.configurations[MarketDataSource.finnhub] =
          const DataSourceConfiguration(
            source: MarketDataSource.finnhub,
            enabled: true,
            hasApiKey: true,
          );
      final ProviderContainer container = _container(store);
      addTearDown(container.dispose);

      container.read(dataSourceSettingsProvider);
      await _flushAsyncWork();

      final DataSourceSettingsState state = container.read(
        dataSourceSettingsProvider,
      );
      expect(state.isLoading, isFalse);
      expect(state.configurations, hasLength(MarketDataSource.values.length));
      expect(state.configurationFor(MarketDataSource.finnhub).enabled, isTrue);
    });

    test('does not enable a keyed provider before a key exists', () async {
      final _FakeDataSourceSettingsStore store = _FakeDataSourceSettingsStore();
      final ProviderContainer container = _container(store);
      addTearDown(container.dispose);
      container.read(dataSourceSettingsProvider);
      await _flushAsyncWork();

      await container
          .read(dataSourceSettingsProvider.notifier)
          .setEnabled(MarketDataSource.finnhub, true);

      final DataSourceSettingsState state = container.read(
        dataSourceSettingsProvider,
      );
      expect(state.configurationFor(MarketDataSource.finnhub).enabled, isFalse);
      expect(state.errorMessage, contains('Add a Finnhub API key'));
      expect(store.enabledWrites, isEmpty);
    });

    test('saving a key enables its provider', () async {
      final _FakeDataSourceSettingsStore store = _FakeDataSourceSettingsStore();
      final ProviderContainer container = _container(store);
      addTearDown(container.dispose);
      container.read(dataSourceSettingsProvider);
      await _flushAsyncWork();

      await container
          .read(dataSourceSettingsProvider.notifier)
          .setApiKey(MarketDataSource.financialModelingPrep, 'new-secret');

      final DataSourceConfiguration configuration = container
          .read(dataSourceSettingsProvider)
          .configurationFor(MarketDataSource.financialModelingPrep);
      expect(configuration.hasApiKey, isTrue);
      expect(configuration.enabled, isTrue);
      expect(store.keys[MarketDataSource.financialModelingPrep], 'new-secret');
      expect(
        store.enabledWrites,
        contains((MarketDataSource.financialModelingPrep, true)),
      );
    });

    test('removing a key disables its provider', () async {
      final _FakeDataSourceSettingsStore store = _FakeDataSourceSettingsStore();
      store.configurations[MarketDataSource.alphaVantage] =
          const DataSourceConfiguration(
            source: MarketDataSource.alphaVantage,
            enabled: true,
            hasApiKey: true,
          );
      store.keys[MarketDataSource.alphaVantage] = 'secret';
      final ProviderContainer container = _container(store);
      addTearDown(container.dispose);
      container.read(dataSourceSettingsProvider);
      await _flushAsyncWork();

      await container
          .read(dataSourceSettingsProvider.notifier)
          .removeApiKey(MarketDataSource.alphaVantage);

      final DataSourceConfiguration configuration = container
          .read(dataSourceSettingsProvider)
          .configurationFor(MarketDataSource.alphaVantage);
      expect(configuration.enabled, isFalse);
      expect(configuration.hasApiKey, isFalse);
      expect(store.keys, isNot(contains(MarketDataSource.alphaVantage)));
    });

    test('surfaces a storage failure without changing prior state', () async {
      final _FakeDataSourceSettingsStore store = _FakeDataSourceSettingsStore()
        ..failWrites = true;
      final ProviderContainer container = _container(store);
      addTearDown(container.dispose);
      container.read(dataSourceSettingsProvider);
      await _flushAsyncWork();

      await container
          .read(dataSourceSettingsProvider.notifier)
          .setEnabled(MarketDataSource.secEdgar, false);

      final DataSourceSettingsState state = container.read(
        dataSourceSettingsProvider,
      );
      expect(state.configurationFor(MarketDataSource.secEdgar).enabled, isTrue);
      expect(state.errorMessage, contains('Could not save SEC EDGAR'));
      expect(state.busySources, isEmpty);
    });
  });
}

ProviderContainer _container(DataSourceSettingsStore store) =>
    ProviderContainer(
      overrides: [dataSourceSettingsStoreProvider.overrideWithValue(store)],
    );

Future<void> _flushAsyncWork() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

final class _MemorySecretStore implements ApiSecretStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<bool> contains(String key) async => values.containsKey(key);

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

final class _FakeDataSourceSettingsStore implements DataSourceSettingsStore {
  _FakeDataSourceSettingsStore() {
    for (final MarketDataSource source in MarketDataSource.values) {
      configurations[source] = DataSourceConfiguration(
        source: source,
        enabled: source.enabledByDefault,
        hasApiKey: false,
      );
    }
  }

  final Map<MarketDataSource, DataSourceConfiguration> configurations =
      <MarketDataSource, DataSourceConfiguration>{};
  final Map<MarketDataSource, String> keys = <MarketDataSource, String>{};
  final List<(MarketDataSource, bool)> enabledWrites =
      <(MarketDataSource, bool)>[];
  bool failWrites = false;

  @override
  Future<DataSourceConfiguration> load(MarketDataSource source) async =>
      configurations[source]!;

  @override
  Future<void> removeApiKey(MarketDataSource source) async {
    _maybeFail();
    keys.remove(source);
    configurations[source] = configurations[source]!.copyWith(hasApiKey: false);
  }

  @override
  Future<void> setApiKey(MarketDataSource source, String apiKey) async {
    _maybeFail();
    keys[source] = apiKey;
    configurations[source] = configurations[source]!.copyWith(hasApiKey: true);
  }

  @override
  Future<void> setEnabled(MarketDataSource source, bool enabled) async {
    _maybeFail();
    enabledWrites.add((source, enabled));
    configurations[source] = configurations[source]!.copyWith(enabled: enabled);
  }

  void _maybeFail() {
    if (failWrites) {
      throw StateError('write failed');
    }
  }
}
