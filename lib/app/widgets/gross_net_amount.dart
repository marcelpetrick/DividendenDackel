import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/tax/tax_estimates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gross and estimated-net labels for one held dividend.
class GrossNetAmount extends ConsumerWidget {
  /// Creates a label pair.
  const GrossNetAmount({required this.event, required this.gross, super.key});

  final DividendEvent event;
  final Money gross;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? year = event.paymentDate?.year;
    final AsyncValue<PortfolioTaxEstimates>? annual = year == null
        ? null
        : ref.watch(portfolioTaxEstimatesProvider(year));
    final TaxEventEstimate? estimate =
        annual?.value?.byEventKey[dividendTaxEventKey(event)];
    final String net = switch (estimate?.result) {
      DividendTaxBreakdown(:final Money net) => net.format(withSymbol: true),
      UnsupportedTaxCalculation(:final String explanation) => explanation,
      _ when year == null => 'Payment date needed for annual allowance order.',
      _ => 'Calculating…',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Gross ${gross.format(withSymbol: true)}'),
        Text('Net (estimated) $net'),
        Text(
          'Estimate—not tax advice.',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
