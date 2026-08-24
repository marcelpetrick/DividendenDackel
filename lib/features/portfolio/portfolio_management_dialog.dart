import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/portfolio/portfolio_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Creates, renames, clears and deletes local portfolio containers.
class PortfolioManagementDialog extends ConsumerStatefulWidget {
  /// Creates the management dialog.
  const PortfolioManagementDialog({super.key});

  @override
  ConsumerState<PortfolioManagementDialog> createState() =>
      _PortfolioManagementDialogState();
}

class _PortfolioManagementDialogState
    extends ConsumerState<PortfolioManagementDialog> {
  bool _working = false;
  String? _message;

  Future<String?> _askName({String initial = ''}) async {
    String current = initial;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(initial.isEmpty ? 'Create portfolio' : 'Rename portfolio'),
        content: TextFormField(
          key: const ValueKey<String>('portfolio-name'),
          initialValue: initial,
          autofocus: true,
          maxLength: 120,
          textInputAction: TextInputAction.done,
          onChanged: (String value) => current = value,
          onFieldSubmitted: (String value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(context).pop(value.trim());
            }
          },
          decoration: InputDecoration(labelText: context.tr('Portfolio name')),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final String value = current.trim();
              if (value.isNotEmpty) Navigator.of(context).pop(value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _create() async {
    final String? name = await _askName();
    if (name == null || !mounted) return;
    setState(() => _working = true);
    final DateTime now = ref.read(clockProvider).now().toUtc();
    late final List<InvestmentPortfolio> existing;
    try {
      existing = await ref
          .read(portfolioRepositoryProvider)
          .watchPortfolios()
          .first;
    } on Object {
      if (mounted) {
        setState(() {
          _working = false;
          _message = 'Portfolio list could not be read. Nothing was created.';
        });
      }
      return;
    }
    if (!mounted) return;
    final String baseId = 'portfolio-${now.microsecondsSinceEpoch}';
    final Set<String> ids = existing
        .map((InvestmentPortfolio portfolio) => portfolio.id)
        .toSet();
    String id = baseId;
    for (int suffix = 2; ids.contains(id); suffix++) {
      id = '$baseId-$suffix';
    }
    final result = await ref
        .read(portfolioRepositoryProvider)
        .savePortfolio(
          InvestmentPortfolio(
            id: id,
            name: name,
            createdAt: now,
            updatedAt: now,
          ),
        );
    if (!mounted) return;
    if (result.failureOrNull case final failure?) {
      setState(() {
        _working = false;
        _message = failure.message;
      });
      return;
    }
    await ref.read(portfolioSelectionProvider.notifier).select(id);
    if (mounted) setState(() => _working = false);
  }

  Future<void> _rename(InvestmentPortfolio portfolio) async {
    final String? name = await _askName(initial: portfolio.name);
    if (name == null || name == portfolio.name || !mounted) return;
    await _run(
      ref
          .read(portfolioRepositoryProvider)
          .savePortfolio(
            portfolio.copyWith(
              name: name,
              updatedAt: ref.read(clockProvider).now().toUtc(),
            ),
          ),
      success: 'Portfolio renamed.',
    );
  }

  Future<void> _clear(InvestmentPortfolio portfolio) async {
    final bool confirmed = await _confirm(
      title: 'Clear ${portfolio.name}?',
      message:
          'This permanently removes all holdings, watchlist entries and '
          'activity/import history in this portfolio. Market-data cache and '
          'the portfolio itself remain.',
      action: 'Clear portfolio',
    );
    if (!confirmed || !mounted) return;
    await _run(
      ref.read(portfolioRepositoryProvider).clearPortfolio(portfolio.id),
      success: 'Portfolio cleared.',
    );
  }

  Future<void> _delete(
    InvestmentPortfolio portfolio,
    List<InvestmentPortfolio> portfolios,
  ) async {
    final bool confirmed = await _confirm(
      title: 'Delete ${portfolio.name}?',
      message:
          'This permanently deletes the portfolio and all of its holdings, '
          'watchlist entries and activity/import history.',
      action: 'Delete portfolio',
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _working = true;
      _message = null;
    });
    final result = await ref
        .read(portfolioRepositoryProvider)
        .deletePortfolio(portfolio.id);
    if (!mounted) return;
    if (result.failureOrNull case final failure?) {
      setState(() {
        _working = false;
        _message = failure.message;
      });
      return;
    }
    if (ref.read(selectedPortfolioIdProvider) == portfolio.id) {
      final InvestmentPortfolio fallback = portfolios.firstWhere(
        (InvestmentPortfolio item) => item.id != portfolio.id,
      );
      await ref.read(portfolioSelectionProvider.notifier).select(fallback.id);
    }
    if (mounted) {
      setState(() {
        _working = false;
        _message = 'Portfolio deleted.';
      });
    }
  }

  Future<void> _run(
    Future<Result<void>> operation, {
    required String success,
  }) async {
    setState(() {
      _working = true;
      _message = null;
    });
    final Result<void> result = await operation;
    if (!mounted) return;
    setState(() {
      _working = false;
      _message = result.failureOrNull?.message ?? success;
    });
  }

  Future<bool> _confirm({
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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<InvestmentPortfolio>> portfoliosValue = ref.watch(
      portfoliosProvider,
    );
    return AlertDialog(
      title: const Text('Manage portfolios'),
      content: SizedBox(
        width: 620,
        height: (MediaQuery.sizeOf(context).height * 0.65).clamp(300, 520),
        child: portfoliosValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) =>
              const Center(child: Text('Portfolio list could not be loaded.')),
          data: (List<InvestmentPortfolio> portfolios) => ListView(
            children: <Widget>[
              const Text(
                'Each portfolio keeps its own holdings, watchlist and immutable '
                'activity history. Clearing or deleting is never automatic.',
              ),
              const SizedBox(height: AppTheme.space),
              for (final InvestmentPortfolio portfolio in portfolios)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: Text(portfolio.name, translate: false),
                    subtitle: Text(
                      portfolio.isDemo
                          ? 'Demo portfolio'
                          : 'Personal portfolio',
                    ),
                    trailing: Wrap(
                      spacing: AppTheme.space / 2,
                      children: <Widget>[
                        IconButton(
                          tooltip: context.tr('Rename ${portfolio.name}'),
                          onPressed: _working ? null : () => _rename(portfolio),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: context.tr('Clear ${portfolio.name}'),
                          onPressed: _working ? null : () => _clear(portfolio),
                          icon: const Icon(Icons.cleaning_services_outlined),
                        ),
                        IconButton(
                          tooltip: context.tr(
                            portfolios.length == 1
                                ? 'The final portfolio cannot be deleted'
                                : 'Delete ${portfolio.name}',
                          ),
                          onPressed: _working || portfolios.length == 1
                              ? null
                              : () => _delete(portfolio, portfolios),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_message case final String message) ...<Widget>[
                const SizedBox(height: AppTheme.space),
                Text(message),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        OutlinedButton.icon(
          key: const ValueKey<String>('create-portfolio'),
          onPressed: _working ? null : _create,
          icon: const Icon(Icons.add),
          label: const Text('New portfolio'),
        ),
        FilledButton(
          onPressed: _working ? null : () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
