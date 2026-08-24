import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/app/widgets/gross_net_amount.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/currency/fx_state.dart';
import 'package:dividendendackel/features/portfolio/activity_dialog.dart';
import 'package:dividendendackel/features/portfolio/add_instrument_dialog.dart';
import 'package:dividendendackel/features/portfolio/holding_edit_dialog.dart';
import 'package:dividendendackel/features/portfolio/import_dialog.dart';
import 'package:dividendendackel/features/portfolio/performance_card.dart';
import 'package:dividendendackel/features/portfolio/performance_state.dart';
import 'package:dividendendackel/features/portfolio/portfolio_management_dialog.dart';
import 'package:dividendendackel/features/portfolio/portfolio_selection.dart';
import 'package:dividendendackel/features/settings/currency_settings.dart';
import 'package:dividendendackel/features/tax/tax_estimates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Portfolio value, income and collection management (Vision.md §8).
class PortfolioScreen extends ConsumerWidget {
  /// Creates the portfolio screen.
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<InvestmentPortfolio>> portfoliosValue = ref.watch(
      portfoliosProvider,
    );
    final List<InvestmentPortfolio> portfolios =
        portfoliosValue.value ?? const <InvestmentPortfolio>[];
    final String? portfolioId = ref.watch(effectivePortfolioIdProvider);
    final PortfolioSelectionState selection = ref.watch(
      portfolioSelectionProvider,
    );
    final AsyncValue<List<Holding>> holdings = ref.watch(holdingsProvider);
    final AsyncValue<List<WatchlistEntry>> watchlistValue = ref.watch(
      watchlistProvider,
    );
    final List<WatchlistEntry> watchlist =
        watchlistValue.value ?? const <WatchlistEntry>[];
    final AsyncValue<Map<String, Instrument>> instrumentsValue = ref.watch(
      instrumentsByIdProvider,
    );
    final Map<String, Instrument> instruments =
        instrumentsValue.value ?? const <String, Instrument>{};
    final AsyncValue<Map<String, Quote>> quotesValue = ref.watch(
      quotesProvider,
    );
    final Map<String, Quote> quotes =
        quotesValue.value ?? const <String, Quote>{};
    final AsyncValue<List<DividendEvent>> dividendData = ref.watch(
      upcomingDividendsProvider(365),
    );
    final List<DividendEvent> dividends =
        dividendData.value ?? const <DividendEvent>[];
    final DateTime now = ref.watch(clockProvider).now();
    final AsyncValue<List<PortfolioActivity>> activitiesValue = ref.watch(
      portfolioActivitiesProvider,
    );
    final List<PortfolioActivity> activities =
        activitiesValue.value ?? const <PortfolioActivity>[];
    final AsyncValue<List<PortfolioValuationSnapshot>> valuationsValue = ref
        .watch(portfolioValuationSnapshotsProvider);
    final List<PortfolioValuationSnapshot> valuations =
        valuationsValue.value ?? const <PortfolioValuationSnapshot>[];
    final AsyncValue<List<PortfolioImportBatch>> importBatchesValue = ref.watch(
      portfolioImportBatchesProvider,
    );
    final List<PortfolioImportBatch> importBatches =
        importBatchesValue.value ?? const <PortfolioImportBatch>[];
    final AsyncValue<List<DividendEvent>> yearPaymentsValue = ref.watch(
      dividendPaymentsForYearProvider(now.year),
    );
    final List<DividendReconciliationLine> reconciliation =
        DividendReconciliationCalculator.calculate(
          activities: activities,
          expectedEvents: yearPaymentsValue.value ?? const <DividendEvent>[],
          start: DateTime.utc(now.year),
          end: DateTime.utc(now.year + 1),
        );
    final Currency displayCurrency = ref
        .watch(displayCurrencyProvider)
        .currency;
    final FxRefreshState fxRefresh = ref.watch(fxRefreshProvider);
    final AsyncValue<PortfolioTaxEstimates> currentTax = ref.watch(
      portfolioTaxEstimatesProvider(now.year),
    );
    final AsyncValue<PortfolioTaxEstimates> nextTax = ref.watch(
      portfolioTaxEstimatesProvider(now.year + 1),
    );

    return Scaffold(
      body: AsyncValueView<List<Holding>>(
        value: holdings,
        onRetry: () => ref.invalidate(holdingsProvider),
        builder: (BuildContext context, List<Holding> data) {
          final PortfolioOverview overview = const PortfolioOverviewCalculator()
              .calculate(
                holdings: data,
                instruments: instruments,
                quotes: quotes,
                dividends: dividends,
                asOf: now,
              );
          final bool needsFx = overview.byCurrency.keys.any(
            (Currency currency) => currency != displayCurrency,
          );
          final AsyncValue<List<FxRate>>? fxRatesValue = needsFx
              ? ref.watch(cachedFxRatesProvider)
              : null;
          final List<FxRate> fxRates = needsFx
              ? fxRatesValue?.value ?? const <FxRate>[]
              : const <FxRate>[];
          final _TaxWindow taxWindow = _taxWindow(
            dividends,
            <AsyncValue<PortfolioTaxEstimates>>[currentTax, nextTax],
            <String>{for (final Holding holding in data) holding.instrumentId},
          );
          final FxRateBook rateBook = FxRateBook(fxRates);
          final PortfolioCurrencyExposure valueExposure =
              CurrencyExposureCalculator.calculate(
                nativeValues: <Currency, Money>{
                  for (final PortfolioCurrencySummary summary
                      in overview.byCurrency.values)
                    summary.currency: summary.totalValue,
                },
                displayCurrency: displayCurrency,
                rates: rateBook,
                asOf: now,
              );
          final PortfolioCurrencyExposure incomeExposure =
              CurrencyExposureCalculator.calculate(
                nativeValues: <Currency, Money>{
                  for (final PortfolioCurrencySummary summary
                      in overview.byCurrency.values)
                    summary.currency: summary.forecastAnnualDividend,
                },
                displayCurrency: displayCurrency,
                rates: rateBook,
                asOf: now,
              );
          final PortfolioHealth health = PortfolioHealthCalculator.calculate(
            overview: overview,
            displayCurrency: displayCurrency,
            rates: rateBook,
            asOf: now,
          );
          if (ref.watch(automaticPortfolioValuationEnabledProvider)) {
            unawaited(
              ref
                  .read(portfolioValuationRecorderProvider)
                  .record(
                    scopeId: portfolioId ?? InvestmentPortfolio.consolidatedId,
                    overview: overview,
                    activities: activities,
                    instrumentCurrencies: <String, Currency>{
                      for (final Instrument instrument in instruments.values)
                        instrument.internalId: instrument.currency,
                    },
                  ),
            );
          }
          return _PortfolioBody(
            portfolios: portfolios,
            portfolioId: portfolioId,
            selection: selection,
            overview: overview,
            watchlist: watchlist,
            instruments: instruments,
            dividendDataAvailable: dividendData.hasValue,
            taxWindow: taxWindow,
            valueExposure: valueExposure,
            incomeExposure: incomeExposure,
            health: health,
            activities: activities,
            valuations: valuations,
            asOf: now,
            importBatches: importBatches,
            reconciliation: reconciliation,
            onSelectPortfolio: (String? id) =>
                ref.read(portfolioSelectionProvider.notifier).select(id),
            onManagePortfolios: () => _showPortfolioManagement(context),
            onRecordActivity: portfolioId == null
                ? null
                : () => _showActivity(context, ref, portfolioId, instruments),
            onReverseActivity: portfolioId == null
                ? null
                : (int id) => _reverseActivity(context, ref, id),
            onImport: portfolioId == null
                ? null
                : () => _showImport(context, portfolioId),
            onUndoImport: (PortfolioImportBatch batch) =>
                _undoImport(context, ref, batch),
            onEditHolding: portfolioId == null
                ? null
                : (Holding holding) => _editHolding(
                    context,
                    holding,
                    instruments[holding.instrumentId],
                  ),
            onRemoveHolding: portfolioId == null
                ? null
                : (Holding holding) => _removeHolding(context, ref, holding),
            onRemoveWatchlist: portfolioId == null
                ? null
                : (WatchlistEntry entry) =>
                      _removeWatchlist(context, ref, entry),
            fxRefreshing: fxRefresh.isRefreshing,
            fxError: fxRefresh.errorMessage,
            refreshFx: () => ref.read(fxRefreshProvider.notifier).refresh(),
            pricesComplete: overview.byCurrency.values.every(
              (PortfolioCurrencySummary summary) => summary.isComplete,
            ),
            partialFailures: <String>[
              if (watchlistValue.hasError) 'Watchlist unavailable.',
              if (instrumentsValue.hasError)
                'Some instrument names are unavailable.',
              if (quotesValue.hasError)
                'Cached prices could not be read; values are unavailable.',
              if (dividendData.hasError)
                'Dividend income could not be read; it is unavailable.',
              if (activitiesValue.hasError)
                'Portfolio activities could not be read.',
              if (valuationsValue.hasError)
                'Historical portfolio valuations could not be read.',
              if (importBatchesValue.hasError)
                'Import history could not be read.',
              if (portfoliosValue.hasError)
                'Portfolio selection could not be read.',
              if (selection.errorMessage case final String message) message,
              if (yearPaymentsValue.hasError)
                'Expected payments could not be reconciled.',
              if (fxRatesValue?.hasError ?? false) 'Exchange rates could not be read; converted totals are unavailable.',
            ],
          );
        },
      ),
      floatingActionButton: portfolioId == null
          ? null
          : FloatingActionButton.extended(
              key: const ValueKey<String>('add-instrument'),
              onPressed: () => _showAddInstrument(context, portfolioId),
              icon: const Icon(Icons.add),
              label: const Text('Add instrument'),
            ),
    );
  }

  Future<void> _showAddInstrument(
    BuildContext context,
    String portfolioId,
  ) async {
    final String? message = await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          AddInstrumentDialog(portfolioId: portfolioId),
    );
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showActivity(
    BuildContext context,
    WidgetRef ref,
    String portfolioId,
    Map<String, Instrument> instruments,
  ) async {
    final String? message = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => PortfolioActivityDialog(
        portfolioId: portfolioId,
        instruments: instruments,
      ),
    );
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _showPortfolioManagement(BuildContext context) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => const PortfolioManagementDialog(),
      );

  Future<void> _editHolding(
    BuildContext context,
    Holding holding,
    Instrument? instrument,
  ) async {
    if (instrument == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Instrument metadata is unavailable.')),
      );
      return;
    }
    final String? message = await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          HoldingEditDialog(holding: holding, instrument: instrument),
    );
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _removeHolding(
    BuildContext context,
    WidgetRef ref,
    Holding holding,
  ) async {
    final bool confirmed = await _confirmRemoval(
      context,
      title: 'Remove holding?',
      message:
          'The current position will be removed and an auditable quantity '
          'adjustment will remain in the activity ledger.',
      action: 'Remove holding',
    );
    if (!confirmed || !context.mounted) return;
    final result = await ref
        .read(portfolioEditorProvider)
        .removeHolding(
          portfolioId: holding.portfolioId,
          instrumentId: holding.instrumentId,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'Holding removed.'),
        ),
      );
    }
  }

  Future<void> _removeWatchlist(
    BuildContext context,
    WidgetRef ref,
    WatchlistEntry entry,
  ) async {
    final bool confirmed = await _confirmRemoval(
      context,
      title: 'Remove watchlist entry?',
      message: 'The cached instrument and its market data will remain.',
      action: 'Remove',
    );
    if (!confirmed || !context.mounted) return;
    final result = await ref
        .read(portfolioEditorProvider)
        .removeFromWatchlist(
          portfolioId: entry.portfolioId,
          instrumentId: entry.instrumentId,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failureOrNull?.message ?? 'Watchlist entry removed.',
          ),
        ),
      );
    }
  }

  Future<bool> _confirmRemoval(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _showImport(BuildContext context, String portfolioId) async {
    final String? message = await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          PortfolioImportDialog(portfolioId: portfolioId),
    );
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _undoImport(
    BuildContext context,
    WidgetRef ref,
    PortfolioImportBatch batch,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Undo this import?'),
        content: const Text(
          'Reversal rows will be appended for every activity in the batch. '
          'The audit trail remains intact.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Undo import'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref
        .read(portfolioRepositoryProvider)
        .undoImportBatch(
          batch.portfolioId,
          batch.id,
          occurredAt: ref.read(clockProvider).now().toUtc(),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.failureOrNull?.message ??
                '${result.valueOrNull ?? 0} activities reversed.',
          ),
        ),
      );
    }
  }

  Future<void> _reverseActivity(
    BuildContext context,
    WidgetRef ref,
    int activityId,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Reverse activity?'),
        content: const Text(
          'The original row remains in the audit trail. A reversal will be '
          'added and its economic effect removed.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reverse'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref
        .read(portfolioRepositoryProvider)
        .reverseActivity(activityId, occurredAt: ref.read(clockProvider).now());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failureOrNull?.message ?? 'Activity reversed.'),
        ),
      );
    }
  }
}

class _PortfolioScopeCard extends StatelessWidget {
  const _PortfolioScopeCard({
    required this.portfolios,
    required this.portfolioId,
    required this.saving,
    required this.onSelect,
    required this.onManage,
  });

  final List<InvestmentPortfolio> portfolios;
  final String? portfolioId;
  final bool saving;
  final ValueChanged<String?> onSelect;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.space * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.account_balance_wallet_outlined),
              const SizedBox(width: AppTheme.space),
              Expanded(
                child: Text(
                  'Portfolio scope',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              OutlinedButton.icon(
                key: const ValueKey<String>('manage-portfolios'),
                onPressed: onManage,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Manage'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space),
          DropdownButtonFormField<String>(
            key: ValueKey<String>(
              'portfolio-selector-${portfolioId ?? InvestmentPortfolio.consolidatedId}',
            ),
            initialValue: portfolioId ?? InvestmentPortfolio.consolidatedId,
            isExpanded: true,
            decoration: InputDecoration(labelText: context.tr('Showing')),
            items: <DropdownMenuItem<String>>[
              for (final InvestmentPortfolio portfolio in portfolios)
                DropdownMenuItem<String>(
                  value: portfolio.id,
                  child: Text(
                    portfolio.name,
                    translate: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const DropdownMenuItem<String>(
                value: InvestmentPortfolio.consolidatedId,
                child: Text(
                  'All portfolios (consolidated)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            onChanged: saving
                ? null
                : (String? id) => onSelect(
                    id == InvestmentPortfolio.consolidatedId ? null : id,
                  ),
          ),
          if (portfolioId == null) ...<Widget>[
            const SizedBox(height: AppTheme.space),
            const Text(
              'Consolidated is a read-only combined view. Select one portfolio '
              'to add, edit, remove, record or import data. Tax estimates are '
              'not combined across portfolio boundaries.',
            ),
          ],
        ],
      ),
    ),
  );
}

class _PortfolioBody extends StatelessWidget {
  const _PortfolioBody({
    required this.portfolios,
    required this.portfolioId,
    required this.selection,
    required this.overview,
    required this.watchlist,
    required this.instruments,
    required this.dividendDataAvailable,
    required this.taxWindow,
    required this.valueExposure,
    required this.incomeExposure,
    required this.health,
    required this.activities,
    required this.valuations,
    required this.asOf,
    required this.importBatches,
    required this.reconciliation,
    required this.onSelectPortfolio,
    required this.onManagePortfolios,
    required this.onRecordActivity,
    required this.onReverseActivity,
    required this.onImport,
    required this.onUndoImport,
    required this.onEditHolding,
    required this.onRemoveHolding,
    required this.onRemoveWatchlist,
    required this.fxRefreshing,
    required this.fxError,
    required this.refreshFx,
    required this.pricesComplete,
    required this.partialFailures,
  });

  final List<InvestmentPortfolio> portfolios;
  final String? portfolioId;
  final PortfolioSelectionState selection;
  final PortfolioOverview overview;
  final List<WatchlistEntry> watchlist;
  final Map<String, Instrument> instruments;
  final bool dividendDataAvailable;
  final _TaxWindow taxWindow;
  final PortfolioCurrencyExposure valueExposure;
  final PortfolioCurrencyExposure incomeExposure;
  final PortfolioHealth health;
  final List<PortfolioActivity> activities;
  final List<PortfolioValuationSnapshot> valuations;
  final DateTime asOf;
  final List<PortfolioImportBatch> importBatches;
  final List<DividendReconciliationLine> reconciliation;
  final ValueChanged<String?> onSelectPortfolio;
  final VoidCallback onManagePortfolios;
  final VoidCallback? onRecordActivity;
  final ValueChanged<int>? onReverseActivity;
  final VoidCallback? onImport;
  final ValueChanged<PortfolioImportBatch> onUndoImport;
  final ValueChanged<Holding>? onEditHolding;
  final ValueChanged<Holding>? onRemoveHolding;
  final ValueChanged<WatchlistEntry>? onRemoveWatchlist;
  final bool fxRefreshing;
  final String? fxError;
  final VoidCallback refreshFx;
  final bool pricesComplete;
  final List<String> partialFailures;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(
      AppTheme.space * 2,
      AppTheme.space * 2,
      AppTheme.space * 2,
      AppTheme.space * 10,
    ),
    children: <Widget>[
      _PortfolioScopeCard(
        portfolios: portfolios,
        portfolioId: portfolioId,
        saving: selection.isSaving,
        onSelect: onSelectPortfolio,
        onManage: onManagePortfolios,
      ),
      const SizedBox(height: AppTheme.space * 2),
      if (partialFailures.isNotEmpty) ...<Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Some saved data is unavailable'),
            subtitle: Text(partialFailures.join(' ')),
          ),
        ),
        const SizedBox(height: AppTheme.space),
      ],
      Text('Overview', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppTheme.space),
      if (overview.byCurrency.isEmpty)
        const _EmptyPortfolioCard()
      else
        Wrap(
          spacing: AppTheme.space,
          runSpacing: AppTheme.space,
          children: <Widget>[
            for (final PortfolioCurrencySummary summary
                in overview.byCurrency.values)
              _CurrencySummaryCard(
                summary: summary,
                dividendDataAvailable: dividendDataAvailable,
                taxWindow: taxWindow,
                taxBoundaryAvailable: portfolioId != null,
              ),
          ],
        ),
      if (overview.byCurrency.isNotEmpty) ...<Widget>[
        const SizedBox(height: AppTheme.space),
        _DisplayCurrencyCard(
          values: valueExposure,
          income: incomeExposure,
          refreshing: fxRefreshing,
          errorMessage: fxError,
          onRefresh: refreshFx,
          pricesComplete: pricesComplete,
          dividendDataAvailable: dividendDataAvailable,
        ),
      ],
      const SizedBox(height: AppTheme.space * 2),
      Text('Holdings', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppTheme.space),
      if (overview.positions.isEmpty)
        Text(
          'No holdings yet. Add an instrument to start tracking its value and dividends.',
          style: Theme.of(context).textTheme.bodyMedium,
        )
      else
        for (final PortfolioPositionSummary position in overview.positions)
          _PositionCard(
            position: position,
            dividendDataAvailable: dividendDataAvailable,
            portfolioValue: position.value == null
                ? null
                : overview.byCurrency[position.value!.currency]?.totalValue,
            onEdit: onEditHolding == null
                ? null
                : () => onEditHolding!(position.holding),
            onRemove: onRemoveHolding == null
                ? null
                : () => onRemoveHolding!(position.holding),
          ),
      if (overview.positions.isNotEmpty) ...<Widget>[
        const SizedBox(height: AppTheme.space * 2),
        _PortfolioHealthCard(health: health),
      ],
      const SizedBox(height: AppTheme.space * 2),
      Text('Watchlist', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppTheme.space),
      if (watchlist.isEmpty)
        Text(
          'No watchlist entries yet.',
          style: Theme.of(context).textTheme.bodyMedium,
        )
      else
        Card(
          child: Column(
            children: <Widget>[
              for (final WatchlistEntry entry in watchlist)
                ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: Text(
                    instruments[entry.instrumentId]?.name ?? entry.instrumentId,
                  ),
                  subtitle: Text(
                    instruments[entry.instrumentId]?.displaySymbol ??
                        'Instrument metadata unavailable',
                  ),
                  trailing: onRemoveWatchlist == null
                      ? null
                      : IconButton(
                          tooltip: context.tr('Remove from watchlist'),
                          onPressed: () => onRemoveWatchlist!(entry),
                          icon: const Icon(Icons.bookmark_remove_outlined),
                        ),
                ),
            ],
          ),
        ),
      const SizedBox(height: AppTheme.space * 2),
      _ActivityLedgerCard(
        activities: activities,
        importBatches: importBatches,
        instruments: instruments,
        portfolioNames: <String, String>{
          for (final InvestmentPortfolio portfolio in portfolios)
            portfolio.id: portfolio.name,
        },
        showPortfolio: portfolioId == null,
        reconciliation: reconciliation,
        onRecord: onRecordActivity,
        onReverse: onReverseActivity,
        onImport: onImport,
        onUndoImport: onUndoImport,
      ),
      const SizedBox(height: AppTheme.space * 2),
      PortfolioPerformanceCard(
        activities: activities,
        scopeId: portfolioId ?? InvestmentPortfolio.consolidatedId,
        valuations: valuations,
        overview: overview,
        instruments: instruments,
        asOf: asOf,
      ),
    ],
  );
}

class _ActivityLedgerCard extends StatelessWidget {
  const _ActivityLedgerCard({
    required this.activities,
    required this.importBatches,
    required this.instruments,
    required this.portfolioNames,
    required this.showPortfolio,
    required this.reconciliation,
    required this.onRecord,
    required this.onReverse,
    required this.onImport,
    required this.onUndoImport,
  });

  final List<PortfolioActivity> activities;
  final List<PortfolioImportBatch> importBatches;
  final Map<String, Instrument> instruments;
  final Map<String, String> portfolioNames;
  final bool showPortfolio;
  final List<DividendReconciliationLine> reconciliation;
  final VoidCallback? onRecord;
  final ValueChanged<int>? onReverse;
  final VoidCallback? onImport;
  final ValueChanged<PortfolioImportBatch> onUndoImport;

  @override
  Widget build(BuildContext context) {
    final Set<int> reversed = activities
        .where(
          (PortfolioActivity item) =>
              item.type == PortfolioActivityType.reversal,
        )
        .map((PortfolioActivity item) => item.reversesActivityId!)
        .toSet();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.receipt_long_outlined),
                const SizedBox(width: AppTheme.space),
                Expanded(
                  child: Text(
                    'Activity ledger',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space),
            Wrap(
              spacing: AppTheme.space / 2,
              runSpacing: AppTheme.space / 2,
              children: <Widget>[
                OutlinedButton.icon(
                  key: const ValueKey<String>('import-activities'),
                  onPressed: onImport,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Import CSV'),
                ),
                FilledButton.tonalIcon(
                  onPressed: onRecord,
                  icon: const Icon(Icons.add),
                  label: const Text('Record'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space / 2),
            const Text(
              'Purchases, sales and actual cash flows stay on this device. '
              'Corrections append reversals; history is never silently rewritten.',
            ),
            if (importBatches.isNotEmpty) ...<Widget>[
              const Divider(height: AppTheme.space * 3),
              Text(
                'Import history',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final PortfolioImportBatch batch in importBatches.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    batch.isUndone
                        ? Icons.history_toggle_off
                        : Icons.file_download_done_outlined,
                  ),
                  title: Text('${batch.activityCount} activities'),
                  subtitle: Text(
                    '${_importSource(batch.source)} · '
                    '${MaterialLocalizations.of(context).formatMediumDate(batch.importedAt)}'
                    '${batch.isUndone ? ' · Undone' : ''}',
                  ),
                  trailing: batch.isUndone
                      ? null
                      : TextButton(
                          onPressed: () => onUndoImport(batch),
                          child: const Text('Undo'),
                        ),
                ),
            ],
            if (reconciliation.isNotEmpty) ...<Widget>[
              const Divider(height: AppTheme.space * 3),
              Text(
                'Expected vs actually recorded this year',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.space / 2),
              const Text(
                'Expected is gross provider data using the shares held on each '
                'payment date. Actual is gross dividend cash entered or imported.',
              ),
              for (final DividendReconciliationLine line in reconciliation)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(line.currency.code),
                  subtitle: Text(
                    'Expected ${line.expectedGross.format()} · '
                    'Actual ${line.actualGross.format()}',
                  ),
                  trailing: Text(
                    line.variance.amount.sign >= 0
                        ? '+${line.variance.format()}'
                        : line.variance.format(),
                  ),
                ),
            ],
            const Divider(height: AppTheme.space * 3),
            if (activities.isEmpty)
              const Text('No activities recorded yet.')
            else
              for (final PortfolioActivity activity in activities.take(12))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(_activityIcon(activity.type)),
                  title: Text(_activityTitle(activity, instruments)),
                  subtitle: Text(
                    <String>[
                      MaterialLocalizations.of(context)
                          .formatMediumDate(activity.occurredAt),
                      if (showPortfolio)
                        portfolioNames[activity.portfolioId] ??
                            activity.portfolioId,
                    ].join(' · '),
                  ),
                  trailing:
                      onReverse != null &&
                          activity.id != null &&
                          activity.type != PortfolioActivityType.reversal &&
                          !reversed.contains(activity.id)
                      ? IconButton(
                          tooltip: context.tr('Reverse activity'),
                          onPressed: () => onReverse!(activity.id!),
                          icon: const Icon(Icons.undo),
                        )
                      : null,
                ),
          ],
        ),
      ),
    );
  }

  static String _activityTitle(
    PortfolioActivity activity,
    Map<String, Instrument> instruments,
  ) {
    final String label = switch (activity.type) {
      PortfolioActivityType.openingBalance => 'Opening balance',
      PortfolioActivityType.purchase => 'Purchase',
      PortfolioActivityType.sale => 'Sale',
      PortfolioActivityType.deposit => 'Deposit',
      PortfolioActivityType.withdrawal => 'Withdrawal',
      PortfolioActivityType.dividend => 'Dividend received',
      PortfolioActivityType.tax => 'Tax',
      PortfolioActivityType.fee => 'Fee',
      PortfolioActivityType.holdingAdjustment => 'Holding adjustment',
      PortfolioActivityType.reversal => 'Reversal',
    };
    final String? symbol = activity.instrumentId == null
        ? null
        : instruments[activity.instrumentId]?.displaySymbol;
    final String value =
        activity.cashAmount?.format() ??
        (activity.quantity == null ? '' : '${activity.quantity} shares');
    return <String>[label, ?symbol, if (value.isNotEmpty) value].join(' · ');
  }

  static IconData _activityIcon(PortfolioActivityType type) => switch (type) {
    PortfolioActivityType.purchase ||
    PortfolioActivityType.openingBalance => Icons.add_chart,
    PortfolioActivityType.sale => Icons.sell_outlined,
    PortfolioActivityType.deposit => Icons.south_west,
    PortfolioActivityType.withdrawal => Icons.north_east,
    PortfolioActivityType.dividend => Icons.payments_outlined,
    PortfolioActivityType.tax ||
    PortfolioActivityType.fee => Icons.remove_circle_outline,
    PortfolioActivityType.holdingAdjustment => Icons.tune,
    PortfolioActivityType.reversal => Icons.undo,
  };

  static String _importSource(String source) => switch (source) {
    'import:portfolio-performance-csv' => 'Portfolio Performance CSV',
    'import:dividendendackel-csv' => 'DividendenDackel CSV',
    'import:interactive-brokers-flex-csv' => 'Interactive Brokers Flex CSV',
    _ => 'Local CSV',
  };
}

class _PortfolioHealthCard extends StatelessWidget {
  const _PortfolioHealthCard({required this.health});

  final PortfolioHealth health;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.health_and_safety_outlined),
                const SizedBox(width: AppTheme.space),
                Expanded(
                  child: Text(
                    'Portfolio health',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space / 2),
            Text(
              'Concentration context—not a rating or investment advice. '
              'Shares use cached values converted to '
              '${health.displayCurrency.code}.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.space),
            Text(
              'Value coverage: ${health.pricedPositionCount} of '
              '${health.positionCount} holdings',
            ),
            if (!health.valueCoverageComplete ||
                health.missingValueCurrencies.isNotEmpty)
              Text(
                'Unpriced holdings and currencies without a dated FX rate are '
                'excluded, not treated as zero.',
                style: theme.textTheme.bodySmall,
              ),
            if (health.missingIncomeCurrencies.isNotEmpty)
              Text(
                'Dividend income in ${health.missingIncomeCurrencies.map((Currency item) => item.code).join(', ')} is excluded because no dated FX rate is cached.',
                style: theme.textTheme.bodySmall,
              ),
            if (health.positions.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: AppTheme.space),
                child: Text(
                  'Cached quotes are needed before value concentration can be '
                  'calculated.',
                ),
              )
            else ...<Widget>[
              const Divider(height: AppTheme.space * 3),
              if (health.topFiveShare case final Percentage share)
                Text(
                  'Top ${health.positions.length.clamp(0, 5)} positions: '
                  '${share.format()} of covered value',
                  style: theme.textTheme.titleSmall,
                ),
              const SizedBox(height: AppTheme.space),
              for (final String insight in health.insights)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.space / 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.info_outline, size: 18),
                      const SizedBox(width: AppTheme.space / 2),
                      Expanded(child: Text(insight)),
                    ],
                  ),
                ),
              const SizedBox(height: AppTheme.space),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double width = constraints.maxWidth < 760
                      ? constraints.maxWidth
                      : (constraints.maxWidth - AppTheme.space * 2) / 3;
                  return Wrap(
                    spacing: AppTheme.space,
                    runSpacing: AppTheme.space,
                    children: <Widget>[
                      SizedBox(
                        width: width,
                        child: _ExposureList(
                          title: 'Positions',
                          values: health.positions,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ExposureList(
                          title: 'Sectors',
                          values: health.sectors,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ExposureList(
                          title: 'Countries',
                          values: health.countries,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ExposureList(
                          title: 'Currencies',
                          values: health.currencies,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: _ExposureList(
                          title: 'Expected dividend income',
                          values: health.dividendIncome,
                          emptyMessage: 'No dated dividend income available.',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExposureList extends StatelessWidget {
  const _ExposureList({
    required this.title,
    required this.values,
    this.emptyMessage = 'No covered values.',
  });

  final String title;
  final List<PortfolioHealthSlice> values;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(title, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: AppTheme.space / 2),
      if (values.isEmpty)
        Text(emptyMessage)
      else
        for (final PortfolioHealthSlice slice in values.take(5))
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.space / 2),
            child: Semantics(
              label: context.tr('${slice.label}, ${slice.share.format()}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          slice.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space),
                      Text(slice.share.format()),
                    ],
                  ),
                  LinearProgressIndicator(value: slice.share.rate.toDouble()),
                ],
              ),
            ),
          ),
    ],
  );
}

class _DisplayCurrencyCard extends StatelessWidget {
  const _DisplayCurrencyCard({
    required this.values,
    required this.income,
    required this.refreshing,
    required this.errorMessage,
    required this.onRefresh,
    required this.pricesComplete,
    required this.dividendDataAvailable,
  });
  final PortfolioCurrencyExposure values;
  final PortfolioCurrencyExposure income;
  final bool refreshing;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final bool pricesComplete;
  final bool dividendDataAvailable;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Set<Currency> missing = <Currency>{
      ...values.missingCurrencies,
      ...income.missingCurrencies,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${values.displayCurrency.code} display view',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: context.tr('Refresh ECB exchange rates'),
                  onPressed: refreshing ? null : onRefresh,
                  icon: refreshing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                ),
              ],
            ),
            _SummaryRow(
              label: 'Converted portfolio value',
              value: MoneyText(values.total, style: theme.textTheme.titleLarge),
            ),
            _SummaryRow(
              label: 'Next 365 days gross',
              value: dividendDataAvailable
                  ? MoneyText(income.total, style: theme.textTheme.titleMedium)
                  : const Text('Loading…'),
            ),
            if (!pricesComplete)
              Text(
                'Converted value is partial because at least one holding has '
                'no cached quote.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            if (missing.isNotEmpty)
              Text(
                'Incomplete: no dated EUR reference rate for '
                '${missing.map((Currency item) => item.code).join(', ')}.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            if (errorMessage != null)
              Text(
                'Refresh failed: $errorMessage Cached values remain visible.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            const Divider(height: AppTheme.space * 2),
            Text('Currency exposure', style: theme.textTheme.titleSmall),
            const SizedBox(height: AppTheme.space / 2),
            for (final CurrencyExposureSlice slice in values.slices)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.space / 2),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 46, child: Text(slice.nativeCurrency.code)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: double.parse(slice.share.rate.toString()),
                        semanticsLabel: context.tr(
                          '${slice.nativeCurrency.code} ${slice.share.format()}',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space),
                    Text(slice.share.format()),
                  ],
                ),
              ),
            for (final CurrencyExposureSlice slice in values.slices.where(
              (item) => item.conversion.rates.isNotEmpty,
            ))
              Text(
                '${slice.nativeCurrency.code}: '
                '${slice.conversion.rates.map((FxRate rate) => '${rate.base.code}/${rate.quote.code} ${rate.rate} · ${rate.provenance.source} · ${_date(rate.observedAt)}').join(' via ')}'
                '${slice.conversion.isStale ? ' · stale' : ''}',
                style: theme.textTheme.labelSmall,
              ),
            Text(
              'Native totals remain above. Converted figures use exact cached '
              'daily rates and are rounded only for display.',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

class _EmptyPortfolioCard extends StatelessWidget {
  const _EmptyPortfolioCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(AppTheme.space * 2),
      child: Row(
        children: <Widget>[
          Icon(Icons.pie_chart_outline),
          SizedBox(width: AppTheme.space),
          Expanded(
            child: Text(
              'Add a holding to see portfolio value, day change, allocation, yield and the next dividend.',
            ),
          ),
        ],
      ),
    ),
  );
}

class _CurrencySummaryCard extends StatelessWidget {
  const _CurrencySummaryCard({
    required this.summary,
    required this.dividendDataAvailable,
    required this.taxWindow,
    required this.taxBoundaryAvailable,
  });

  final PortfolioCurrencySummary summary;
  final bool dividendDataAvailable;
  final _TaxWindow taxWindow;
  final bool taxBoundaryAvailable;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: 310,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.space * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${summary.currency.code} portfolio',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.space),
              if (summary.pricedPositionCount == 0)
                Text('No priced value', style: theme.textTheme.headlineSmall)
              else
                MoneyText(
                  summary.totalValue,
                  style: theme.textTheme.headlineSmall,
                ),
              Text(
                summary.isComplete
                    ? '${summary.positionCount} priced holdings'
                    : '${summary.pricedPositionCount} of '
                          '${summary.positionCount} holdings priced',
                style: theme.textTheme.labelSmall,
              ),
              const Divider(height: AppTheme.space * 2),
              _SummaryRow(
                label: 'Day change',
                value: summary.dayChange == null
                    ? const Text('Not available')
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          MoneyText(
                            summary.dayChange!,
                            showSign: true,
                            colorBySign: true,
                          ),
                          if (summary.dayChangePercent != null)
                            Text(
                              ' · ${summary.dayChangePercent!.format(withSign: true)}',
                            ),
                        ],
                      ),
              ),
              _SummaryRow(
                label: 'Next 365 days',
                value: dividendDataAvailable
                    ? MoneyText(summary.forecastAnnualDividend)
                    : const Text('Loading…'),
              ),
              _SummaryRow(
                label: 'Net (estimated)',
                value: !taxBoundaryAvailable
                    ? const Text('Select one portfolio')
                    : !dividendDataAvailable || taxWindow.loading
                    ? const Text('Calculating…')
                    : summary.currency != Currency.eur
                    ? const Text('Needs dated EUR FX')
                    : Text(
                        '${taxWindow.netEur.format(withSymbol: true)}'
                        '${taxWindow.unsupportedCount == 0 ? '' : ' + ${taxWindow.unsupportedCount} unavailable'}',
                      ),
              ),
              _SummaryRow(
                label: 'Forward gross yield',
                value: Text(
                  dividendDataAvailable
                      ? summary.forwardYield?.format() ?? 'Not available'
                      : 'Loading…',
                ),
              ),
              Text(
                'Estimate—not tax advice.',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      final bool stack =
          constraints.maxWidth < 360 ||
          MediaQuery.textScalerOf(context).scale(16) >= 24;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.space / 2),
        child: stack
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(label),
                  const SizedBox(height: AppTheme.space / 4),
                  Align(alignment: Alignment.centerRight, child: value),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Text(label)),
                  const SizedBox(width: AppTheme.space),
                  Flexible(child: value),
                ],
              ),
      );
    },
  );
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({
    required this.position,
    required this.dividendDataAvailable,
    required this.portfolioValue,
    required this.onEdit,
    required this.onRemove,
  });

  final PortfolioPositionSummary position;
  final bool dividendDataAvailable;
  final Money? portfolioValue;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Instrument? instrument = position.instrument;
    final PositionDividend? next = position.nextDividend;
    return Card(
      key: ValueKey<String>('holding-${position.holding.instrumentId}'),
      margin: const EdgeInsets.only(bottom: AppTheme.space),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space * 1.5),
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
                        instrument?.name ?? position.holding.instrumentId,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        '${instrument?.displaySymbol ?? ''} · '
                        '${position.holding.quantity} shares',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (position.value != null)
                  MoneyText(position.value!, style: theme.textTheme.titleMedium)
                else
                  const Text('No price yet'),
              ],
            ),
            const SizedBox(height: AppTheme.space),
            Wrap(
              spacing: AppTheme.space * 2,
              runSpacing: AppTheme.space / 2,
              children: <Widget>[
                _TextMetric(
                  label: 'Day change',
                  value: position.dayChange == null
                      ? 'Not available'
                      : '${position.dayChange!.format(withSymbol: true)} '
                            '(${position.dayChangePercent?.format(withSign: true) ?? '—'})',
                ),
                _TextMetric(
                  label:
                      'Allocation in ${instrument?.currency.code ?? 'currency'}',
                  value: position.allocation?.format() ?? 'Not available',
                ),
                _TextMetric(
                  label: 'Forward gross yield',
                  value: dividendDataAvailable
                      ? position.forwardYield?.format() ?? 'Not available'
                      : 'Loading…',
                ),
              ],
            ),
            if (_canSimulate || onEdit != null || onRemove != null) ...<Widget>[
              const SizedBox(height: AppTheme.space),
              Wrap(
                spacing: AppTheme.space / 2,
                runSpacing: AppTheme.space / 2,
                children: <Widget>[
                  if (_canSimulate)
                    OutlinedButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (BuildContext context) => _SimulationDialog(
                          position: position,
                          portfolioValue: portfolioValue!,
                        ),
                      ),
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Simulate investment'),
                    ),
                  if (onEdit != null)
                    OutlinedButton.icon(
                      key: ValueKey<String>(
                        'edit-holding-${position.holding.instrumentId}',
                      ),
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                  if (onRemove != null)
                    TextButton.icon(
                      key: ValueKey<String>(
                        'remove-holding-${position.holding.instrumentId}',
                      ),
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                    ),
                ],
              ),
            ],
            const Divider(height: AppTheme.space * 2),
            if (!dividendDataAvailable)
              Text('Loading dividend data…', style: theme.textTheme.bodySmall)
            else if (next == null)
              Text(
                'Next dividend not known yet.',
                style: theme.textTheme.bodySmall,
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: AppTheme.space / 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Next dividend ${_date(context, next.event)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        GrossNetAmount(
                          event: next.event,
                          gross: next.grossAmount,
                        ),
                      ],
                    ),
                  ),
                  DividendStatusChip(next.event.status),
                ],
              ),
          ],
        ),
      ),
    );
  }

  bool get _canSimulate =>
      dividendDataAvailable &&
      position.quote?.price.isPositive == true &&
      position.value != null &&
      portfolioValue != null &&
      position.forecastAnnualDividend != null &&
      position.holding.quantity > Decimal.zero;

  static String _date(BuildContext context, DividendEvent event) {
    final DateTime date = event.paymentDate ?? event.exDate!;
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }
}

class _SimulationDialog extends StatefulWidget {
  const _SimulationDialog({
    required this.position,
    required this.portfolioValue,
  });

  final PortfolioPositionSummary position;
  final Money portfolioValue;

  @override
  State<_SimulationDialog> createState() => _SimulationDialogState();
}

class _SimulationDialogState extends State<_SimulationDialog> {
  late final TextEditingController _investment = TextEditingController(
    text: '1000',
  );

  @override
  void dispose() {
    _investment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PortfolioPositionSummary position = widget.position;
    final Money price = position.quote!.price;
    final Money annualPerShare = position.forecastAnnualDividend!.dividedBy(
      position.holding.quantity,
    );
    final Decimal? amount = Decimal.tryParse(_investment.text.trim());
    DividendSimulation? simulation;
    if (amount != null && amount > Decimal.zero) {
      simulation = DividendSimulator.calculate(
        additionalInvestment: Money(amount, price.currency),
        sharePrice: price,
        existingQuantity: position.holding.quantity,
        existingPositionValue: position.value!,
        portfolioValue: widget.portfolioValue,
        annualDividendPerShare: annualPerShare,
      );
    }
    final Instrument? instrument = position.instrument;
    return AlertDialog(
      title: Text('Simulate ${instrument?.name ?? 'investment'}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                key: const ValueKey<String>('simulation-investment'),
                controller: _investment,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.tr(
                    'Additional investment (${price.currency.code})',
                  ),
                  border: const OutlineInputBorder(),
                  errorText: amount == null || amount <= Decimal.zero
                      ? context.tr('Enter an amount greater than zero.')
                      : null,
                ),
                onChanged: (String value) => setState(() {}),
              ),
              const SizedBox(height: AppTheme.space * 2),
              Text(
                'Basis: cached price ${price.format(withSymbol: true)} and '
                'next-365-day gross dividends of '
                '${annualPerShare.format(withSymbol: true)} per current share.',
              ),
              const SizedBox(height: AppTheme.space * 2),
              if (simulation case final DividendSimulation value) ...<Widget>[
                _SimulationRow(
                  label: 'Additional fractional shares',
                  value: value.additionalShares
                      .round(scale: 4)
                      .toStringAsFixed(4),
                ),
                _SimulationRow(
                  label: 'Added annual gross dividend',
                  value: value.additionalAnnualDividend.format(
                    withSymbol: true,
                  ),
                ),
                _SimulationRow(
                  label: 'Average added gross per month',
                  value: value.averageMonthlyDividend.format(withSymbol: true),
                ),
                _SimulationRow(
                  label: 'New weight in ${price.currency.code} holdings',
                  value:
                      '${value.previousWeight.format()} → '
                      '${value.newWeight.format()} '
                      '(${value.weightChange.format(withSign: true)} points)',
                ),
                _SimulationRow(
                  label: 'New forward gross yield',
                  value: value.newForwardYield.format(),
                ),
              ],
              const SizedBox(height: AppTheme.space),
              Text(
                'Scenario only—not a recommendation. Fractional shares are '
                'shown; broker rules, fees, taxes, price movement and dividend '
                'changes are not modelled.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _SimulationRow extends StatelessWidget {
  const _SimulationRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppTheme.space),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(label)),
        const SizedBox(width: AppTheme.space),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    ),
  );
}

final class _TaxWindow {
  const _TaxWindow({
    required this.loading,
    required this.netEur,
    required this.unsupportedCount,
  });
  final bool loading;
  final Money netEur;
  final int unsupportedCount;
}

_TaxWindow _taxWindow(
  Iterable<DividendEvent> events,
  Iterable<AsyncValue<PortfolioTaxEstimates>> annualValues,
  Set<String> heldInstrumentIds,
) {
  final bool loading = annualValues.any((value) => !value.hasValue);
  final Map<String, TaxEventEstimate> estimates = <String, TaxEventEstimate>{
    for (final AsyncValue<PortfolioTaxEstimates> annual in annualValues)
      if (annual.value case final value?) ...value.byEventKey,
  };
  Money net = Money.zero(Currency.eur);
  int unsupported = 0;
  for (final DividendEvent event in events) {
    if (!heldInstrumentIds.contains(event.instrumentId)) continue;
    switch (estimates[dividendTaxEventKey(event)]?.result) {
      case DividendTaxBreakdown(net: final Money payment):
        net += payment;
      case UnsupportedTaxCalculation():
        unsupported++;
      case null:
        if (!loading) unsupported++;
    }
  }
  return _TaxWindow(
    loading: loading,
    netEur: net,
    unsupportedCount: unsupported,
  );
}

class _TextMetric extends StatelessWidget {
  const _TextMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      Text(value, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}
