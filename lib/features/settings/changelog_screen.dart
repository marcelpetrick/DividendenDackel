import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/features/settings/changelog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Parsed release history, read from the bundled `CHANGELOG.md`.
final FutureProvider<List<ChangelogRelease>> changelogProvider =
    FutureProvider<List<ChangelogRelease>>((Ref ref) => ChangelogParser.load());

/// The app's own release history, shown from the same file the repository uses.
class ChangelogScreen extends ConsumerWidget {
  /// Creates the screen.
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ChangelogRelease>> releases = ref.watch(
      changelogProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('What changed')),
      body: AsyncValueView<List<ChangelogRelease>>(
        value: releases,
        onRetry: () => ref.invalidate(changelogProvider),
        builder: (BuildContext context, List<ChangelogRelease> data) =>
            data.isEmpty
            ? const Center(child: Text('No release notes are available.'))
            : ListView.builder(
                padding: const EdgeInsets.all(AppTheme.space * 2),
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) =>
                    _ReleaseBlock(data[index]),
              ),
      ),
    );
  }
}

class _ReleaseBlock extends StatelessWidget {
  const _ReleaseBlock(this.release);

  final ChangelogRelease release;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space * 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Flexible(
                child: release.isUnreleased
                    ? Text('In development', style: theme.textTheme.titleMedium)
                    : Text(
                        release.version,
                        style: theme.textTheme.titleMedium,
                        translate: false,
                      ),
              ),
              if (release.date case final DateTime date) ...<Widget>[
                const SizedBox(width: AppTheme.space),
                Text(
                  _isoDay(date),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  translate: false,
                ),
              ],
            ],
          ),
          if (release.isUnreleased)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.space / 2),
              child: Text(
                'Finished and merged, not yet in a published build.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final ChangelogSection section in release.sections) ...<Widget>[
            const SizedBox(height: AppTheme.space * 1.5),
            Text(
              section.title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppTheme.space / 2),
            for (final String entry in section.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.space / 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('•  ', style: theme.textTheme.bodyMedium),
                    Expanded(
                      child: Text(
                        entry,
                        style: theme.textTheme.bodyMedium,
                        // Release notes are the repository's own English text.
                        // Translating them per build would either fabricate
                        // history or go stale; the screen's own copy is
                        // localized instead.
                        translate: false,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  static String _isoDay(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
