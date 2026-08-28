import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/use_cases/portfolio_import.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local file selection, validation preview and atomic import confirmation.
class PortfolioImportDialog extends ConsumerStatefulWidget {
  /// Creates the import flow for [portfolioId].
  const PortfolioImportDialog({required this.portfolioId, super.key});

  /// Portfolio that receives valid rows.
  final String portfolioId;

  @override
  ConsumerState<PortfolioImportDialog> createState() =>
      _PortfolioImportDialogState();
}

class _PortfolioImportDialogState extends ConsumerState<PortfolioImportDialog> {
  PortfolioImportPreview? _preview;
  String? _selectedName;
  String? _message;
  bool _loading = false;
  bool _applying = false;

  Future<void> _chooseFile() async {
    if (_loading || _applying) return;
    const XTypeGroup csvFiles = XTypeGroup(
      label: 'CSV transactions',
      extensions: <String>['csv'],
      mimeTypes: <String>['text/csv', 'text/plain'],
    );
    final XFile? selected = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[csvFiles],
    );
    if (selected == null || !mounted) return;
    setState(() {
      _loading = true;
      _preview = null;
      _selectedName = selected.name;
      _message = null;
    });
    try {
      final int length = await selected.length();
      if (!mounted) return;
      if (length > 10 * 1024 * 1024) {
        setState(() {
          _loading = false;
          _message = 'The CSV is larger than the 10 MB safety limit.';
        });
        return;
      }
      final String contents = await selected.readAsString();
      final Result<PortfolioImportPreview> result = await ref
          .read(portfolioImportServiceProvider)
          .preview(portfolioId: widget.portfolioId, contents: contents);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _preview = result.valueOrNull;
        _message = result.failureOrNull?.message;
      });
    } on Object {
      if (mounted) {
        setState(() {
          _loading = false;
          _message = 'The selected file could not be read.';
        });
      }
    }
  }

  Future<void> _apply() async {
    final PortfolioImportPreview preview = _preview!;
    setState(() {
      _applying = true;
      _message = null;
    });
    final Result<int> result = await ref
        .read(portfolioImportServiceProvider)
        .apply(preview);
    if (!mounted) return;
    if (result.failureOrNull case final failure?) {
      setState(() {
        _applying = false;
        _message = failure.message;
      });
      return;
    }
    Navigator.of(context).pop(
      context.trFormat('{count} activities imported.', <String, Object?>{
        'count': result.valueOrNull ?? 0,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PortfolioImportPreview? preview = _preview;
    return AlertDialog(
      title: const Text('Import activities'),
      content: SizedBox(
        width: 620,
        height: (MediaQuery.sizeOf(context).height * 0.7).clamp(320, 560),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'The file is read locally and is never uploaded or retained. '
                'Nothing changes until you review this preview and choose Apply.',
              ),
              const SizedBox(height: AppTheme.space),
              OutlinedButton.icon(
                key: const ValueKey<String>('choose-import-file'),
                onPressed: _loading || _applying ? null : _chooseFile,
                icon: const Icon(Icons.file_open_outlined),
                label: Text(_selectedName ?? 'Choose CSV file'),
              ),
              if (_loading) ...<Widget>[
                const SizedBox(height: AppTheme.space),
                const LinearProgressIndicator(),
              ],
              if (_message case final String message) ...<Widget>[
                const SizedBox(height: AppTheme.space),
                Text(
                  message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (preview != null) ...<Widget>[
                const SizedBox(height: AppTheme.space * 2),
                Text('Review', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppTheme.space / 2),
                Text.format(
                  '{format} · {ready} ready · '
                  '{duplicates} duplicates · {rejected} rejected',
                  <String, Object?>{
                    'format': context.tr(_formatName(preview.format)),
                    'ready': preview.activities.length,
                    'duplicates': preview.duplicateCount,
                    'rejected': preview.issues.length,
                  },
                ),
                if (preview.duplicateCount > 0)
                  const Text(
                    'Duplicates are skipped using stable imported row identities.',
                  ),
                if (preview.activities.isNotEmpty) ...<Widget>[
                  const Divider(height: AppTheme.space * 3),
                  Text(
                    'Activities to apply',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final activity in preview.activities.take(20))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(activity.type.name),
                      subtitle: Text(
                        '${MaterialLocalizations.of(context).formatMediumDate(activity.occurredAt)}'
                        '${activity.quantity == null ? '' : ' · ${activity.quantity} shares'}'
                        '${activity.cashAmount == null ? '' : ' · ${activity.cashAmount!.format()}'}',
                      ),
                    ),
                  if (preview.activities.length > 20)
                    Text.format('{count} more activities', <String, Object?>{
                      'count': preview.activities.length - 20,
                    }),
                ],
                if (preview.issues.isNotEmpty) ...<Widget>[
                  const Divider(height: AppTheme.space * 3),
                  Text(
                    'Rejected rows',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final PortfolioImportIssue issue in preview.issues.take(
                    20,
                  ))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.error_outline),
                      title: Text.format('Line {line}', <String, Object?>{
                        'line': issue.line,
                      }),
                      subtitle: Text(issue.message),
                    ),
                ],
                const Divider(height: AppTheme.space * 3),
                const Text(
                  'Native columns: Date, Type, Symbol or ISIN, Quantity, '
                  'Unit Price, Amount, Currency, Fees, Taxes, External ID, Notes. '
                  'Portfolio Performance transactions and Interactive Brokers '
                  'Flex exports are detected automatically.',
                ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _applying ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const ValueKey<String>('apply-import'),
          onPressed: preview?.canApply == true && !_applying ? _apply : null,
          child: _applying
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Apply'),
        ),
      ],
    );
  }

  static String _formatName(PortfolioImportFormat format) => switch (format) {
    PortfolioImportFormat.dividendendackel => 'DividendenDackel CSV',
    PortfolioImportFormat.portfolioPerformance => 'Portfolio Performance CSV',
    PortfolioImportFormat.interactiveBrokersFlex =>
      'Interactive Brokers Flex CSV',
  };
}
