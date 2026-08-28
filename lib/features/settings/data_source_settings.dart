import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data sources the user can configure.
enum MarketDataSource {
  /// US filings and company facts; no credential required.
  secEdgar,

  /// ECB reference exchange rates via Frankfurter; no credential required.
  frankfurter,

  /// Instrument identity outside the US via OpenFIGI; no credential required.
  openFigi,

  /// Optional Financial Modeling Prep account.
  financialModelingPrep,

  /// Optional Finnhub account.
  finnhub,

  /// Optional Alpha Vantage account.
  alphaVantage;

  /// User-facing provider name.
  String get label => switch (this) {
    secEdgar => 'SEC EDGAR',
    frankfurter => 'Frankfurter / ECB',
    openFigi => 'OpenFIGI',
    financialModelingPrep => 'Financial Modeling Prep',
    finnhub => 'Finnhub',
    alphaVantage => 'Alpha Vantage',
  };

  /// Stable id shared with provider mappings and request coordination.
  String get providerId => switch (this) {
    secEdgar => 'sec',
    frankfurter => 'frankfurter',
    openFigi => 'openfigi',
    financialModelingPrep => 'fmp',
    finnhub => 'finnhub',
    alphaVantage => 'alpha_vantage',
  };

  /// What the source contributes to the app.
  String get description => switch (this) {
    secEdgar => 'US dividend history, company facts and filings',
    frankfurter => 'Daily reference exchange rates',
    openFigi => 'Finds non-US listings by ISIN, symbol or name. Identity only, never prices',
    financialModelingPrep => 'Optional quotes, calendars and fundamentals',
    finnhub => 'Optional news, calendars and market data',
    alphaVantage => 'Optional fundamentals and market data',
  };

  /// Whether the source needs a credential supplied by the user.
  bool get requiresApiKey => switch (this) {
    secEdgar || frankfurter || openFigi => false,
    financialModelingPrep || finnhub || alphaVantage => true,
  };

  /// Keyless providers are active by default; optional providers are opt-in.
  bool get enabledByDefault => !requiresApiKey;
}

/// Non-secret state for one provider.
@immutable
final class DataSourceConfiguration {
  /// Creates configuration state.
  const DataSourceConfiguration({
    required this.source,
    required this.enabled,
    required this.hasApiKey,
  });

  /// Provider being configured.
  final MarketDataSource source;

  /// Whether requests may use this provider.
  final bool enabled;

  /// Whether a credential exists. The credential itself never enters UI state.
  final bool hasApiKey;

  /// Returns a copy with changed values.
  DataSourceConfiguration copyWith({bool? enabled, bool? hasApiKey}) =>
      DataSourceConfiguration(
        source: source,
        enabled: enabled ?? this.enabled,
        hasApiKey: hasApiKey ?? this.hasApiKey,
      );
}

/// Secure credential boundary.
abstract interface class ApiSecretStore {
  /// Whether [key] exists without returning its value to the caller.
  Future<bool> contains(String key);

  /// Reads a credential, for provider adapters only.
  ///
  /// The UI asks [contains] instead: a key must never enter widget state,
  /// a snapshot, a log line or an error message (Vision.md §34, §80). This
  /// exists because an adapter has to put the value on the wire, and nothing
  /// else may call it.
  Future<String?> read(String key);

  /// Writes a credential.
  Future<void> write(String key, String value);

  /// Removes a credential.
  Future<void> delete(String key);
}

/// Android Keystore / Linux Secret Service credential implementation.
final class SecureApiSecretStore implements ApiSecretStore {
  /// Creates the secure store.
  const SecureApiSecretStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<bool> contains(String key) async =>
      (await _storage.read(key: key))?.isNotEmpty ?? false;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Persistence boundary for provider settings.
abstract interface class DataSourceSettingsStore {
  /// Loads non-sensitive status for [source].
  Future<DataSourceConfiguration> load(MarketDataSource source);

  /// Persists whether [source] is enabled.
  Future<void> setEnabled(MarketDataSource source, bool enabled);

  /// Saves a user-supplied credential securely.
  Future<void> setApiKey(MarketDataSource source, String apiKey);

  /// Deletes a provider credential.
  Future<void> removeApiKey(MarketDataSource source);
}

/// Stores toggles in preferences and credentials in secure platform storage.
final class PlatformDataSourceSettingsStore implements DataSourceSettingsStore {
  /// Creates the platform-backed store.
  PlatformDataSourceSettingsStore({
    this.secrets = const SecureApiSecretStore(),
    Future<SharedPreferences> Function()? loadPreferences,
  }) : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;

  /// Secure store used for key material.
  final ApiSecretStore secrets;
  final Future<SharedPreferences> Function() _loadPreferences;

  static String _enabledKey(MarketDataSource source) =>
      'provider.${source.name}.enabled';

  /// Secure-storage key holding [source]'s credential.
  static String secretKey(MarketDataSource source) =>
      'dividendendackel.provider.${source.name}.apiKey';

  @override
  Future<DataSourceConfiguration> load(MarketDataSource source) async {
    final SharedPreferences preferences = await _loadPreferences();
    final bool enabled =
        preferences.getBool(_enabledKey(source)) ?? source.enabledByDefault;
    final bool hasApiKey = source.requiresApiKey
        ? await secrets.contains(secretKey(source))
        : false;
    return DataSourceConfiguration(
      source: source,
      enabled: enabled && (!source.requiresApiKey || hasApiKey),
      hasApiKey: hasApiKey,
    );
  }

  @override
  Future<void> setEnabled(MarketDataSource source, bool enabled) async {
    final SharedPreferences preferences = await _loadPreferences();
    final bool saved = await preferences.setBool(_enabledKey(source), enabled);
    if (!saved) {
      throw StateError('The platform preference store rejected the write.');
    }
  }

  @override
  Future<void> setApiKey(MarketDataSource source, String apiKey) async {
    if (!source.requiresApiKey) {
      throw ArgumentError.value(source, 'source', 'Source does not use a key');
    }
    final String trimmed = apiKey.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(apiKey, 'apiKey', 'API key must not be empty');
    }
    await secrets.write(secretKey(source), trimmed);
  }

  @override
  Future<void> removeApiKey(MarketDataSource source) =>
      secrets.delete(secretKey(source));
}

/// Provider-settings UI state.
@immutable
final class DataSourceSettingsState {
  /// Creates state.
  const DataSourceSettingsState({
    required this.configurations,
    this.isLoading = false,
    this.busySources = const <MarketDataSource>{},
    this.errorMessage,
  });

  /// Status for all supported sources.
  final List<DataSourceConfiguration> configurations;

  /// Whether initial settings are loading.
  final bool isLoading;

  /// Providers currently being changed.
  final Set<MarketDataSource> busySources;

  /// Recoverable storage error to show to the user.
  final String? errorMessage;

  /// Returns configuration for [source].
  DataSourceConfiguration configurationFor(MarketDataSource source) =>
      configurations.firstWhere(
        (DataSourceConfiguration item) => item.source == source,
      );

  /// Returns a copy with changed values.
  DataSourceSettingsState copyWith({
    List<DataSourceConfiguration>? configurations,
    bool? isLoading,
    Set<MarketDataSource>? busySources,
    String? errorMessage,
    bool clearError = false,
  }) => DataSourceSettingsState(
    configurations: configurations ?? this.configurations,
    isLoading: isLoading ?? this.isLoading,
    busySources: busySources ?? this.busySources,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

/// Loads and mutates provider settings without ever exposing key material.
final class DataSourceSettingsController
    extends Notifier<DataSourceSettingsState> {
  bool _disposed = false;

  @override
  DataSourceSettingsState build() {
    ref.onDispose(() => _disposed = true);
    // `reload` updates state before its first await, so defer it until Riverpod
    // has installed the initial value returned below.
    unawaited(Future<void>.microtask(reload));
    return DataSourceSettingsState(configurations: _defaults, isLoading: true);
  }

  List<DataSourceConfiguration> get _defaults => MarketDataSource.values
      .map(
        (MarketDataSource source) => DataSourceConfiguration(
          source: source,
          enabled: source.enabledByDefault,
          hasApiKey: false,
        ),
      )
      .toList(growable: false);

  /// Reloads all settings after an initial or recoverable failure.
  Future<void> reload() async {
    if (!_disposed) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final DataSourceSettingsStore store = ref.read(
        dataSourceSettingsStoreProvider,
      );
      final List<DataSourceConfiguration> configurations = await Future.wait(
        MarketDataSource.values.map(store.load),
      );
      if (!_disposed) {
        state = DataSourceSettingsState(configurations: configurations);
      }
    } on Object {
      if (!_disposed) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load data-source settings.',
        );
      }
    }
  }

  /// Enables or disables [source]. Keyed sources require a saved key first.
  Future<void> setEnabled(MarketDataSource source, bool enabled) async {
    final DataSourceConfiguration current = state.configurationFor(source);
    if (enabled && source.requiresApiKey && !current.hasApiKey) {
      state = state.copyWith(
        errorMessage: 'Add a ${source.label} API key before enabling it.',
      );
      return;
    }
    await _mutate(source, () async {
      await ref
          .read(dataSourceSettingsStoreProvider)
          .setEnabled(source, enabled);
      _replace(current.copyWith(enabled: enabled));
    });
  }

  /// Stores a key and enables its provider.
  Future<void> setApiKey(MarketDataSource source, String apiKey) async {
    await _mutate(source, () async {
      final DataSourceSettingsStore store = ref.read(
        dataSourceSettingsStoreProvider,
      );
      await store.setApiKey(source, apiKey);
      await store.setEnabled(source, true);
      _replace(
        state.configurationFor(source).copyWith(hasApiKey: true, enabled: true),
      );
    });
  }

  /// Disables [source] and removes its key.
  Future<void> removeApiKey(MarketDataSource source) async {
    await _mutate(source, () async {
      final DataSourceSettingsStore store = ref.read(
        dataSourceSettingsStoreProvider,
      );
      await store.setEnabled(source, false);
      await store.removeApiKey(source);
      _replace(
        state
            .configurationFor(source)
            .copyWith(hasApiKey: false, enabled: false),
      );
    });
  }

  Future<void> _mutate(
    MarketDataSource source,
    Future<void> Function() operation,
  ) async {
    state = state.copyWith(
      busySources: <MarketDataSource>{...state.busySources, source},
      clearError: true,
    );
    try {
      await operation();
    } on Object {
      if (!_disposed) {
        state = state.copyWith(
          errorMessage: 'Could not save ${source.label} settings.',
        );
      }
    } finally {
      if (!_disposed) {
        state = state.copyWith(
          busySources: <MarketDataSource>{...state.busySources}..remove(source),
        );
      }
    }
  }

  void _replace(DataSourceConfiguration replacement) {
    if (_disposed) {
      return;
    }
    state = state.copyWith(
      configurations: <DataSourceConfiguration>[
        for (final DataSourceConfiguration item in state.configurations)
          if (item.source == replacement.source) replacement else item,
      ],
    );
  }
}

/// Platform-backed provider settings; tests replace it with an in-memory fake.
/// Secure credential store, shared by settings and by provider adapters.
///
/// Settings only ever asks whether a credential exists; an adapter reads the
/// value to put it on the wire. Both go through this one boundary so there is a
/// single place where key material is handled (Vision.md §34, §80).
final Provider<ApiSecretStore> apiSecretStoreProvider =
    Provider<ApiSecretStore>((Ref ref) => const SecureApiSecretStore());

final Provider<DataSourceSettingsStore> dataSourceSettingsStoreProvider =
    Provider<DataSourceSettingsStore>(
      (Ref ref) => PlatformDataSourceSettingsStore(
        secrets: ref.watch(apiSecretStoreProvider),
      ),
    );

/// Provider configuration observed by Settings and later by the registry.
final NotifierProvider<DataSourceSettingsController, DataSourceSettingsState>
dataSourceSettingsProvider =
    NotifierProvider<DataSourceSettingsController, DataSourceSettingsState>(
      DataSourceSettingsController.new,
    );
