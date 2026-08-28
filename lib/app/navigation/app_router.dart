import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/navigation/app_shell.dart';
import 'package:dividendendackel/app/navigation/destinations.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/features/calendar/calendar_screen.dart';
import 'package:dividendendackel/features/calendar/forecast_screen.dart';
import 'package:dividendendackel/features/currency/fx_state.dart';
import 'package:dividendendackel/features/notifications/notification_settings_screen.dart';
import 'package:dividendendackel/features/notifications/notification_state.dart';
import 'package:dividendendackel/features/portfolio/portfolio_screen.dart';
import 'package:dividendendackel/features/refresh/portfolio_refresh.dart';
import 'package:dividendendackel/features/research/research_detail_screen.dart';
import 'package:dividendendackel/features/research/research_screen.dart';
import 'package:dividendendackel/features/settings/about_screen.dart';
import 'package:dividendendackel/features/settings/changelog_screen.dart';
import 'package:dividendendackel/features/settings/currency_settings_screen.dart';
import 'package:dividendendackel/features/settings/data_sources_screen.dart';
import 'package:dividendendackel/features/settings/settings_screen.dart';
import 'package:dividendendackel/features/settings/tax_settings_screen.dart';
import 'package:dividendendackel/features/status/data_status_screen.dart';
import 'package:dividendendackel/features/today/today_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Builds the application router.
///
/// The four top-level destinations live inside a shell so switching between
/// them does not rebuild the frame, while secondary screens are pushed on top.
GoRouter buildRouter({String initialLocation = '/today'}) => GoRouter(
  initialLocation: initialLocation,
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) =>
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? _) {
              final PortfolioRefreshState refresh = ref.watch(
                portfolioRefreshProvider,
              );
              return AppShell(
                currentDestination: AppDestination.fromLocation(state.uri.path),
                onDestinationSelected: (AppDestination destination) =>
                    context.go(destination.path),
                actions: <Widget>[
                  IconButton(
                    icon: refresh.isRefreshing
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    tooltip: context.tr(
                      refresh.isRefreshing ? 'Refreshing data' : 'Refresh data',
                    ),
                    onPressed: refresh.isRefreshing
                        ? null
                        : () async {
                            await ref
                                .read(portfolioRefreshProvider.notifier)
                                .refresh(force: true);
                            await ref
                                .read(fxRefreshProvider.notifier)
                                .refresh();
                            await ref
                                .read(notificationSettingsProvider.notifier)
                                .sync();
                          },
                  ),
                  IconButton(
                    icon: const Icon(Icons.dns_outlined),
                    tooltip: context.tr('Data status'),
                    onPressed: () => context.push('/status'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: context.tr('Settings'),
                    onPressed: () => context.push('/settings'),
                  ),
                ],
                banner: DataFreshnessBanner(
                  state: refresh,
                  now: ref.watch(clockProvider).now(),
                ),
                child: child,
              );
            },
          ),
      routes: <RouteBase>[
        GoRoute(
          path: '/today',
          builder: (BuildContext context, GoRouterState state) =>
              const TodayScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (BuildContext context, GoRouterState state) =>
              const CalendarScreen(),
        ),
        GoRoute(
          path: '/calendar/forecast',
          builder: (BuildContext context, GoRouterState state) =>
              const ForecastScreen(),
        ),
        GoRoute(
          path: '/portfolio',
          builder: (BuildContext context, GoRouterState state) =>
              const PortfolioScreen(),
        ),
        GoRoute(
          path: '/research',
          builder: (BuildContext context, GoRouterState state) =>
              const ResearchScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/status',
      builder: (BuildContext context, GoRouterState state) =>
          const DataStatusScreen(),
    ),
    GoRoute(
      path: '/research/:instrumentId',
      builder: (BuildContext context, GoRouterState state) =>
          ResearchDetailScreen(
            instrumentId: state.pathParameters['instrumentId']!,
          ),
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) =>
          const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/notifications',
      builder: (BuildContext context, GoRouterState state) =>
          const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/data-sources',
      builder: (BuildContext context, GoRouterState state) =>
          const DataSourcesScreen(),
    ),
    GoRoute(
      path: '/settings/currency',
      builder: (BuildContext context, GoRouterState state) =>
          const CurrencySettingsScreen(),
    ),
    GoRoute(
      path: '/settings/tax',
      builder: (BuildContext context, GoRouterState state) =>
          const TaxSettingsScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (BuildContext context, GoRouterState state) =>
          const AboutScreen(),
    ),
    GoRoute(
      path: '/about/changelog',
      builder: (BuildContext context, GoRouterState state) =>
          const ChangelogScreen(),
    ),
  ],
);
