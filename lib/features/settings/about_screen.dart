import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          Text('Data sources', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTheme.space),
          Text(
            'Currently showing the bundled sample dataset. It is illustrative '
            'and is not real market data.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.space * 3),
          Text('Licence', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppTheme.space),
          Text('GPLv3 or later.', style: theme.textTheme.bodyMedium),
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
