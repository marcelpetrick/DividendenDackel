import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/research/research_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Instrument research (Vision.md §15, §16).
///
/// Lists locally known instruments and opens their evidence-led research view.
class ResearchScreen extends ConsumerWidget {
  /// Creates the research screen.
  const ResearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<String, Instrument>> instruments = ref.watch(
      instrumentsByIdProvider,
    );

    return AsyncValueView<Map<String, Instrument>>(
      value: instruments,
      onRetry: () => ref.invalidate(instrumentsByIdProvider),
      isEmpty: (Map<String, Instrument> data) => data.isEmpty,
      emptyTitle: 'No instruments yet',
      emptyMessage: 'Add a holding or a watchlist entry to research it.',
      emptyIcon: Icons.insights_outlined,
      builder: (BuildContext context, Map<String, Instrument> data) {
        final List<Instrument> list = data.values.toList(growable: false)
          ..sort((Instrument a, Instrument b) => a.name.compareTo(b.name));

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalInset =
                ((constraints.maxWidth - 1200) / 2).clamp(0, double.infinity) +
                AppTheme.space * 2;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalInset,
                AppTheme.space * 2,
                horizontalInset,
                AppTheme.space * 2,
              ),
              children: <Widget>[
                const _ResearchIntroduction(),
                const SizedBox(height: AppTheme.space * 2),
                LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints gridConstraints) {
                        final double scaledBody = MediaQuery.textScalerOf(
                          context,
                        ).scale(16);
                        final int columns = scaledBody >= 24
                            ? 1
                            : gridConstraints.maxWidth >= 1120
                            ? 3
                            : gridConstraints.maxWidth >= 720
                            ? 2
                            : 1;
                        final double cardWidth =
                            (gridConstraints.maxWidth -
                                (columns - 1) * AppTheme.space * 2) /
                            columns;
                        return Wrap(
                          key: const ValueKey<String>('research-card-grid'),
                          spacing: AppTheme.space * 2,
                          runSpacing: AppTheme.space * 2,
                          children: <Widget>[
                            for (final Instrument instrument in list)
                              SizedBox(
                                width: cardWidth,
                                child: _ResearchInstrumentCard(
                                  instrument: instrument,
                                ),
                              ),
                          ],
                        );
                      },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ResearchIntroduction extends StatelessWidget {
  const _ResearchIntroduction();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.fact_check_outlined,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: AppTheme.space * 1.5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Evidence-led research',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTheme.space / 2),
                  const Text('Research context only — not a recommendation.'),
                  const Text(
                    'Scores use available evidence only. Missing dimensions '
                    'are omitted, never scored as zero.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResearchInstrumentCard extends ConsumerWidget {
  const _ResearchInstrumentCard({required this.instrument});

  final Instrument instrument;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<ResearchSnapshot?> snapshot = ref.watch(
      currentResearchSnapshotProvider(instrument.internalId),
    );
    final ResearchSnapshot? value = snapshot.value;
    final String instrumentLabel = context.trFormat(
      'Research {name}, {symbol}',
      <String, Object?>{
        'name': instrument.name,
        'symbol': instrument.displaySymbol,
      },
    );
    final String semanticsLabel = value != null
        ? context.trFormat(
            'Research {name}, {symbol}. Score {score} out of 100 from '
            '{available} of {total} dimensions.',
            <String, Object?>{
              'name': instrument.name,
              'symbol': instrument.displaySymbol,
              'score': value.overall.score,
              'available': value.dimensions.length,
              'total': ResearchDimension.values.length,
            },
          )
        : '$instrumentLabel. ${context.tr(snapshot.isLoading
              ? 'Computing assessment…'
              : snapshot.hasError
              ? 'Assessment unavailable. Instrument details remain available.'
              : 'Not enough cached evidence')}';
    return Semantics(
      button: true,
      label: semanticsLabel,
      hint: context.tr('Open research details'),
      child: ExcludeSemantics(
        child: Card(
          key: ValueKey<String>('research-card-${instrument.internalId}'),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            onTap: () => context.push(
              '/research/${Uri.encodeComponent(instrument.internalId)}',
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              instrument.name,
                              translate: false,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              <String>[
                                instrument.displaySymbol,
                                ?instrument.sector,
                              ].join(' · '),
                              overflow: TextOverflow.ellipsis,
                              translate: false,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: AppTheme.space * 1.5),
                  const Divider(),
                  const SizedBox(height: AppTheme.space * 1.5),
                  _AssessmentPreview(snapshot: snapshot),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AssessmentPreview extends StatelessWidget {
  const _AssessmentPreview({required this.snapshot});

  final AsyncValue<ResearchSnapshot?> snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.value case final ResearchSnapshot value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppTheme.space,
            runSpacing: AppTheme.space / 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Semantics(
                label: context.trFormat(
                  'Research score {score} out of 100',
                  <String, Object?>{'score': value.overall.score},
                ),
                child: Text(
                  '${value.overall.score} / 100',
                  translate: false,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
              Chip(
                avatar: const Icon(Icons.dataset_outlined, size: 16),
                label: Text.format(
                  '{available} of {total} dimensions',
                  <String, Object?>{
                    'available': value.dimensions.length,
                    'total': ResearchDimension.values.length,
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space),
          Wrap(
            spacing: AppTheme.space / 2,
            runSpacing: AppTheme.space / 2,
            children: <Widget>[
              for (final ResearchDimension dimension
                  in ResearchDimension.values)
                if (value.dimensions.containsKey(dimension))
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(_dimensionLabel(dimension)),
                  ),
            ],
          ),
        ],
      );
    }
    if (snapshot.hasError) {
      return const _PreviewMessage(
        icon: Icons.error_outline,
        text: 'Assessment unavailable. Instrument details remain available.',
      );
    }
    if (snapshot.isLoading) {
      return const _PreviewMessage(
        icon: Icons.hourglass_top_outlined,
        text: 'Computing assessment…',
        loading: true,
      );
    }
    return const _PreviewMessage(
      icon: Icons.remove_circle_outline,
      text: 'Not enough cached evidence',
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({
    required this.icon,
    required this.text,
    this.loading = false,
  });

  final IconData icon;
  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      if (loading)
        const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      else
        Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      const SizedBox(width: AppTheme.space),
      Expanded(child: Text(text)),
    ],
  );
}

String _dimensionLabel(ResearchDimension dimension) => switch (dimension) {
  ResearchDimension.valuation => 'Valuation',
  ResearchDimension.quality => 'Quality',
  ResearchDimension.growth => 'Growth',
  ResearchDimension.momentum => 'Momentum',
  ResearchDimension.dividend => 'Dividend',
  ResearchDimension.eventRisk => 'Event risk',
};
