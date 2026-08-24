import 'dart:async';

import 'package:dividendendackel/app/localization/language_preference.dart';
import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/navigation/app_router.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/theme/theme_preference.dart';
import 'package:dividendendackel/features/currency/fx_state.dart';
import 'package:dividendendackel/features/notifications/notification_state.dart';
import 'package:dividendendackel/features/onboarding/onboarding_screen.dart';
import 'package:dividendendackel/features/onboarding/onboarding_state.dart';
import 'package:dividendendackel/features/refresh/portfolio_refresh.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The application root.
class DividendenDackelApp extends ConsumerStatefulWidget {
  /// Creates the app.
  const DividendenDackelApp({this.initialLocation = '/today', super.key});

  /// Where the router starts. Overridden by widget tests.
  final String initialLocation;

  @override
  ConsumerState<DividendenDackelApp> createState() =>
      _DividendenDackelAppState();
}

class _DividendenDackelAppState extends ConsumerState<DividendenDackelApp>
    with WidgetsBindingObserver {
  Future<void>? _refreshCycle;
  late final GoRouter _router = buildRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      unawaited(_refreshAfterSeed());
    });
  }

  Future<void> _refreshAfterSeed() async {
    final Future<void>? existing = _refreshCycle;
    if (existing != null) return existing;
    final Future<void> current = _runRefreshAfterSeed();
    _refreshCycle = current;
    try {
      await current;
    } finally {
      if (identical(_refreshCycle, current)) _refreshCycle = null;
    }
  }

  Future<void> _runRefreshAfterSeed() async {
    if (!ref.read(automaticPortfolioRefreshEnabledProvider)) return;
    try {
      await ref.read(sampleDataProvider.future);
      if (mounted) {
        await ref.read(portfolioRefreshProvider.notifier).refresh();
        await ref.read(fxRefreshProvider.notifier).refresh();
        await ref.read(notificationSettingsProvider.notifier).sync();
      }
    } on Object {
      // The local-data provider records its own failure. The app remains usable
      // and a later resume/manual refresh can retry without an unhandled future.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(automaticPortfolioRefreshEnabledProvider)) {
      unawaited(_refreshAfterSeed());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Seeding runs once and is idempotent; watching it here means the very
    // first frame already has data on the way.
    ref.watch(sampleDataProvider);
    final ThemeMode themeMode = ref.watch(themePreferenceProvider).mode;
    final Locale locale = ref.watch(languagePreferenceProvider).language.locale;
    final AsyncValue<bool> onboarding = ref.watch(onboardingCompletedProvider);

    if (onboarding.value != true) {
      return MaterialApp(
        title: 'DividendenDackel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: onboarding.isLoading && !onboarding.hasError
            ? Scaffold(
                body: Center(
                  child: CircularProgressIndicator.adaptive(
                    semanticsLabel: AppLocalizations(locale)
                        .text('Loading first-run settings'),
                  ),
                ),
              )
            : OnboardingScreen(
                onComplete: () async {
                  await ref.read(onboardingStoreProvider).complete();
                  ref.invalidate(onboardingCompletedProvider);
                },
              ),
      );
    }

    return MaterialApp.router(
      title: 'DividendenDackel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
