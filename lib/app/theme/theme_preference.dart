import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for the user's theme choice.
///
/// Kept behind an interface so application and widget tests never depend on a
/// platform channel. Theme choice is not sensitive; API keys use secure local
/// storage when F11 lands.
abstract interface class ThemePreferenceStore {
  /// Loads the saved mode, falling back to [ThemeMode.system].
  Future<ThemeMode> load();

  /// Persists [mode].
  Future<void> save(ThemeMode mode);
}

/// Stores the theme mode in the platform preference store.
final class SharedPreferencesThemePreferenceStore
    implements ThemePreferenceStore {
  /// Creates the store.
  SharedPreferencesThemePreferenceStore({
    Future<SharedPreferences> Function()? loadPreferences,
  }) : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance;

  static const String _key = 'appearance.themeMode';

  final Future<SharedPreferences> Function() _loadPreferences;

  @override
  Future<ThemeMode> load() async {
    final SharedPreferences preferences = await _loadPreferences();
    final String? saved = preferences.getString(_key);
    return ThemeMode.values
            .where((ThemeMode mode) => mode.name == saved)
            .firstOrNull ??
        ThemeMode.system;
  }

  @override
  Future<void> save(ThemeMode mode) async {
    final SharedPreferences preferences = await _loadPreferences();
    final bool saved = await preferences.setString(_key, mode.name);
    if (!saved) {
      throw StateError('The platform preference store rejected the write.');
    }
  }
}

/// UI state for the theme preference.
@immutable
final class ThemePreferenceState {
  /// Creates preference state.
  const ThemePreferenceState({
    this.mode = ThemeMode.system,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  /// Mode currently applied to the app.
  final ThemeMode mode;

  /// Whether the initial persisted value is being read.
  final bool isLoading;

  /// Whether the current value is being persisted.
  final bool isSaving;

  /// User-facing persistence failure, if any.
  final String? errorMessage;

  /// Returns a copy with explicitly supplied values.
  ThemePreferenceState copyWith({
    ThemeMode? mode,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) => ThemePreferenceState(
    mode: mode ?? this.mode,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

/// Reads and writes the selected theme while applying changes immediately.
final class ThemePreferenceController extends Notifier<ThemePreferenceState> {
  bool _disposed = false;

  @override
  ThemePreferenceState build() {
    ref.onDispose(() => _disposed = true);
    unawaited(_load());
    return const ThemePreferenceState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final ThemeMode mode = await ref
          .read(themePreferenceStoreProvider)
          .load();
      if (!_disposed) {
        state = ThemePreferenceState(mode: mode);
      }
    } on Object {
      if (!_disposed) {
        state = const ThemePreferenceState(
          errorMessage: 'Could not load the saved theme. Using system theme.',
        );
      }
    }
  }

  /// Applies [mode] now, then persists it for the next launch.
  Future<void> select(ThemeMode mode) async {
    state = state.copyWith(mode: mode, isSaving: true, clearError: true);
    try {
      await ref.read(themePreferenceStoreProvider).save(mode);
      if (!_disposed) {
        state = state.copyWith(isSaving: false, clearError: true);
      }
    } on Object {
      if (!_disposed) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Theme changed, but could not be saved for next time.',
        );
      }
    }
  }
}

/// The platform preference implementation. Tests replace this with a fake.
final Provider<ThemePreferenceStore> themePreferenceStoreProvider =
    Provider<ThemePreferenceStore>(
      (Ref ref) => SharedPreferencesThemePreferenceStore(),
    );

/// The selected and persisted application theme.
final NotifierProvider<ThemePreferenceController, ThemePreferenceState>
themePreferenceProvider =
    NotifierProvider<ThemePreferenceController, ThemePreferenceState>(
      ThemePreferenceController.new,
    );
