import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/theme/app_colors.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/refresh/portfolio_refresh.dart';

/// A dividend's certainty, shown as a word and a shape — never colour alone.
///
/// Vision.md §27 forbids colour as the only carrier of meaning, and §9.4
/// requires estimated values to be visually distinguishable from confirmed
/// ones. Both are satisfied by labelling the status outright.
class DividendStatusChip extends StatelessWidget {
  /// Creates a chip for [status].
  const DividendStatusChip(this.status, {super.key});

  /// The status to describe.
  final DividendStatus status;

  /// The word shown to the user.
  static String labelFor(DividendStatus status) => switch (status) {
    DividendStatus.confirmed => 'Confirmed',
    DividendStatus.announced => 'Announced',
    DividendStatus.expected => 'Expected',
    DividendStatus.historicallyEstimated => 'Estimated',
    DividendStatus.unknown => 'Unconfirmed',
  };

  static IconData _iconFor(DividendStatus status) => switch (status) {
    DividendStatus.confirmed => Icons.check_circle_outline,
    DividendStatus.announced => Icons.campaign_outlined,
    DividendStatus.expected => Icons.schedule_outlined,
    DividendStatus.historicallyEstimated => Icons.query_stats_outlined,
    DividendStatus.unknown => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = status.isEstimate
        ? context.semanticColors.estimate
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label: context.tr('Dividend status: ${labelFor(status)}'),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_iconFor(status), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            labelFor(status),
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Renders a money amount, optionally signed and coloured by direction.
class MoneyText extends StatelessWidget {
  /// Creates a money label.
  const MoneyText(
    this.amount, {
    this.style,
    this.showSign = false,
    this.colorBySign = false,
    super.key,
  });

  /// The amount to render.
  final Money amount;

  /// Text style override.
  final TextStyle? style;

  /// Whether to prefix a `+` on positive amounts.
  final bool showSign;

  /// Whether to tint by direction. Never the only cue — the sign is always
  /// present when this is enabled.
  final bool colorBySign;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String text = amount.format(withSymbol: true);
    final String prefix = showSign && amount.isPositive ? '+' : '';

    Color? color;
    if (colorBySign && !amount.isZero) {
      color = amount.isPositive
          ? context.semanticColors.positive
          : context.semanticColors.negative;
    }

    return Text(
      '$prefix$text',
      style: (style ?? theme.textTheme.bodyMedium)?.copyWith(color: color),
    );
  }
}

/// Explains how fresh a value is (Vision.md §2.5, §38).
class FreshnessLabel extends StatelessWidget {
  /// Creates a freshness label for [provenance] as of [now].
  const FreshnessLabel(this.provenance, {required this.now, super.key});

  /// Where the value came from.
  final Provenance provenance;

  /// The current time.
  final DateTime now;

  /// Renders an age as approximate, human wording.
  static String describeAge(Duration age) {
    if (age.inMinutes < 1) {
      return 'just now';
    }
    if (age.inMinutes < 60) {
      return '${age.inMinutes} min ago';
    }
    if (age.inHours < 24) {
      return '${age.inHours} h ago';
    }
    return '${age.inDays} d ago';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String source = provenance.source == Provenance.sampleSource
        ? 'Sample data'
        : provenance.source;
    final String age = describeAge(provenance.ageAt(now));
    final String suffix = provenance.isStale ? ' · refreshing…' : '';

    return Text(
      '$source · $age$suffix',
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Compact app-wide explanation of saved-data age and refresh activity.
class DataFreshnessBanner extends StatelessWidget {
  /// Creates the banner from shared refresh state.
  const DataFreshnessBanner({
    required this.state,
    required this.now,
    super.key,
  });

  final PortfolioRefreshState state;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final DateTime? completedAt = state.lastCompletedAt;
    final String age = completedAt == null
        ? 'saved data'
        : FreshnessLabel.describeAge(now.difference(completedAt));
    final String progress = state.isRefreshing ? ' — refreshing…' : '';
    final String failure = state.failureCount > 0
        ? ' · ${state.failureCount} source ${state.failureCount == 1 ? 'failed' : 'failures'}; saved data remains visible'
        : '';
    final String message = 'Last updated $age$progress$failure';
    final ThemeData theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      label: context.tr(message),
      child: Container(
        width: double.infinity,
        color: theme.colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: <Widget>[
            if (state.isRefreshing)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox.square(
                  dimension: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  state.failureCount > 0
                      ? Icons.cloud_off_outlined
                      : Icons.offline_pin_outlined,
                  size: 16,
                ),
              ),
            Expanded(child: Text(message, style: theme.textTheme.labelSmall)),
          ],
        ),
      ),
    );
  }
}
