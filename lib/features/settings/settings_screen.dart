import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/features/settings/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Application settings (Vision.md §26, §34).
///
/// Theme mode and the tax profile arrive with later tasks; this is the frame
/// and the route to About.
class SettingsScreen extends StatelessWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppTheme.space * 2),
            child: Text('Data', style: theme.textTheme.titleSmall),
          ),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: const Text('Data sources'),
            subtitle: const Text(
              'The app works without an API key. Optional keys are stored '
              'only on this device.',
            ),
            onTap: null,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppTheme.space * 2),
            child: Text('App', style: theme.textTheme.titleSmall),
          ),
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? _) {
              final AsyncValue<AppVersionInfo> version = ref.watch(
                appVersionProvider,
              );
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                // Surfaced here too, so checking the version does not require
                // knowing to open another screen.
                subtitle: Text(switch (version) {
                  AsyncData<AppVersionInfo>(:final AppVersionInfo value) =>
                    'Version ${value.displayVersion}',
                  AsyncError<AppVersionInfo>() => 'Version unavailable',
                  _ => 'Version…',
                }),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/about'),
              );
            },
          ),
        ],
      ),
    );
  }
}
