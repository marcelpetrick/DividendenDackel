import 'dart:async';

import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for the non-sensitive display currency preference.
abstract interface class DisplayCurrencyStore {
  /// Loads the saved currency, defaulting to EUR.
  Future<Currency> load();

  /// Saves the selected currency.
  Future<void> save(Currency currency);
}

/// SharedPreferences implementation used on Android and Linux.
final class PlatformDisplayCurrencyStore implements DisplayCurrencyStore {
  /// Creates the platform store.
  PlatformDisplayCurrencyStore({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  static const String _key = 'portfolio.displayCurrency';
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<Currency> load() async {
    final Currency saved = Currency.parse(
      (await _preferences()).getString(_key) ?? Currency.eur.code,
    );
    return saved.isKnown ? saved : Currency.eur;
  }

  @override
  Future<void> save(Currency currency) async {
    if (!await (await _preferences()).setString(_key, currency.code)) {
      throw StateError('The platform preference store rejected the write.');
    }
  }
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

  @override
  DisplayCurrencyState build() {
    ref.onDispose(() => _disposed = true);
    unawaited(_load());
    return const DisplayCurrencyState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final Currency currency = await ref
          .read(displayCurrencyStoreProvider)
          .load();
      if (!_disposed) state = DisplayCurrencyState(currency: currency);
    } on Object {
      if (!_disposed) {
        state = const DisplayCurrencyState(
          errorMessage: 'Could not load display currency. Using EUR.',
        );
      }
    }
  }

  /// Applies [currency] now and saves it for the next launch.
  Future<void> select(Currency currency) async {
    state = DisplayCurrencyState(currency: currency, isSaving: true);
    try {
      await ref.read(displayCurrencyStoreProvider).save(currency);
      if (!_disposed) state = DisplayCurrencyState(currency: currency);
    } on Object {
      if (!_disposed) {
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
