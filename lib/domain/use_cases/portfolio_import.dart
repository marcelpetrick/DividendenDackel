import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart';
import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/utils/clock.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';

/// Supported, explicitly documented local CSV layouts.
enum PortfolioImportFormat { dividendendackel, portfolioPerformance }

/// One rejected source row with safe, actionable detail.
final class PortfolioImportIssue {
  /// Creates an issue for a one-based source [line].
  const PortfolioImportIssue({required this.line, required this.message});

  /// One-based CSV line number.
  final int line;

  /// User-facing validation detail. Raw row contents are deliberately absent.
  final String message;
}

/// Read-only preview produced before any database mutation.
final class PortfolioImportPreview {
  /// Creates a preview.
  const PortfolioImportPreview({
    required this.batchId,
    required this.source,
    required this.format,
    required this.activities,
    required this.duplicateCount,
    required this.issues,
  });

  /// Stable identity assigned if the user applies this preview.
  final String batchId;

  /// Adapter provenance stored with each imported activity.
  final String source;

  /// Detected input layout.
  final PortfolioImportFormat format;

  /// Valid, non-duplicate activities ready for one atomic commit.
  final List<PortfolioActivity> activities;

  /// Rows already present from an earlier import.
  final int duplicateCount;

  /// Rejected rows that will not be applied.
  final List<PortfolioImportIssue> issues;

  /// Whether there is at least one activity to apply.
  bool get canApply => activities.isNotEmpty;
}

/// Parses, resolves, previews and atomically applies local portfolio CSVs.
final class PortfolioImportService {
  /// Creates the service.
  const PortfolioImportService({
    required this.portfolios,
    required this.instruments,
    required this.clock,
  });

  /// Portfolio persistence and duplicate lookup.
  final PortfolioRepository portfolios;

  /// Local instrument catalogue used for exact identity resolution.
  final InstrumentRepository instruments;

  /// Import and provenance time source.
  final Clock clock;

  /// Parses [contents] without writing, then removes persisted duplicates.
  Future<Result<PortfolioImportPreview>> preview({
    required String portfolioId,
    required String contents,
  }) => Result.guardAsync<PortfolioImportPreview>(() async {
    if (utf8.encode(contents).length > 10 * 1024 * 1024) {
      throw const ParsingFailure(
        message: 'The CSV is larger than the 10 MB safety limit.',
      );
    }
    final List<Instrument> catalogue = await instruments.watchAll().first;
    final DateTime importedAt = clock.now().toUtc();
    final PortfolioCsvParseResult parsed = PortfolioCsvParser.parse(
      portfolioId: portfolioId,
      contents: contents,
      instruments: catalogue,
      importedAt: importedAt,
    );
    final Set<String> externalIds = <String>{
      for (final PortfolioActivity activity in parsed.activities)
        activity.externalId!,
    };
    final Result<Set<String>> duplicateResult = await portfolios
        .findImportedExternalIds(
          portfolioId: portfolioId,
          source: parsed.source,
          externalIds: externalIds,
        );
    final Set<String>? duplicates = duplicateResult.valueOrNull;
    if (duplicates == null) throw duplicateResult.failureOrNull!;
    final String batchId =
        'import-${importedAt.microsecondsSinceEpoch}-'
        '${sha256.convert(utf8.encode(contents)).toString().substring(0, 12)}';
    final Set<String> seen = <String>{};
    final List<PortfolioActivity> ready = <PortfolioActivity>[
      for (final PortfolioActivity activity in parsed.activities)
        if (!duplicates.contains(activity.externalId) &&
            seen.add(activity.externalId!))
          PortfolioActivity(
            portfolioId: activity.portfolioId,
            type: activity.type,
            occurredAt: activity.occurredAt,
            instrumentId: activity.instrumentId,
            quantity: activity.quantity,
            unitPrice: activity.unitPrice,
            cashAmount: activity.cashAmount,
            externalId: activity.externalId,
            importBatchId: batchId,
            notes: activity.notes,
            provenance: activity.provenance,
          ),
    ];
    return PortfolioImportPreview(
      batchId: batchId,
      source: parsed.source,
      format: parsed.format,
      activities: List<PortfolioActivity>.unmodifiable(ready),
      duplicateCount: parsed.activities.length - ready.length,
      issues: parsed.issues,
    );
  });

  /// Applies exactly the reviewed activities in [preview].
  Future<Result<int>> apply(PortfolioImportPreview preview) =>
      portfolios.applyImportBatch(preview.batchId, preview.activities);
}

/// Pure CSV parser. It performs no I/O and accepts only exact local instrument
/// matches so an ambiguous ticker can never mutate the wrong holding.
abstract final class PortfolioCsvParser {
  /// Parses the native schema or a Portfolio Performance transaction export.
  static PortfolioCsvParseResult parse({
    required String portfolioId,
    required String contents,
    required List<Instrument> instruments,
    required DateTime importedAt,
  }) {
    if (contents.trim().isEmpty) {
      throw const ParsingFailure(message: 'The selected CSV is empty.');
    }
    final List<List<dynamic>> decoded;
    try {
      decoded = Csv().decode(contents);
    } on Object catch (error) {
      throw ParsingFailure(
        message: 'The selected file is not valid CSV.',
        technicalDetail: error.toString(),
        cause: error,
      );
    }
    if (decoded.length < 2) {
      throw const ParsingFailure(
        message: 'The CSV needs a header and at least one data row.',
      );
    }
    final List<String> headers = decoded.first
        .map((dynamic value) => _normalizeHeader(value.toString()))
        .toList(growable: false);
    if (!headers.contains('date') || !headers.contains('type')) {
      throw const ParsingFailure(
        message: 'The CSV needs Date and Type columns.',
      );
    }
    final PortfolioImportFormat format =
        headers.contains('transaction_currency') ||
            headers.contains('ticker_symbol') ||
            headers.contains('security_name')
        ? PortfolioImportFormat.portfolioPerformance
        : PortfolioImportFormat.dividendendackel;
    final String source = switch (format) {
      PortfolioImportFormat.dividendendackel => 'import:dividendendackel-csv',
      PortfolioImportFormat.portfolioPerformance =>
        'import:portfolio-performance-csv',
    };
    final _InstrumentIndex index = _InstrumentIndex(instruments);
    final List<PortfolioActivity> activities = <PortfolioActivity>[];
    final List<PortfolioImportIssue> issues = <PortfolioImportIssue>[];

    for (int rowIndex = 1; rowIndex < decoded.length; rowIndex++) {
      final int line = rowIndex + 1;
      final Map<String, String> row = <String, String>{
        for (int column = 0; column < headers.length; column++)
          headers[column]: column < decoded[rowIndex].length
              ? decoded[rowIndex][column].toString().trim()
              : '',
      };
      try {
        activities.addAll(
          _parseRow(
            line: line,
            portfolioId: portfolioId,
            row: row,
            index: index,
            source: source,
            importedAt: importedAt,
          ),
        );
      } on FormatException catch (error) {
        issues.add(PortfolioImportIssue(line: line, message: error.message));
      } on ArgumentError catch (error) {
        issues.add(
          PortfolioImportIssue(
            line: line,
            message: error.message?.toString() ?? 'Invalid row.',
          ),
        );
      }
    }
    return PortfolioCsvParseResult(
      source: source,
      format: format,
      activities: List<PortfolioActivity>.unmodifiable(activities),
      issues: List<PortfolioImportIssue>.unmodifiable(issues),
    );
  }

  static List<PortfolioActivity> _parseRow({
    required int line,
    required String portfolioId,
    required Map<String, String> row,
    required _InstrumentIndex index,
    required String source,
    required DateTime importedAt,
  }) {
    final PortfolioActivityType type = _activityType(
      _field(row, <String>['type']),
    );
    final DateTime occurredAt = _date(_field(row, <String>['date']));
    final String isin = _field(row, <String>['isin']);
    final String symbol = _field(row, <String>[
      'symbol',
      'ticker',
      'ticker_symbol',
    ]);
    final bool securityRequired =
        type == PortfolioActivityType.purchase ||
        type == PortfolioActivityType.sale ||
        type == PortfolioActivityType.openingBalance;
    final Instrument? instrument = index.resolve(isin: isin, symbol: symbol);
    if (securityRequired && instrument == null) {
      throw const FormatException(
        'An exact local ISIN or unambiguous ticker is required.',
      );
    }
    if ((isin.isNotEmpty || symbol.isNotEmpty) && instrument == null) {
      throw const FormatException(
        'The instrument is unknown or its ticker is ambiguous.',
      );
    }

    final String transactionCurrencyText = _field(row, <String>[
      'currency',
      'transaction_currency',
    ]);
    final String grossCurrencyText = _field(row, <String>[
      'currency_gross_amount',
    ]);
    final String directAmountText = _field(row, <String>['amount']);
    final String grossAmountText = _field(row, <String>['gross_amount']);
    final String valueText = _field(row, <String>['value']);
    final bool useGrossAmount =
        directAmountText.isEmpty &&
        grossAmountText.isNotEmpty &&
        (securityRequired || type == PortfolioActivityType.dividend);
    final String amountText = directAmountText.isNotEmpty
        ? directAmountText
        : useGrossAmount
        ? grossAmountText
        : valueText.isNotEmpty
        ? valueText
        : grossAmountText;
    final String currencyText = useGrossAmount
        ? (grossCurrencyText.isNotEmpty
              ? grossCurrencyText
              : transactionCurrencyText)
        : (transactionCurrencyText.isNotEmpty
              ? transactionCurrencyText
              : grossCurrencyText);
    final Currency? currency = currencyText.isNotEmpty
        ? Currency.parse(currencyText)
        : instrument?.currency;
    final Currency? transactionCurrency = transactionCurrencyText.isNotEmpty
        ? Currency.parse(transactionCurrencyText)
        : currency;
    final Decimal? quantity = _decimalOrNull(
      _field(row, <String>['quantity', 'shares']),
    );
    final Decimal? amount = _decimalOrNull(amountText)?.abs();
    Decimal? unitPrice = _decimalOrNull(
      _field(row, <String>['unit_price', 'quote', 'price']),
    )?.abs();
    if (unitPrice == null &&
        amount != null &&
        quantity != null &&
        quantity > Decimal.zero &&
        securityRequired) {
      unitPrice = (amount / quantity).toDecimal(scaleOnInfinitePrecision: 12);
    }
    final Decimal? fee = _decimalOrNull(_field(row, <String>['fee', 'fees']))
        ?.abs();
    final Decimal? tax = _decimalOrNull(_field(row, <String>['tax', 'taxes']))
        ?.abs();
    final String suppliedId = _field(row, <String>[
      'external_id',
      'transaction_id',
      'contract_ref',
      'id',
    ]);
    final String canonical = row.entries
        .map((MapEntry<String, String> item) => '${item.key}=${item.value}')
        .join('|');
    final String baseId = suppliedId.isNotEmpty
        ? 'external:$suppliedId'
        : 'row:${sha256.convert(utf8.encode(canonical))}';
    final String notes = _field(row, <String>['notes', 'note']);
    final Provenance provenance = Provenance(
      source: source,
      fetchedAt: importedAt,
      updatedAt: occurredAt,
      confidence: Confidence.high,
      reportedCurrency: currency,
      originalSymbol: symbol.isEmpty ? null : symbol,
    );

    PortfolioActivity main;
    switch (type) {
      case PortfolioActivityType.purchase:
      case PortfolioActivityType.sale:
      case PortfolioActivityType.openingBalance:
        if (quantity == null || quantity <= Decimal.zero) {
          throw const FormatException(
            'A positive Quantity/Shares value is required.',
          );
        }
        main = PortfolioActivity(
          portfolioId: portfolioId,
          type: type,
          occurredAt: occurredAt,
          instrumentId: instrument!.internalId,
          quantity: quantity,
          unitPrice: unitPrice == null
              ? null
              : Money(unitPrice, currency ?? instrument.currency),
          cashAmount: amount == null || currency == null
              ? null
              : Money(amount, currency),
          externalId: '$baseId:main',
          notes: notes.isEmpty ? null : notes,
          provenance: provenance,
        );
      case PortfolioActivityType.deposit:
      case PortfolioActivityType.withdrawal:
      case PortfolioActivityType.dividend:
      case PortfolioActivityType.tax:
      case PortfolioActivityType.fee:
        if (amount == null || amount <= Decimal.zero || currency == null) {
          throw const FormatException(
            'A positive Amount/Value and Currency are required.',
          );
        }
        main = PortfolioActivity(
          portfolioId: portfolioId,
          type: type,
          occurredAt: occurredAt,
          instrumentId: instrument?.internalId,
          cashAmount: Money(amount, currency),
          externalId: '$baseId:main',
          notes: notes.isEmpty ? null : notes,
          provenance: provenance,
        );
      case PortfolioActivityType.holdingAdjustment:
      case PortfolioActivityType.reversal:
        throw const FormatException('This activity type cannot be imported.');
    }

    return <PortfolioActivity>[
      main,
      if (fee != null && fee > Decimal.zero)
        PortfolioActivity(
          portfolioId: portfolioId,
          type: PortfolioActivityType.fee,
          occurredAt: occurredAt,
          instrumentId: instrument?.internalId,
          cashAmount: Money(fee, transactionCurrency ?? instrument!.currency),
          externalId: '$baseId:fee',
          provenance: provenance,
        ),
      if (tax != null && tax > Decimal.zero)
        PortfolioActivity(
          portfolioId: portfolioId,
          type: PortfolioActivityType.tax,
          occurredAt: occurredAt,
          instrumentId: instrument?.internalId,
          cashAmount: Money(tax, transactionCurrency ?? instrument!.currency),
          externalId: '$baseId:tax',
          provenance: provenance,
        ),
    ];
  }

  static String _normalizeHeader(String value) {
    final String normalized = value
        .replaceFirst('\u{FEFF}', '')
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp('[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return switch (normalized) {
      'datum' => 'date',
      'typ' => 'type',
      'wert' => 'value',
      'transaktionswaehrung' => 'transaction_currency',
      'bruttobetrag' => 'gross_amount',
      'waehrung_bruttobetrag' => 'currency_gross_amount',
      'gebuehren' => 'fees',
      'steuern' => 'taxes',
      'stueck' => 'shares',
      'wertpapiername' => 'security_name',
      'notiz' => 'note',
      _ => normalized,
    };
  }

  static String _field(Map<String, String> row, List<String> names) {
    for (final String name in names) {
      final String? value = row[name];
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  static PortfolioActivityType _activityType(String raw) {
    final String value = raw
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return switch (value) {
      'buy' || 'purchase' || 'kauf' => PortfolioActivityType.purchase,
      'sell' || 'sale' || 'verkauf' => PortfolioActivityType.sale,
      'deposit' || 'einlage' => PortfolioActivityType.deposit,
      'withdrawal' ||
      'removal' ||
      'entnahme' => PortfolioActivityType.withdrawal,
      'interest' ||
      'zinsen' ||
      'fees_refund' ||
      'tax_refund' ||
      'gebuehrenerstattung' ||
      'steuererstattung' => PortfolioActivityType.deposit,
      'interest_charge' || 'zinsbelastung' => PortfolioActivityType.withdrawal,
      'dividend' || 'dividende' => PortfolioActivityType.dividend,
      'tax' || 'taxes' || 'steuer' || 'steuern' => PortfolioActivityType.tax,
      'fee' || 'fees' || 'gebuehr' || 'gebuehren' => PortfolioActivityType.fee,
      'openingbalance' ||
      'opening_balance' ||
      'delivery_inbound' ||
      'einlieferung' => PortfolioActivityType.openingBalance,
      'delivery_outbound' || 'auslieferung' => PortfolioActivityType.sale,
      _ => throw FormatException('Unsupported activity type "$raw".'),
    };
  }

  static DateTime _date(String raw) {
    final String value = raw.trim();
    final DateTime? iso = DateTime.tryParse(value);
    if (iso != null) return iso.toUtc();
    final RegExpMatch? match = RegExp(
      r'^(\d{1,2})[./-](\d{1,2})[./-](\d{4})(?:[ T].*)?$',
    ).firstMatch(value);
    if (match != null) {
      final int day = int.parse(match.group(1)!);
      final int month = int.parse(match.group(2)!);
      final int year = int.parse(match.group(3)!);
      final DateTime parsed = DateTime.utc(year, month, day, 12);
      if (parsed.year == year && parsed.month == month && parsed.day == day) {
        return parsed;
      }
    }
    throw FormatException('Date "$raw" is not ISO or day-month-year.');
  }

  static Decimal? _decimalOrNull(String raw) {
    String value = raw.trim();
    if (value.isEmpty || value == '-') return null;
    bool negative = false;
    if (value.startsWith('(') && value.endsWith(')')) {
      negative = true;
      value = value.substring(1, value.length - 1);
    }
    value = value.replaceAll(RegExp(r'[^0-9,\.\-+]'), '');
    final int comma = value.lastIndexOf(',');
    final int dot = value.lastIndexOf('.');
    if (comma >= 0 && dot >= 0) {
      if (comma > dot) {
        value = value.replaceAll('.', '').replaceFirst(',', '.');
      } else {
        value = value.replaceAll(',', '');
      }
    } else if (comma >= 0) {
      value = value.replaceFirst(',', '.');
    }
    try {
      final Decimal parsed = Decimal.parse(value);
      return negative ? -parsed : parsed;
    } on FormatException {
      throw FormatException('"$raw" is not a valid decimal number.');
    }
  }
}

/// Pure parser output before persisted duplicate detection.
final class PortfolioCsvParseResult {
  /// Creates parser output.
  const PortfolioCsvParseResult({
    required this.source,
    required this.format,
    required this.activities,
    required this.issues,
  });

  /// Stable adapter provenance.
  final String source;

  /// Detected input layout.
  final PortfolioImportFormat format;

  /// Valid activities parsed from the source.
  final List<PortfolioActivity> activities;

  /// Rows rejected without preventing valid rows from being previewed.
  final List<PortfolioImportIssue> issues;
}

final class _InstrumentIndex {
  _InstrumentIndex(List<Instrument> instruments) : _instruments = instruments;

  final List<Instrument> _instruments;

  Instrument? resolve({required String isin, required String symbol}) {
    if (isin.trim().isNotEmpty) {
      final List<Instrument> matches = _instruments
          .where(
            (Instrument item) =>
                item.isin?.toUpperCase() == isin.trim().toUpperCase(),
          )
          .toList(growable: false);
      if (matches.length == 1) return matches.single;
      return null;
    }
    if (symbol.trim().isEmpty) return null;
    final String normalized = symbol.trim().toUpperCase();
    final List<Instrument> matches = _instruments
        .where(
          (Instrument item) =>
              item.symbol.toUpperCase() == normalized ||
              item.displaySymbol.toUpperCase() == normalized,
        )
        .toList(growable: false);
    return matches.length == 1 ? matches.single : null;
  }
}
