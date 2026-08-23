import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/portfolio/portfolio_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search and add flow shared by Android and Linux portfolio screens.
class AddInstrumentDialog extends ConsumerStatefulWidget {
  /// Creates the flow.
  const AddInstrumentDialog({required this.portfolioId, super.key});

  /// Portfolio receiving the holding or watchlist entry.
  final String portfolioId;

  @override
  ConsumerState<AddInstrumentDialog> createState() =>
      _AddInstrumentDialogState();
}

class _AddInstrumentDialogState extends ConsumerState<AddInstrumentDialog> {
  final TextEditingController _query = TextEditingController();
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _averagePrice = TextEditingController();
  List<Instrument> _results = const <Instrument>[];
  Instrument? _selected;
  String? _message;
  bool _searching = false;
  bool _saving = false;

  @override
  void dispose() {
    _query.dispose();
    _quantity.dispose();
    _averagePrice.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_query.text.trim().isEmpty || _searching) {
      setState(() => _message = 'Enter a symbol, company name or ISIN.');
      return;
    }
    setState(() {
      _searching = true;
      _message = null;
      _results = const <Instrument>[];
    });
    final Result<InstrumentSearchOutcome> result = await ref
        .read(portfolioEditorProvider)
        .search(_query.text);
    if (!mounted) {
      return;
    }
    final InstrumentSearchOutcome? outcome = result.valueOrNull;
    setState(() {
      _searching = false;
      _results = outcome?.instruments ?? const <Instrument>[];
      _message = result.failureOrNull?.message ?? outcome?.warning?.message;
      if (_results.isEmpty && _message == null) {
        _message = 'No matching instrument found.';
      }
    });
  }

  Future<void> _addHolding() async {
    final Instrument selected = _selected!;
    Decimal quantity;
    Money? averagePrice;
    try {
      quantity = Decimal.parse(_quantity.text.trim());
      final String price = _averagePrice.text.trim();
      if (price.isNotEmpty) {
        averagePrice = Money.parse(price, selected.currency);
      }
    } on FormatException {
      setState(() => _message = 'Enter valid decimal numbers.');
      return;
    }
    await _save(
      () => ref
          .read(portfolioEditorProvider)
          .addHolding(
            portfolioId: widget.portfolioId,
            instrument: selected,
            quantity: quantity,
            averagePurchasePrice: averagePrice,
          ),
      '${selected.name} added to the portfolio.',
    );
  }

  Future<void> _addToWatchlist() async {
    final Instrument selected = _selected!;
    await _save(
      () => ref
          .read(portfolioEditorProvider)
          .addToWatchlist(
            portfolioId: widget.portfolioId,
            instrument: selected,
          ),
      '${selected.name} added to the watchlist.',
    );
  }

  Future<void> _save(
    Future<Result<void>> Function() operation,
    String success,
  ) async {
    if (_saving) {
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    final Result<void> result = await operation();
    if (!mounted) {
      return;
    }
    final Failure? failure = result.failureOrNull;
    if (failure != null) {
      setState(() {
        _saving = false;
        _message = failure.message;
      });
      return;
    }
    Navigator.of(context).pop(success);
  }

  @override
  Widget build(BuildContext context) {
    final Instrument? selected = _selected;
    return AlertDialog(
      title: Text(selected == null ? 'Add instrument' : selected.name),
      content: SizedBox(
        width: 560,
        height: (MediaQuery.sizeOf(context).height * 0.65).clamp(260, 430),
        child: selected == null ? _searchStep(context) : _detailsStep(context),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _searchStep(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      TextField(
        controller: _query,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _search(),
        decoration: InputDecoration(
          labelText: 'Symbol, company name or ISIN',
          suffixIcon: IconButton(
            tooltip: 'Search',
            onPressed: _searching ? null : _search,
            icon: const Icon(Icons.search),
          ),
        ),
      ),
      const SizedBox(height: AppTheme.space),
      if (_searching) const LinearProgressIndicator(),
      if (_message case final String message) ...<Widget>[
        const SizedBox(height: AppTheme.space),
        Text(
          message,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
      const SizedBox(height: AppTheme.space),
      Expanded(
        child: _results.isEmpty
            ? const Center(
                child: Text('Search local data and enabled providers.'),
              )
            : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (BuildContext context, int index) {
                  final Instrument instrument = _results[index];
                  return ListTile(
                    key: ValueKey<String>(
                      'search-result-${instrument.internalId}',
                    ),
                    title: Text(instrument.name),
                    subtitle: Text(
                      '${instrument.displaySymbol} · ${instrument.currency.code}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => setState(() {
                      _selected = instrument;
                      _message = null;
                    }),
                  );
                },
              ),
      ),
    ],
  );

  Widget _detailsStep(BuildContext context) {
    final Instrument selected = _selected!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _saving
                  ? null
                  : () => setState(() {
                      _selected = null;
                      _message = null;
                    }),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to results'),
            ),
          ),
          Text(selected.displaySymbol),
          const SizedBox(height: AppTheme.space * 2),
          TextField(
            key: const ValueKey<String>('holding-quantity'),
            controller: _quantity,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Quantity',
              helperText: 'Fractional shares are supported.',
            ),
          ),
          const SizedBox(height: AppTheme.space),
          TextField(
            key: const ValueKey<String>('holding-average-price'),
            controller: _averagePrice,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Average purchase price (optional)',
              suffixText: selected.currency.code,
            ),
          ),
          if (_message case final String message) ...<Widget>[
            const SizedBox(height: AppTheme.space),
            Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: AppTheme.space * 2),
          if (_saving)
            const Center(child: CircularProgressIndicator.adaptive())
          else ...<Widget>[
            FilledButton.icon(
              onPressed: _addHolding,
              icon: const Icon(Icons.pie_chart_outline),
              label: const Text('Add holding'),
            ),
            const SizedBox(height: AppTheme.space),
            OutlinedButton.icon(
              onPressed: _addToWatchlist,
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Add to watchlist'),
            ),
          ],
        ],
      ),
    );
  }
}
