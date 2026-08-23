import 'package:decimal/decimal.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manual activity entry shared by Android and Linux.
class PortfolioActivityDialog extends ConsumerStatefulWidget {
  /// Creates the dialog for [portfolioId].
  const PortfolioActivityDialog({
    required this.portfolioId,
    required this.instruments,
    super.key,
  });

  /// Portfolio receiving the immutable activity.
  final String portfolioId;

  /// Available local instruments keyed by identity.
  final Map<String, Instrument> instruments;

  @override
  ConsumerState<PortfolioActivityDialog> createState() =>
      _PortfolioActivityDialogState();
}

class _PortfolioActivityDialogState
    extends ConsumerState<PortfolioActivityDialog> {
  PortfolioActivityType _type = PortfolioActivityType.purchase;
  String? _instrumentId;
  DateTime _occurredAt = DateTime.now();
  Currency _currency = Currency.eur;
  final TextEditingController _quantity = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  String? _message;
  bool _saving = false;

  static const List<PortfolioActivityType> _visibleTypes =
      <PortfolioActivityType>[
        PortfolioActivityType.purchase,
        PortfolioActivityType.sale,
        PortfolioActivityType.deposit,
        PortfolioActivityType.withdrawal,
        PortfolioActivityType.dividend,
        PortfolioActivityType.tax,
        PortfolioActivityType.fee,
      ];

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _needsQuantity =>
      _type == PortfolioActivityType.purchase ||
      _type == PortfolioActivityType.sale;

  bool get _needsInstrument =>
      _needsQuantity || _type == PortfolioActivityType.dividend;

  bool get _needsAmount => !_needsQuantity;

  Future<void> _pickDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (selected != null && mounted) {
      setState(() => _occurredAt = selected);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    try {
      final Instrument? instrument = widget.instruments[_instrumentId];
      final Decimal? quantity = _quantity.text.trim().isEmpty
          ? null
          : Decimal.parse(_quantity.text.trim());
      final Money? price = _price.text.trim().isEmpty
          ? null
          : Money.parse(_price.text.trim(), instrument?.currency ?? _currency);
      final Money? amount = _amount.text.trim().isEmpty
          ? null
          : Money.parse(_amount.text.trim(), _currency);
      final DateTime timestamp = DateTime(
        _occurredAt.year,
        _occurredAt.month,
        _occurredAt.day,
        12,
      ).toUtc();
      final PortfolioActivity activity = PortfolioActivity(
        portfolioId: widget.portfolioId,
        type: _type,
        occurredAt: timestamp,
        instrumentId: _needsInstrument ? _instrumentId : null,
        quantity: quantity,
        unitPrice: price,
        cashAmount: amount,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        provenance: Provenance.user(timestamp),
      );
      setState(() {
        _saving = true;
        _message = null;
      });
      final Result<int> result = await ref
          .read(portfolioRepositoryProvider)
          .recordActivity(activity);
      if (!mounted) return;
      if (result.failureOrNull case final failure?) {
        setState(() {
          _saving = false;
          _message = failure.message;
        });
        return;
      }
      Navigator.of(context).pop('${_label(_type)} recorded.');
    } on FormatException {
      setState(() => _message = 'Enter valid decimal numbers.');
    } on ArgumentError catch (error) {
      setState(
        () =>
            _message = error.message?.toString() ?? 'Check the entered values.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Record activity'),
    content: SizedBox(
      width: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownButtonFormField<PortfolioActivityType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Activity type'),
              items: <DropdownMenuItem<PortfolioActivityType>>[
                for (final PortfolioActivityType type in _visibleTypes)
                  DropdownMenuItem<PortfolioActivityType>(
                    value: type,
                    child: Text(_label(type)),
                  ),
              ],
              onChanged: _saving
                  ? null
                  : (PortfolioActivityType? value) {
                      if (value != null) setState(() => _type = value);
                    },
            ),
            const SizedBox(height: AppTheme.space),
            if (_needsInstrument) ...<Widget>[
              DropdownButtonFormField<String>(
                initialValue: _instrumentId,
                decoration: InputDecoration(
                  labelText: _type == PortfolioActivityType.dividend
                      ? 'Instrument (required)'
                      : 'Instrument',
                ),
                items: <DropdownMenuItem<String>>[
                  for (final Instrument instrument in widget.instruments.values)
                    DropdownMenuItem<String>(
                      value: instrument.internalId,
                      child: Text(
                        '${instrument.displaySymbol} · ${instrument.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: _saving
                    ? null
                    : (String? value) => setState(() {
                        _instrumentId = value;
                        final Instrument? instrument =
                            widget.instruments[value];
                        if (instrument != null) {
                          _currency = instrument.currency;
                        }
                      }),
              ),
              const SizedBox(height: AppTheme.space),
            ],
            OutlinedButton.icon(
              onPressed: _saving ? null : _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(
                MaterialLocalizations.of(context).formatMediumDate(_occurredAt),
              ),
            ),
            if (_needsQuantity) ...<Widget>[
              const SizedBox(height: AppTheme.space),
              TextField(
                controller: _quantity,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: AppTheme.space),
              TextField(
                controller: _price,
                decoration: InputDecoration(
                  labelText: 'Price per share (optional)',
                  suffixText: widget.instruments[_instrumentId]?.currency.code,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
            if (_needsAmount) ...<Widget>[
              const SizedBox(height: AppTheme.space),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _amount,
                      decoration: InputDecoration(
                        labelText: _type == PortfolioActivityType.dividend
                            ? 'Gross cash amount'
                            : 'Cash amount',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.space),
                  SizedBox(
                    width: 110,
                    child: DropdownButtonFormField<Currency>(
                      initialValue: _currency,
                      decoration: const InputDecoration(labelText: 'Currency'),
                      items: <DropdownMenuItem<Currency>>[
                        for (final Currency currency in Currency.known.values)
                          DropdownMenuItem<Currency>(
                            value: currency,
                            child: Text(currency.code),
                          ),
                      ],
                      onChanged: _saving
                          ? null
                          : (Currency? value) {
                              if (value != null) {
                                setState(() => _currency = value);
                              }
                            },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppTheme.space),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            if (_message case final String message) ...<Widget>[
              const SizedBox(height: AppTheme.space),
              Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (_saving) ...<Widget>[
              const SizedBox(height: AppTheme.space),
              const LinearProgressIndicator(),
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
        onPressed: _saving ? null : _save,
        child: const Text('Record'),
      ),
    ],
  );

  static String _label(PortfolioActivityType type) => switch (type) {
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
}
