import 'dart:async';

import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for the non-sensitive display currency preference.
abstract interface class DisplayCurrencyStore {
  /// Loads the saved currency for [portfolioId], defaulting to EUR.
  Future<Currency> load(String portfolioId);

  /// Saves the selected currency for [portfolioId].
  Future<void> save(String portfolioId, Currency currency);
}

/// SharedPreferences implementation used on Android and Linux.
final class PlatformDisplayCurrencyStore implements DisplayCurrencyStore {
  /// Creates the platform store.
  PlatformDisplayCurrencyStore({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  static const String _legacyKey = 'portfolio.displayCurrency';
  static const String _keyPrefix = 'portfolio.displayCurrency.v2.';
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<Currency> load(String portfolioId) async {
    final SharedPreferences preferences = await _preferences();
    final String? scoped = preferences.getString(_key(portfolioId));
    final String? migrated = portfolioId == InvestmentPortfolio.defaultId
        ? preferences.getString(_legacyKey)
        : null;
    final Currency saved = Currency.parse(
      scoped ?? migrated ?? Currency.eur.code,
    );
    return saved.isKnown ? saved : Currency.eur;
  }

  @override
  Future<void> save(String portfolioId, Currency currency) async {
    if (!await (await _preferences()).setString(
      _key(portfolioId),
      currency.code,
    )) {
      throw StateError('The platform preference store rejected the write.');
    }
  }

  static String _key(String portfolioId) =>
      '$_keyPrefix${Uri.encodeComponent(portfolioId)}';
}

/// Immediately applied display-currency preference state.
final class DisplayCurrencyState {
  /// Creates preference state.
  const DisplayCurrencyState({
    this.currency = Currency.eur,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });
  final Currency currency;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
}

/// Loads and persists the display currency.
final class DisplayCurrencyController extends Notifier<DisplayCurrencyState> {
  bool _disposed = false;
  String _scopeId = InvestmentPortfolio.defaultId;

  @override
  DisplayCurrencyState build() {
    _disposed = false;
    _scopeId =
        ref.watch(effectivePortfolioIdProvider) ??
        InvestmentPortfolio.consolidatedId;
    ref.onDispose(() => _disposed = true);
    unawaited(_load(_scopeId));
    return const DisplayCurrencyState(isLoading: true);
  }

  Future<void> _load(String scopeId) async {
    try {
      final Currency currency = await ref
          .read(displayCurrencyStoreProvider)
          .load(scopeId);
      if (!_disposed && scopeId == _scopeId) {
        state = DisplayCurrencyState(currency: currency);
      }
    } on Object {
      if (!_disposed && scopeId == _scopeId) {
        state = const DisplayCurrencyState(
          errorMessage: 'Could not load display currency. Using EUR.',
        );
      }
    }
  }

  /// Applies [currency] now and saves it for the next launch.
  Future<void> select(Currency currency) async {
    final String scopeId = _scopeId;
    state = DisplayCurrencyState(currency: currency, isSaving: true);
    try {
      await ref.read(displayCurrencyStoreProvider).save(scopeId, currency);
      if (!_disposed && scopeId == _scopeId) {
        state = DisplayCurrencyState(currency: currency);
      }
    } on Object {
      if (!_disposed && scopeId == _scopeId) {
        state = DisplayCurrencyState(
          currency: currency,
          errorMessage:
              'Currency changed, but could not be saved for next time.',
        );
      }
    }
  }
}

/// Platform store, overridden in tests.
final Provider<DisplayCurrencyStore> displayCurrencyStoreProvider =
    Provider<DisplayCurrencyStore>((Ref ref) => PlatformDisplayCurrencyStore());

/// Selected portfolio display currency.
final NotifierProvider<DisplayCurrencyController, DisplayCurrencyState>
displayCurrencyProvider =
    NotifierProvider<DisplayCurrencyController, DisplayCurrencyState>(
      DisplayCurrencyController.new,
    );
