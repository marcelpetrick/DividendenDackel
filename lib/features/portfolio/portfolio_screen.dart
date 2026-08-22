import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The user's holdings (Vision.md §8.2).
class PortfolioScreen extends ConsumerWidget {
  /// Creates the portfolio screen.
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Holding>> holdings = ref.watch(holdingsProvider);
    final Map<String, Instrument> instruments =
        ref.watch(instrumentsByIdProvider).value ??
        const <String, Instrument>{};
    final Map<String, Quote> quotes =
        ref.watch(quotesProvider).value ?? const <String, Quote>{};

    return AsyncValueView<List<Holding>>(
      value: holdings,
      isEmpty: (List<Holding> data) => data.isEmpty,
      emptyTitle: 'No holdings yet',
      emptyMessage: 'Add an instrument to start tracking its dividends.',
      emptyIcon: Icons.pie_chart_outline,
      builder: (BuildContext context, List<Holding> data) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space),
        itemCount: data.length,
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final Holding holding = data[index];
          return _HoldingTile(
            holding: holding,
            instrument: instruments[holding.instrumentId],
            quote: quotes[holding.instrumentId],
          );
        },
      ),
    );
  }
}

class _HoldingTile extends StatelessWidget {
  const _HoldingTile({
    required this.holding,
    required this.instrument,
    required this.quote,
  });

  final Holding holding;
  final Instrument? instrument;
  final Quote? quote;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Quote? quote = this.quote;
    // A position without a cached quote still shows everything else, rather
    // than the whole row disappearing (Vision.md §7, §44).
    final Money? value = quote == null ? null : holding.valueAt(quote.price);
    final Money? gain = quote == null
        ? null
        : holding.unrealizedGainAt(quote.price);

    return ListTile(
      title: Text(instrument?.name ?? holding.instrumentId),
      subtitle: Text(
        '${holding.quantity} × '
                '${instrument?.displaySymbol ?? ''}'
            .trim(),
        style: theme.textTheme.bodySmall,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (value != null)
            MoneyText(value, style: theme.textTheme.titleMedium)
          else
            Text('No price yet', style: theme.textTheme.bodySmall),
          if (gain != null)
            MoneyText(
              gain,
              style: theme.textTheme.bodySmall,
              showSign: true,
              colorBySign: true,
            ),
        ],
      ),
    );
  }
}
