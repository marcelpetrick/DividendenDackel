import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/features/news/news_link_launcher.dart';
import 'package:dividendendackel/features/settings/data_source_guide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Walks the user through obtaining a provider credential.
class DataSourceGuideSheet extends ConsumerWidget {
  /// Creates the sheet for [guide].
  const DataSourceGuideSheet({required this.guide, super.key});

  /// The provider being explained.
  final DataSourceGuide guide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space * 3,
          0,
          AppTheme.space * 3,
          AppTheme.space * 3,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.format('Setting up {source}', <String, Object?>{
                'source': guide.source.label,
              }, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppTheme.space),
              Text(guide.summary, style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppTheme.space * 2),
              for (final (int index, String step) in guide.steps.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.space),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Numbered, because the order matters: the key only
                      // exists after the form is submitted.
                      SizedBox(
                        width: 26,
                        child: Text(
                          '${index + 1}.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          translate: false,
                        ),
                      ),
                      Expanded(
                        child: Text(step, style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ),
              if (guide.caveat case final String caveat) ...<Widget>[
                const SizedBox(height: AppTheme.space),
                Container(
                  padding: const EdgeInsets.all(AppTheme.space),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.info_outline, size: 18),
                      const SizedBox(width: AppTheme.space),
                      Expanded(
                        child: Text(caveat, style: theme.textTheme.bodySmall),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.space * 2),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  key: const ValueKey<String>('guide-open-signup'),
                  onPressed: () => ref
                      .read(newsLinkLauncherProvider)
                      .open(Uri.parse(guide.signUpUrl)),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open the sign-up page'),
                ),
              ),
              const SizedBox(height: AppTheme.space),
              // The key is a credential, so it is said plainly where it is
              // asked for, not buried in a privacy page.
              Text(
                'The key is stored in this device\'s secure credential store '
                'and is never sent anywhere except to that provider.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
