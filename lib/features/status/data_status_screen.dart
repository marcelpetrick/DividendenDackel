import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/core/logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transparency and debugging surface (Vision.md §41, §42).
///
/// Currently shows the recent operation log; provider health and active request
/// tracking arrive with the Request Coordinator in tasks F7 and F12.
class DataStatusScreen extends ConsumerWidget {
  /// Creates the data status screen.
  const DataStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InMemoryLogSink sink = ref.watch(logSinkProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Data status')),
      body: StreamBuilder<LogRecord>(
        stream: sink.stream,
        builder: (BuildContext context, AsyncSnapshot<LogRecord> snapshot) {
          final List<LogRecord> records = sink.records.reversed.toList(
            growable: false,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(AppTheme.space * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Data sources', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppTheme.space / 2),
                    Text(
                      'No provider is configured yet. The app is running on '
                      'the bundled sample dataset, which needs no API key.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.space * 2,
                  AppTheme.space * 2,
                  AppTheme.space * 2,
                  AppTheme.space,
                ),
                child: Text(
                  'Recent activity',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? Center(
                        child: Text(
                          'Nothing logged yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (BuildContext context, int index) {
                          final LogRecord record = records[index];
                          return ListTile(
                            dense: true,
                            title: Text(
                              '${record.component}: ${record.message}',
                              style: theme.textTheme.bodySmall,
                            ),
                            subtitle: Text(
                              <String>[
                                record.level.label,
                                if (record.operation != null) record.operation!,
                                if (record.duration != null)
                                  '${record.duration!.inMilliseconds} ms',
                              ].join(' · '),
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
