import 'package:dividendendackel/app/navigation/app_router.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
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

class _DividendenDackelAppState extends ConsumerState<DividendenDackelApp> {
  late final GoRouter _router = buildRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Seeding runs once and is idempotent; watching it here means the very
    // first frame already has data on the way.
    ref.watch(sampleDataProvider);

    return MaterialApp.router(
      title: 'DividendenDackel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Vision.md §26: System, Light and Dark are supported from the start.
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
