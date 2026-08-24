import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Languages fully supported by the application UI.
enum AppLanguage {
  /// English.
  english('en', 'English'),

  /// German.
  german('de', 'Deutsch'),

  /// Croatian.
  croatian('hr', 'Hrvatski');

  const AppLanguage(this.code, this.nativeName);

  /// ISO 639-1 language code.
  final String code;

  /// Language name shown without requiring an existing translation.
  final String nativeName;

  /// Flutter locale for this choice.
  Locale get locale => Locale(code);

  /// Resolves a supported locale, falling back to English.
  static AppLanguage fromLocale(Locale locale) => values.firstWhere(
    (AppLanguage language) => language.code == locale.languageCode,
    orElse: () => AppLanguage.english,
  );
}

/// Persistence boundary for the selected language.
abstract interface class LanguagePreferenceStore {
  /// Loads the saved language or a supported platform default.
  Future<AppLanguage> load();

  /// Persists [language].
  Future<void> save(AppLanguage language);
}

/// Stores the language in ordinary local preferences.
final class SharedPreferencesLanguagePreferenceStore
    implements LanguagePreferenceStore {
  /// Creates the store.
  SharedPreferencesLanguagePreferenceStore({
    Future<SharedPreferences> Function()? loadPreferences,
    Locale Function()? platformLocale,
  }) : _loadPreferences = loadPreferences ?? SharedPreferences.getInstance,
       _platformLocale =
           platformLocale ??
           (() => WidgetsBinding.instance.platformDispatcher.locale);

  static const String _key = 'appearance.language';

  final Future<SharedPreferences> Function() _loadPreferences;
  final Locale Function() _platformLocale;

  @override
  Future<AppLanguage> load() async {
    final SharedPreferences preferences = await _loadPreferences();
    final String? saved = preferences.getString(_key);
    return AppLanguage.values
            .where((AppLanguage language) => language.code == saved)
            .firstOrNull ??
        AppLanguage.fromLocale(_platformLocale());
  }

  @override
  Future<void> save(AppLanguage language) async {
    final SharedPreferences preferences = await _loadPreferences();
    final bool saved = await preferences.setString(_key, language.code);
    if (!saved) {
      throw StateError('The platform preference store rejected the write.');
    }
  }
}

/// State applied by the root app and shown by Settings.
@immutable
final class LanguagePreferenceState {
  /// Creates language preference state.
  const LanguagePreferenceState({
    this.language = AppLanguage.english,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  /// Language currently applied to the widget tree.
  final AppLanguage language;

  /// Whether the persisted choice is loading.
  final bool isLoading;

  /// Whether a new choice is being persisted.
  final bool isSaving;

  /// User-visible persistence failure.
  final String? errorMessage;

  /// Returns a copy with selected values changed.
  LanguagePreferenceState copyWith({
    AppLanguage? language,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) => LanguagePreferenceState(
    language: language ?? this.language,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

/// Loads, applies and saves the language without restarting the application.
final class LanguagePreferenceController
    extends Notifier<LanguagePreferenceState> {
  bool _disposed = false;

  @override
  LanguagePreferenceState build() {
    ref.onDispose(() => _disposed = true);
    unawaited(_load());
    return const LanguagePreferenceState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final AppLanguage language = await ref
          .read(languagePreferenceStoreProvider)
          .load();
      if (!_disposed) state = LanguagePreferenceState(language: language);
    } on Object {
      if (!_disposed) {
        state = const LanguagePreferenceState(
          errorMessage: 'Could not load the saved language. Using English.',
        );
      }
    }
  }

  /// Applies [language] immediately, then saves it for the next launch.
  Future<void> select(AppLanguage language) async {
    state = state.copyWith(
      language: language,
      isSaving: true,
      clearError: true,
    );
    try {
      await ref.read(languagePreferenceStoreProvider).save(language);
      if (!_disposed) {
        state = state.copyWith(isSaving: false, clearError: true);
      }
    } on Object {
      if (!_disposed) {
        state = state.copyWith(
          isSaving: false,
          errorMessage:
              'Language changed, but could not be saved for next time.',
        );
      }
    }
  }
}

/// Platform store; widget tests replace this boundary.
final Provider<LanguagePreferenceStore> languagePreferenceStoreProvider =
    Provider<LanguagePreferenceStore>(
      (Ref ref) => SharedPreferencesLanguagePreferenceStore(),
    );

/// Selected application language.
final NotifierProvider<LanguagePreferenceController, LanguagePreferenceState>
languagePreferenceProvider =
    NotifierProvider<LanguagePreferenceController, LanguagePreferenceState>(
      LanguagePreferenceController.new,
    );
