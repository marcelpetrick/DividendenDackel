import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_colors.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/core/logging/logging.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/settings/data_source_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transparent provider health and request diagnostics (Vision.md §41–§43).
class DataStatusScreen extends ConsumerWidget {
  /// Creates the data status screen.
  const DataStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DataSourceSettingsState settings = ref.watch(
      dataSourceSettingsProvider,
    );
    final AsyncValue<List<ProviderStatus>> statusesValue = ref.watch(
      providerStatusesProvider,
    );
    final List<ProviderStatus> statuses =
        statusesValue.value ?? const <ProviderStatus>[];
    final AsyncValue<List<RequestStatus>> operationsValue = ref.watch(
      activeOperationsProvider,
    );
    final List<RequestStatus> operations =
        operationsValue.value ?? const <RequestStatus>[];
    final InMemoryLogSink sink = ref.watch(logSinkProvider);
    final DateTime now = ref.watch(clockProvider).now();
    final Map<String, ProviderStatus> byProvider = <String, ProviderStatus>{
      for (final ProviderStatus status in statuses) status.providerId: status,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Data status')),
      body: StreamBuilder<LogRecord>(
        stream: sink.stream,
        builder: (BuildContext context, AsyncSnapshot<LogRecord> snapshot) {
          final List<LogRecord> records = sink.records.reversed
              .take(100)
              .toList(growable: false);
          return ListView(
            padding: const EdgeInsets.all(AppTheme.space * 2),
            children: <Widget>[
              if (statusesValue.hasError ||
                  operationsValue.hasError) ...<Widget>[
                const _QuietState(
                  icon: Icons.warning_amber_outlined,
                  text:
                      'Some provider diagnostics could not be read. Saved '
                      'status entries remain visible.',
                ),
                const SizedBox(height: AppTheme.space),
              ],
              Text(
                'Data sources',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.space / 2),
              Text(
                'Live health and locally retained request statistics. '
                'Portfolio values and credentials are never included.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppTheme.space),
              for (final DataSourceConfiguration configuration
                  in settings.configurations)
                _ProviderCard(
                  configuration: configuration,
                  status: byProvider[configuration.source.providerId],
                  activeCount: operations
                      .where(
                        (RequestStatus operation) =>
                            operation.provider ==
                            configuration.source.providerId,
                      )
                      .length,
                  now: now,
                ),
              const SizedBox(height: AppTheme.space),
              Text(
                'Current activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.space / 2),
              if (operations.isEmpty)
                const _QuietState(
                  icon: Icons.check_circle_outline,
                  text: 'No active requests.',
                )
              else
                for (final RequestStatus operation in operations)
                  _OperationTile(operation: operation, now: now),
              const SizedBox(height: AppTheme.space * 2),
              Text(
                'Recent activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.space / 2),
              if (records.isEmpty)
                const _QuietState(
                  icon: Icons.history_outlined,
                  text: 'Nothing logged yet.',
                )
              else
                for (final LogRecord record in records)
                  _LogTile(record: record),
            ],
          );
        },
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.configuration,
    required this.status,
    required this.activeCount,
    required this.now,
  });

  final DataSourceConfiguration configuration;
  final ProviderStatus? status;
  final int activeCount;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ProviderStatus? status = this.status;
    final _HealthPresentation health = _healthPresentation(
      configuration.enabled ? status?.health : null,
      enabled: configuration.enabled,
      colors: context.semanticColors,
      scheme: theme.colorScheme,
    );
    final double? hitRate = status?.cacheHitRate;

    return Card(
      key: ValueKey<String>('provider-${configuration.source.providerId}'),
      margin: const EdgeInsets.only(bottom: AppTheme.space),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    configuration.source.label,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Icon(health.icon, color: health.color, size: 18),
                const SizedBox(width: AppTheme.space / 2),
                Text(
                  health.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: health.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space),
            Wrap(
              spacing: AppTheme.space * 2,
              runSpacing: AppTheme.space / 2,
              children: <Widget>[
                _Metric(
                  label: 'Active requests',
                  value: activeCount.toString(),
                ),
                _Metric(
                  label: 'Last request',
                  value: status?.lastRequestAt == null
                      ? 'Never'
                      : FreshnessLabel.describeAge(
                          context,
                          now.difference(status!.lastRequestAt!),
                        ),
                ),
                _Metric(
                  label: 'Cache hit rate',
                  value: hitRate == null
                      ? 'No cache requests yet'
                      : '${(hitRate * 100).round()}% '
                            '(${status!.cacheHits}/'
                            '${status.cacheHits + status.cacheMisses})',
                ),
              ],
            ),
            if (status?.rateLimitResetAt
                case final DateTime retryAt) ...<Widget>[
              const SizedBox(height: AppTheme.space),
              Text.format('Retry available: {time}', <String, Object?>{
                'time': _formatDateTime(context, retryAt),
              }, style: theme.textTheme.bodySmall),
            ],
            if (status?.lastErrorMessage case final String message) ...<Widget>[
              const SizedBox(height: AppTheme.space),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppTheme.space / 2),
                  Expanded(
                    child: Text.format(
                      'Last error: {message}',
                      <String, Object?>{'message': message},
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.tr('$label: $value'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({required this.operation, required this.now});

  final RequestStatus operation;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final Duration? duration = operation.durationAt(now);
    return Card(
      child: ListTile(
        leading: operation.lifecycle == RequestLifecycle.queued
            ? const Icon(Icons.more_horiz)
            : const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
        title: Text(operation.operation),
        subtitle: Text(
          <String>[
            operation.provider,
            operation.lifecycle.name,
            operation.priority.name,
            if (operation.attempt > 0)
              context.trFormat('attempt {count}', <String, Object?>{
                'count': operation.attempt,
              }),
            if (duration != null) '${duration.inMilliseconds} ms',
            if (operation.rateLimitResetAt != null)
              context.trFormat('retry {time}', <String, Object?>{
                'time': _formatDateTime(context, operation.rateLimitResetAt!),
              }),
            if (operation.failureMessage != null) operation.failureMessage!,
          ].join(' · '),
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.record});

  final LogRecord record;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      record.errorCategory == null
          ? Icons.check_circle_outline
          : Icons.error_outline,
      size: 18,
    ),
    title: Text('${record.component}: ${record.message}', translate: false),
    subtitle: Text(
      <String>[
        record.level.label,
        if (record.provider != null) record.provider!,
        if (record.operation != null) record.operation!,
        if (record.duration != null) '${record.duration!.inMilliseconds} ms',
      ].join(' · '),
    ),
  );
}

class _QuietState extends StatelessWidget {
  const _QuietState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppTheme.space),
    child: Row(
      children: <Widget>[
        Icon(icon, size: 18),
        const SizedBox(width: AppTheme.space),
        Text(text),
      ],
    ),
  );
}

final class _HealthPresentation {
  const _HealthPresentation(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

_HealthPresentation _healthPresentation(
  ProviderHealth? health, {
  required bool enabled,
  required AppSemanticColors colors,
  required ColorScheme scheme,
}) {
  if (!enabled) {
    return _HealthPresentation(
      'Disabled',
      Icons.pause_circle_outline,
      scheme.onSurfaceVariant,
    );
  }
  return switch (health ?? ProviderHealth.unknown) {
    ProviderHealth.unknown => _HealthPresentation(
      'Idle',
      Icons.schedule_outlined,
      scheme.onSurfaceVariant,
    ),
    ProviderHealth.healthy => _HealthPresentation(
      'Connected',
      Icons.check_circle_outline,
      colors.positive,
    ),
    ProviderHealth.degraded => _HealthPresentation(
      'Degraded',
      Icons.warning_amber_outlined,
      colors.estimate,
    ),
    ProviderHealth.offline => _HealthPresentation(
      'Offline',
      Icons.cloud_off_outlined,
      colors.negative,
    ),
    ProviderHealth.authenticationError => _HealthPresentation(
      'Authentication error',
      Icons.key_off_outlined,
      colors.negative,
    ),
    ProviderHealth.rateLimited => _HealthPresentation(
      'Rate limited',
      Icons.timer_outlined,
      colors.estimate,
    ),
  };
}

String _formatDateTime(BuildContext context, DateTime value) {
  final MaterialLocalizations localizations = MaterialLocalizations.of(context);
  final DateTime local = value.toLocal();
  return '${localizations.formatMediumDate(local)} '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}
