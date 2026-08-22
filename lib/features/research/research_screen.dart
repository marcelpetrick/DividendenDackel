import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Instrument research (Vision.md §15, §16).
///
/// Lists the instruments the app knows about; the research score and the detail
/// screen land with tasks T5 and T6.
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
          itemBuilder: (BuildContext context, int index) => ListTile(
            title: Text(list[index].name),
            subtitle: Text(list[index].displaySymbol),
            trailing: Text(
              list[index].sector ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        );
      },
    );
  }
}
