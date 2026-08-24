import 'package:dividendendackel/app/localization/language_preference.dart';
import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/theme/theme_preference.dart';
import 'package:dividendendackel/features/settings/about_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Application settings (Vision.md §26, §34).
///
/// Theme selection, data-source entry points and the route to About.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ThemePreferenceState themePreference = ref.watch(
      themePreferenceProvider,
    );
    final LanguagePreferenceState languagePreference = ref.watch(
      languagePreferenceProvider,
    );

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
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/data-sources'),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: const Text(
              'Disabled, important-only or all factual portfolio events',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Dividend tax estimate'),
            subtitle: const Text(
              'Per-portfolio gross/net assumptions, allowance and withholding',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/tax'),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency & exchange rates'),
            subtitle: const Text(
              'Display currency, ECB rate dates, sources and staleness',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/currency'),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppTheme.space * 2),
            child: Text('Appearance', style: theme.textTheme.titleSmall),
          ),
          IgnorePointer(
            ignoring: themePreference.isLoading,
            child: RadioGroup<ThemeMode>(
              groupValue: themePreference.mode,
              onChanged: (ThemeMode? mode) {
                if (mode != null) {
                  ref.read(themePreferenceProvider.notifier).select(mode);
                }
              },
              child: const Column(
                children: <Widget>[
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    secondary: Icon(Icons.brightness_auto_outlined),
                    title: Text('System'),
                    subtitle: Text('Match this device'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    secondary: Icon(Icons.light_mode_outlined),
                    title: Text('Light'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    secondary: Icon(Icons.dark_mode_outlined),
                    title: Text('Dark'),
                  ),
                ],
              ),
            ),
          ),
          if (themePreference.isSaving)
            LinearProgressIndicator(semanticsLabel: context.tr('Saving theme')),
          if (themePreference.errorMessage case final String message)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.space * 2,
                AppTheme.space,
                AppTheme.space * 2,
                AppTheme.space * 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.warning_amber_outlined,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: AppTheme.space),
                  Expanded(child: Text(message)),
                  TextButton(
                    onPressed: () => ref
                        .read(themePreferenceProvider.notifier)
                        .select(themePreference.mode),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppTheme.space * 2),
            child: Text('Language', style: theme.textTheme.titleSmall),
          ),
          IgnorePointer(
            ignoring:
                languagePreference.isLoading || languagePreference.isSaving,
            child: RadioGroup<AppLanguage>(
              groupValue: languagePreference.language,
              onChanged: (AppLanguage? language) {
                if (language != null) {
                  ref
                      .read(languagePreferenceProvider.notifier)
                      .select(language);
                }
              },
              child: Column(
                children: <Widget>[
                  for (final AppLanguage language in AppLanguage.values)
                    RadioListTile<AppLanguage>(
                      key: ValueKey<String>('language-${language.code}'),
                      value: language,
                      secondary: const Icon(Icons.language_outlined),
                      title: Text(language.nativeName),
                    ),
                ],
              ),
            ),
          ),
          if (languagePreference.isSaving)
            LinearProgressIndicator(
              semanticsLabel: context.tr('Saving language'),
            ),
          if (languagePreference.errorMessage case final String message)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.space * 2,
                AppTheme.space,
                AppTheme.space * 2,
                AppTheme.space * 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.warning_amber_outlined,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: AppTheme.space),
                  Expanded(child: Text(message)),
                  TextButton(
                    onPressed: () => ref
                        .read(languagePreferenceProvider.notifier)
                        .select(languagePreference.language),
                    child: const Text('Retry'),
                  ),
                ],
              ),
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
