import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/features/news/news_link_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Build identity, read from the installed package (Vision.md §62).
final class AppVersionInfo {
  /// Creates version information.
  const AppVersionInfo({
    required this.version,
    required this.buildNumber,
    required this.commit,
  });

  /// Semantic version, e.g. `0.1.0`.
  final String version;

  /// Build number, e.g. `1`.
  final String buildNumber;

  /// Commit the build came from, injected at build time by the release
  /// pipeline with `--dart-define=APP_COMMIT=...`.
  final String commit;

  /// `0.1.0 (1)`.
  String get displayVersion => '$version ($buildNumber)';
}

/// Reads the version from the running package rather than a constant.
///
/// A hardcoded fallback would keep displaying the old number after a version
/// bump, which is exactly the moment the value matters.
final FutureProvider<AppVersionInfo> appVersionProvider =
    FutureProvider<AppVersionInfo>((Ref ref) async {
      final PackageInfo info = await PackageInfo.fromPlatform();
      return AppVersionInfo(
        version: info.version,
        buildNumber: info.buildNumber,
        commit: const String.fromEnvironment(
          'APP_COMMIT',
          defaultValue: 'development build',
        ),
      );
    });

/// Version and provenance information (Vision.md §62).
/// Where defect reports and feature requests are collected.
const String _issuesUrl =
    'https://github.com/marcelpetrick/DividendenDackel/issues';

class AboutScreen extends ConsumerWidget {
  /// Creates the about screen.
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        children: <Widget>[
          Text('DividendenDackel', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppTheme.space / 2),
          Text(
            'The dachshund that fetches your dividends.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTheme.space * 2),
          _VersionBlock(
            ref.watch(appVersionProvider),
            onRetry: () => ref.invalidate(appVersionProvider),
          ),
          const SizedBox(height: AppTheme.space * 3),
          Text('Author', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTheme.space),
          const SelectableText(
            'Marcel Petrick · mail@marcelpetrick.it',
            key: ValueKey<String>('about-author'),
          ),
          const SizedBox(height: AppTheme.space * 3),
          Text('Licence', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTheme.space),
          Text(
            'GNU General Public License v3.0 or later (GPL-3.0-or-later). '
            'The source code is available, and you may use, study, share and '
            'modify it under those terms.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.space * 3),
          Text('Under active development', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTheme.space),
          Text(
            'This app is being built in the open and changes often. Features '
            'are still arriving and rough edges are expected.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.space),
          Text(
            'Ideas for features and reports of anything wrong are genuinely '
            'wanted — a mistaken number matters most of all. Write to the '
            'author, or open an issue in the project repository.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.space),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const ValueKey<String>('about-report'),
              onPressed: () => ref
                  .read(newsLinkLauncherProvider)
                  .open(Uri.parse(_issuesUrl)),
              icon: const Icon(Icons.bug_report_outlined),
              label: const Text('Report a problem or request a feature'),
            ),
          ),
          const SizedBox(height: AppTheme.space * 3),
          Text('Release notes', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTheme.space),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const ValueKey<String>('about-changelog'),
              onPressed: () => context.push('/about/changelog'),
              icon: const Icon(Icons.history_outlined),
              label: const Text('What changed'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionBlock extends StatelessWidget {
  const _VersionBlock(this.info, {required this.onRetry});

  final AsyncValue<AppVersionInfo> info;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AsyncValueView<AppVersionInfo>(
      value: info,
      onRetry: onRetry,
      builder: (BuildContext context, AppVersionInfo data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SelectableText(data.displayVersion, style: theme.textTheme.bodyLarge),
          SelectableText(
            'Commit: ${data.commit}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
