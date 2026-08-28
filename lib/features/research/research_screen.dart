import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
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

        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(height: 1),
          itemBuilder: (BuildContext context, int index) {
            final Instrument instrument = list[index];
            return Semantics(
              button: true,
              label: context.trFormat(
                'Research {name}, {symbol}',
                <String, Object?>{
                  'name': instrument.name,
                  'symbol': instrument.displaySymbol,
                },
              ),
              hint: context.tr('Open research details'),
              child: ExcludeSemantics(
                child: ListTile(
                  title: Text(instrument.name, translate: false),
                  subtitle: Text(
                    <String>[
                      instrument.displaySymbol,
                      ?instrument.sector,
                    ].join(' · '),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    '/research/${Uri.encodeComponent(instrument.internalId)}',
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
