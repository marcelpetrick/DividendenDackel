import 'dart:async';

import 'package:dividendendackel/app/theme/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesThemePreferenceStore', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('defaults to system when no preference exists', () async {
      final SharedPreferencesThemePreferenceStore store =
          SharedPreferencesThemePreferenceStore();

      expect(await store.load(), ThemeMode.system);
    });

    test('ignores an unknown persisted value', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'appearance.themeMode': 'sepia',
      });
      final SharedPreferencesThemePreferenceStore store =
          SharedPreferencesThemePreferenceStore();

      expect(await store.load(), ThemeMode.system);
    });

    test('round-trips every supported mode', () async {
      final SharedPreferencesThemePreferenceStore store =
          SharedPreferencesThemePreferenceStore();

      for (final ThemeMode mode in ThemeMode.values) {
        await store.save(mode);
        expect(await store.load(), mode);
      }
    });
  });

  group('ThemePreferenceController', () {
    test('loads and exposes the persisted preference', () async {
      final _FakeThemePreferenceStore store = _FakeThemePreferenceStore(
        initial: ThemeMode.dark,
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [themePreferenceStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);

      expect(container.read(themePreferenceProvider).isLoading, isTrue);
      await _flushAsyncWork();

      expect(container.read(themePreferenceProvider).mode, ThemeMode.dark);
      expect(container.read(themePreferenceProvider).isLoading, isFalse);
    });

    test('applies a selection before persistence finishes', () async {
      final Completer<void> save = Completer<void>();
      final _FakeThemePreferenceStore store = _FakeThemePreferenceStore(
        saveCompleter: save,
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [themePreferenceStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      container.read(themePreferenceProvider);
      await _flushAsyncWork();

      final Future<void> operation = container
          .read(themePreferenceProvider.notifier)
          .select(ThemeMode.light);

      expect(container.read(themePreferenceProvider).mode, ThemeMode.light);
      expect(container.read(themePreferenceProvider).isSaving, isTrue);
      save.complete();
      await operation;
      expect(container.read(themePreferenceProvider).isSaving, isFalse);
      expect(store.saved, <ThemeMode>[ThemeMode.light]);
    });

    test('keeps the applied mode and reports a save failure', () async {
      final _FakeThemePreferenceStore store = _FakeThemePreferenceStore(
        saveError: Exception('disk full'),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [themePreferenceStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      container.read(themePreferenceProvider);
      await _flushAsyncWork();

      await container
          .read(themePreferenceProvider.notifier)
          .select(ThemeMode.dark);

      final ThemePreferenceState state = container.read(
        themePreferenceProvider,
      );
      expect(state.mode, ThemeMode.dark);
      expect(state.isSaving, isFalse);
      expect(state.errorMessage, contains('could not be saved'));
    });

    test('falls back to system and reports a load failure', () async {
      final _FakeThemePreferenceStore store = _FakeThemePreferenceStore(
        loadError: Exception('unreadable'),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [themePreferenceStoreProvider.overrideWithValue(store)],
      );
      addTearDown(container.dispose);
      container.read(themePreferenceProvider);
      await _flushAsyncWork();

      final ThemePreferenceState state = container.read(
        themePreferenceProvider,
      );
      expect(state.mode, ThemeMode.system);
      expect(state.errorMessage, contains('Could not load'));
    });
  });
}

Future<void> _flushAsyncWork() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

final class _FakeThemePreferenceStore implements ThemePreferenceStore {
  _FakeThemePreferenceStore({
    this.initial = ThemeMode.system,
    this.loadError,
    this.saveError,
    this.saveCompleter,
  });

  final ThemeMode initial;
  final Exception? loadError;
  final Exception? saveError;
  final Completer<void>? saveCompleter;
  final List<ThemeMode> saved = <ThemeMode>[];

  @override
  Future<ThemeMode> load() async {
    if (loadError case final Exception error) {
      throw error;
    }
    return initial;
  }

  @override
  Future<void> save(ThemeMode mode) async {
    saved.add(mode);
    if (saveError case final Exception error) {
      throw error;
    }
    await saveCompleter?.future;
  }
}
