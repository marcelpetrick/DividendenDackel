import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for the first-run walkthrough flag.
abstract interface class OnboardingStore {
  /// Whether the walkthrough has been completed on this device.
  Future<bool> isComplete();

  /// Persists completion.
  Future<void> complete();
}

/// SharedPreferences implementation used on Android and Linux.
final class PlatformOnboardingStore implements OnboardingStore {
  /// Creates the platform store.
  PlatformOnboardingStore({Future<SharedPreferences> Function()? preferences})
    : _preferences = preferences ?? SharedPreferences.getInstance;

  static const String _key = 'onboarding.completed.v1';
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<bool> isComplete() async =>
      (await _preferences()).getBool(_key) ?? false;

  @override
  Future<void> complete() async {
    if (!await (await _preferences()).setBool(_key, true)) {
      throw StateError('The platform preference store rejected the write.');
    }
  }
}

/// Overridden by hermetic tests.
final Provider<OnboardingStore> onboardingStoreProvider =
    Provider<OnboardingStore>((Ref ref) => PlatformOnboardingStore());

/// Loads the first-run gate before the main application shell is shown.
final FutureProvider<bool> onboardingCompletedProvider = FutureProvider<bool>(
  (Ref ref) => ref.watch(onboardingStoreProvider).isComplete(),
);
