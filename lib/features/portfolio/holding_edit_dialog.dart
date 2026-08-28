import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edits user-owned holding metadata without replacing ledger history.
class HoldingEditDialog extends ConsumerStatefulWidget {
  /// Creates an editor for [holding].
  const HoldingEditDialog({
    required this.holding,
    required this.instrument,
    super.key,
  });

  /// Existing holding to replace.
  final Holding holding;

  /// Instrument used for labels and the default price currency.
  final Instrument instrument;

  @override
  ConsumerState<HoldingEditDialog> createState() => _HoldingEditDialogState();
}

class _HoldingEditDialogState extends ConsumerState<HoldingEditDialog> {
  late final TextEditingController _quantity = TextEditingController(
    text: widget.holding.quantity.toString(),
  );
  late final TextEditingController _averagePrice = TextEditingController(
    text: widget.holding.averagePurchasePrice?.amount.toString() ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.holding.notes ?? '',
  );
  late DateTime? _purchaseDate = widget.holding.purchaseDate;
  String? _message;
  bool _saving = false;

  @override
  void dispose() {
    _quantity.dispose();
    _averagePrice.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = ref.read(clockProvider).now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );
    if (selected != null && mounted) {
      setState(() => _purchaseDate = selected);
    }
  }

  Future<void> _save() async {
    Decimal quantity;
    Money? averagePrice;
    final Currency priceCurrency =
        widget.holding.averagePurchasePrice?.currency ??
        widget.instrument.currency;
    try {
      quantity = Decimal.parse(_quantity.text.trim());
      if (quantity <= Decimal.zero) {
        setState(() => _message = 'Enter a quantity greater than zero.');
        return;
      }
      final String price = _averagePrice.text.trim();
      if (price.isNotEmpty) {
        averagePrice = Money.parse(price, priceCurrency);
        if (averagePrice.isNegative) {
          setState(() => _message = 'The purchase price cannot be negative.');
          return;
        }
      }
    } on FormatException {
      setState(() => _message = 'Enter valid decimal numbers.');
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    final DateTime now = ref.read(clockProvider).now();
    final result = await ref
        .read(portfolioEditorProvider)
        .updateHolding(
          Holding(
            portfolioId: widget.holding.portfolioId,
            instrumentId: widget.holding.instrumentId,
            quantity: quantity,
            averagePurchasePrice: averagePrice,
            purchaseDate: _purchaseDate,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            provenance: Provenance.user(now),
          ),
        );
    if (!mounted) return;
    if (result.failureOrNull case final failure?) {
      setState(() {
        _saving = false;
        _message = failure.message;
      });
      return;
    }
    Navigator.of(context).pop(
      context.trFormat('{name} updated.', <String, Object?>{
        'name': widget.instrument.name,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Currency priceCurrency =
        widget.holding.averagePurchasePrice?.currency ??
        widget.instrument.currency;
    return AlertDialog(
      title: Text.format('Edit {name}', <String, Object?>{
        'name': widget.instrument.name,
      }),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                key: const ValueKey<String>('edit-holding-quantity'),
                controller: _quantity,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: context.tr('Quantity')),
              ),
              const SizedBox(height: AppTheme.space),
              TextField(
                key: const ValueKey<String>('edit-holding-average-price'),
                controller: _averagePrice,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: context.tr('Average purchase price (optional)'),
                  suffixText: priceCurrency.code,
                ),
              ),
              const SizedBox(height: AppTheme.space),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _purchaseDate == null
                          ? 'Purchase date not set'
                          : MaterialLocalizations.of(context)
                                .formatMediumDate(_purchaseDate!),
                    ),
                  ),
                  TextButton(
                    onPressed: _saving ? null : _pickDate,
                    child: const Text('Choose'),
                  ),
                  if (_purchaseDate != null)
                    IconButton(
                      tooltip: context.tr('Clear purchase date'),
                      onPressed: _saving
                          ? null
                          : () => setState(() => _purchaseDate = null),
                      icon: const Icon(Icons.clear),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.space),
              TextField(
                key: const ValueKey<String>('edit-holding-notes'),
                controller: _notes,
                enabled: !_saving,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.tr('Notes (optional)'),
                ),
              ),
              if (_message case final String message) ...<Widget>[
                const SizedBox(height: AppTheme.space),
                Text(
                  message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey<String>('save-holding-edit'),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
