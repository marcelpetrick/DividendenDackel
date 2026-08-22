import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/core/utils/clock.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:http/http.dart' as http;

/// Keyless adapter for public SEC EDGAR company data.
final class SecEdgarProvider
    implements
        InstrumentSearchProvider,
        DividendDataProvider,
        FilingDataProvider {
  /// Creates the adapter with an injectable transport and time source.
  SecEdgarProvider(this._client, this._clock);

  /// Stable provider id used in mappings, settings and provenance.
  static const String providerId = 'sec';

  /// Declared bot identity sent with every SEC request.
  static const String userAgent = 'DividendenDackel mail@marcelpetrick.it';

  static final Uri _tickerIndexUri = Uri.parse(
    'https://www.sec.gov/files/company_tickers.json',
  );
  static final RegExp _quarterFrame = RegExp(r'^CY(\d{4})Q([1-4])$');
  static final RegExp _annualFrame = RegExp(r'^CY(\d{4})$');

  final http.Client _client;
  final Clock _clock;
  _SecTickerIndex? _tickerIndex;

  @override
  String get id => providerId;

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.instrumentSearch,
    ProviderDataType.dividends,
    ProviderDataType.filings,
  };

  @override
  Future<Result<List<Instrument>>> searchInstruments(
    String query, {
    required int limit,
    required CancellationToken cancellationToken,
  }) => Result.guardAsync<List<Instrument>>(() async {
    final String normalized = query.trim();
    if (normalized.isEmpty) {
      throw const InvalidInstrumentFailure(
        message: 'Enter a ticker or company name.',
      );
    }
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be positive');
    }
    final _SecTickerIndex index = await _loadTickerIndex(cancellationToken);
    final List<Instrument> instruments = index.search(normalized, limit: limit);
    if (instruments.isEmpty) {
      throw NoDataFailure(technicalDetail: 'No SEC ticker matches $normalized');
    }
    return instruments;
  });

  @override
  Future<Result<List<DividendEvent>>> fetchDividends(
    Instrument instrument,
    DateRange range, {
    required CancellationToken cancellationToken,
  }) => Result.guardAsync<List<DividendEvent>>(() async {
    final String cik = await _resolveCik(instrument, cancellationToken);
    final Map<String, dynamic> json = await _getJson(
      Uri.parse('https://data.sec.gov/api/xbrl/companyfacts/CIK$cik.json'),
      cancellationToken,
    );
    final List<DividendEvent> events = _parseDividendFacts(
      json,
      instrument: instrument,
      range: range,
      fetchedAt: _clock.now(),
    );
    if (events.isEmpty) {
      throw NoDataFailure(
        technicalDetail:
            'SEC has no discrete declared dividend-per-share facts for CIK$cik '
            'inside $range',
      );
    }
    return events;
  });

  @override
  Future<Result<List<Filing>>> fetchFilings(
    Instrument instrument,
    DateRange range, {
    required CancellationToken cancellationToken,
  }) => Result.guardAsync<List<Filing>>(() async {
    final String cik = await _resolveCik(instrument, cancellationToken);
    final Map<String, dynamic> json = await _getJson(
      Uri.parse('https://data.sec.gov/submissions/CIK$cik.json'),
      cancellationToken,
    );
    final List<Filing> filings = _parseFilings(
      json,
      instrument: instrument,
      cik: cik,
      range: range,
      fetchedAt: _clock.now(),
    );
    if (filings.isEmpty) {
      throw NoDataFailure(
        technicalDetail: 'SEC has no inline filings for CIK$cik inside $range',
      );
    }
    return filings;
  });

  Future<String> _resolveCik(
    Instrument instrument,
    CancellationToken cancellationToken,
  ) async {
    for (final ProviderMapping mapping in instrument.providerMappings) {
      if (mapping.providerId == id) {
        final String? mapped = mapping.providerInstrumentId;
        if (mapped != null && mapped.trim().isNotEmpty) {
          return _normalizeCik(mapped);
        }
      }
    }

    final _SecTickerIndex index = await _loadTickerIndex(cancellationToken);
    final _SecTickerEntry? entry = index.exactTicker(
      instrument.symbolFor(id) ?? instrument.symbol,
    );
    if (entry == null) {
      throw InvalidInstrumentFailure(
        symbol: instrument.symbol,
        technicalDetail:
            'No explicit SEC CIK mapping or exact ticker association',
      );
    }
    return entry.cik;
  }

  Future<_SecTickerIndex> _loadTickerIndex(
    CancellationToken cancellationToken,
  ) async {
    final _SecTickerIndex? cached = _tickerIndex;
    if (cached != null) {
      return cached;
    }
    final Map<String, dynamic> json = await _getJson(
      _tickerIndexUri,
      cancellationToken,
    );
    final _SecTickerIndex parsed = _SecTickerIndex.fromJson(json);
    _tickerIndex = parsed;
    return parsed;
  }

  Future<Map<String, dynamic>> _getJson(
    Uri uri,
    CancellationToken cancellationToken,
  ) async {
    cancellationToken.throwIfCancelled();
    try {
      final http.Response response = await Future.any(<Future<http.Response>>[
        _client.get(
          uri,
          headers: const <String, String>{
            HttpHeaders.userAgentHeader: userAgent,
            HttpHeaders.acceptHeader: 'application/json',
            HttpHeaders.acceptEncodingHeader: 'gzip, deflate',
          },
        ),
        cancellationToken.whenCancelled.then<http.Response>(
          (_) => throw const CancelledFailure(),
        ),
      ]);
      cancellationToken.throwIfCancelled();
      if (response.statusCode == HttpStatus.tooManyRequests ||
          response.statusCode == HttpStatus.forbidden) {
        throw RateLimitFailure(
          retryAt: _retryAt(response.headers[HttpHeaders.retryAfterHeader]),
          technicalDetail: 'SEC HTTP ${response.statusCode}',
        );
      }
      if (response.statusCode == HttpStatus.notFound) {
        throw NoDataFailure(technicalDetail: 'SEC returned 404 for $uri');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ProviderUnavailableFailure(
          statusCode: response.statusCode,
          technicalDetail: 'SEC request failed for $uri',
        );
      }
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw ParsingFailure(
          technicalDetail: 'SEC response at $uri is not a JSON object',
        );
      }
      return decoded;
    } on Failure {
      rethrow;
    } on SocketException catch (error) {
      throw NetworkFailure(technicalDetail: '$uri: $error', cause: error);
    } on http.ClientException catch (error) {
      throw NetworkFailure(technicalDetail: '$uri: $error', cause: error);
    } on FormatException catch (error) {
      throw ParsingFailure(technicalDetail: '$uri: $error', cause: error);
    }
  }

  DateTime? _retryAt(String? value) {
    if (value == null) {
      return null;
    }
    final int? seconds = int.tryParse(value.trim());
    if (seconds != null) {
      return _clock.now().add(Duration(seconds: seconds));
    }
    try {
      return HttpDate.parse(value).toUtc();
    } on FormatException {
      return null;
    }
  }

  static List<DividendEvent> _parseDividendFacts(
    Map<String, dynamic> json, {
    required Instrument instrument,
    required DateRange range,
    required DateTime fetchedAt,
  }) {
    final Map<String, dynamic> facts = _object(json, 'facts');
    final Object? rawTaxonomy = facts['us-gaap'];
    if (rawTaxonomy is! Map<String, dynamic>) {
      return const <DividendEvent>[];
    }
    final Object? rawConcept =
        rawTaxonomy['CommonStockDividendsPerShareDeclared'];
    if (rawConcept is! Map<String, dynamic>) {
      return const <DividendEvent>[];
    }
    final Map<String, dynamic> units = _object(rawConcept, 'units');
    final Map<String, _SecDividendFact> latestByFrame =
        <String, _SecDividendFact>{};

    for (final MapEntry<String, dynamic> unit in units.entries) {
      final String? currencyCode = unit.key.endsWith('/shares')
          ? unit.key.substring(0, unit.key.length - '/shares'.length)
          : null;
      if (currencyCode == null || unit.value is! List<dynamic>) {
        continue;
      }
      for (final Object? rawFact in unit.value as List<dynamic>) {
        if (rawFact is! Map<String, dynamic>) {
          continue;
        }
        final _SecDividendFact? fact = _SecDividendFact.tryParse(
          rawFact,
          Currency.parse(currencyCode),
        );
        if (fact == null ||
            (!range.contains(fact.periodEnd)) ||
            fact.amount <= Decimal.zero) {
          continue;
        }
        final String key = '${fact.frame}:${fact.currency.code}';
        final _SecDividendFact? existing = latestByFrame[key];
        if (existing == null || fact.filedAt.isAfter(existing.filedAt)) {
          latestByFrame[key] = fact;
        }
      }
    }

    // Annual facts are already totals. Returning them alongside discrete
    // quarters would make downstream income calculations double-count. Keep
    // quarters only while no annual fact exists inside the requested range.
    final Set<int> yearsWithAnnualFacts = latestByFrame.values
        .where((_SecDividendFact fact) => fact.quarter == null)
        .map((_SecDividendFact fact) => fact.frameYear)
        .toSet();
    final List<_SecDividendFact> selected =
        latestByFrame.values
            .where(
              (_SecDividendFact fact) =>
                  fact.quarter == null ||
                  !yearsWithAnnualFacts.contains(fact.frameYear),
            )
            .toList()
          ..sort(
            (_SecDividendFact a, _SecDividendFact b) =>
                a.periodEnd.compareTo(b.periodEnd),
          );

    return selected
        .map(
          (_SecDividendFact fact) => DividendEvent(
            instrumentId: instrument.internalId,
            amountPerShare: Money(fact.amount, fact.currency),
            status: DividendStatus.confirmed,
            frequency: fact.quarter == null
                ? DividendFrequency.annual
                : DividendFrequency.quarterly,
            reportedPeriodStart: fact.periodStart,
            reportedPeriodEnd: fact.periodEnd,
            provenance: Provenance(
              source: providerId,
              fetchedAt: fetchedAt,
              updatedAt: fact.filedAt,
              reportedCurrency: fact.currency,
              originalSymbol:
                  instrument.symbolFor(providerId) ?? instrument.symbol,
              exchange: instrument.market,
            ),
          ),
        )
        .toList(growable: false);
  }

  static List<Filing> _parseFilings(
    Map<String, dynamic> json, {
    required Instrument instrument,
    required String cik,
    required DateRange range,
    required DateTime fetchedAt,
  }) {
    final Map<String, dynamic> filings = _object(json, 'filings');
    final Map<String, dynamic> recent = _object(filings, 'recent');
    final List<dynamic> accessions = _array(recent, 'accessionNumber');
    final List<dynamic> forms = _array(recent, 'form');
    final List<dynamic> filedDates = _array(recent, 'filingDate');
    final List<dynamic> reportDates = _array(recent, 'reportDate');
    final List<dynamic> primaryDocuments = _array(recent, 'primaryDocument');
    final List<dynamic> descriptions = _array(recent, 'primaryDocDescription');
    final List<List<dynamic>> required = <List<dynamic>>[
      forms,
      filedDates,
      reportDates,
      primaryDocuments,
      descriptions,
    ];
    if (required.any(
      (List<dynamic> values) => values.length != accessions.length,
    )) {
      throw const ParsingFailure(
        technicalDetail: 'SEC submissions columns have different lengths',
      );
    }

    final String archiveCik = BigInt.parse(cik).toString();
    final List<Filing> result = <Filing>[];
    for (int index = 0; index < accessions.length; index++) {
      final String accession = _text(accessions[index], 'accessionNumber');
      final DateTime filedAt = _date(filedDates[index], 'filingDate');
      if (!range.contains(filedAt)) {
        continue;
      }
      final String document = _text(primaryDocuments[index], 'primaryDocument');
      final String compactAccession = accession.replaceAll('-', '');
      result.add(
        Filing(
          id: accession,
          instrumentId: instrument.internalId,
          formType: _text(forms[index], 'form'),
          filedAt: filedAt,
          periodOfReport: _optionalDate(reportDates[index]),
          title: _optionalText(descriptions[index]),
          url: Uri.parse(
            'https://www.sec.gov/Archives/edgar/data/$archiveCik/'
            '$compactAccession/$document',
          ),
          provenance: Provenance(
            source: providerId,
            fetchedAt: fetchedAt,
            updatedAt: filedAt,
            originalSymbol:
                instrument.symbolFor(providerId) ?? instrument.symbol,
            exchange: instrument.market,
          ),
        ),
      );
    }
    result.sort((Filing a, Filing b) => b.filedAt.compareTo(a.filedAt));
    return result;
  }

  static Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is! Map<String, dynamic>) {
      throw ParsingFailure(technicalDetail: 'SEC response has no $key object');
    }
    return value;
  }

  static List<dynamic> _array(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is! List<dynamic>) {
      throw ParsingFailure(technicalDetail: 'SEC response has no $key array');
    }
    return value;
  }

  static String _text(Object? value, String field) {
    if (value is! String || value.trim().isEmpty) {
      throw ParsingFailure(technicalDetail: 'SEC $field is missing');
    }
    return value;
  }

  static String? _optionalText(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;

  static DateTime _date(Object? value, String field) {
    final String text = _text(value, field);
    try {
      return DateTime.parse('${text}T00:00:00Z');
    } on FormatException catch (error) {
      throw ParsingFailure(
        technicalDetail: 'SEC $field is not an ISO date: $text',
        cause: error,
      );
    }
  }

  static DateTime? _optionalDate(Object? value) =>
      value is String && value.isNotEmpty
      ? _date(value, 'optional date')
      : null;

  static String _normalizeCik(String raw) {
    final String digits = raw.trim();
    if (!RegExp(r'^\d{1,10}$').hasMatch(digits)) {
      throw InvalidInstrumentFailure(
        technicalDetail: 'SEC CIK must contain 1 to 10 digits',
      );
    }
    return digits.padLeft(10, '0');
  }
}

final class _SecTickerEntry {
  const _SecTickerEntry({
    required this.cik,
    required this.ticker,
    required this.title,
  });

  final String cik;
  final String ticker;
  final String title;
}

final class _SecTickerIndex {
  _SecTickerIndex(this.entries);

  factory _SecTickerIndex.fromJson(Map<String, dynamic> json) {
    final List<_SecTickerEntry> entries = <_SecTickerEntry>[];
    for (final Object? raw in json.values) {
      if (raw is! Map<String, dynamic>) {
        throw const ParsingFailure(
          technicalDetail: 'SEC ticker index contains a non-object row',
        );
      }
      final Object? rawCik = raw['cik_str'];
      if (rawCik is! int) {
        throw const ParsingFailure(
          technicalDetail: 'SEC ticker index row has no integer cik_str',
        );
      }
      entries.add(
        _SecTickerEntry(
          cik: SecEdgarProvider._normalizeCik(rawCik.toString()),
          ticker: SecEdgarProvider._text(raw['ticker'], 'ticker').toUpperCase(),
          title: SecEdgarProvider._text(raw['title'], 'title'),
        ),
      );
    }
    return _SecTickerIndex(List<_SecTickerEntry>.unmodifiable(entries));
  }

  final List<_SecTickerEntry> entries;

  _SecTickerEntry? exactTicker(String ticker) {
    final String normalized = ticker.trim().toUpperCase();
    for (final _SecTickerEntry entry in entries) {
      if (entry.ticker == normalized) {
        return entry;
      }
    }
    return null;
  }

  List<Instrument> search(String query, {required int limit}) {
    final String normalized = query.toUpperCase();
    final List<_SecTickerEntry> matches =
        entries
            .where(
              (_SecTickerEntry entry) =>
                  entry.ticker.contains(normalized) ||
                  entry.title.toUpperCase().contains(normalized),
            )
            .toList()
          ..sort((_SecTickerEntry a, _SecTickerEntry b) {
            final bool aExact = a.ticker == normalized;
            final bool bExact = b.ticker == normalized;
            if (aExact != bExact) {
              return aExact ? -1 : 1;
            }
            return a.ticker.compareTo(b.ticker);
          });
    return matches
        .take(limit)
        .map(
          (_SecTickerEntry entry) => Instrument(
            internalId: Instrument.buildInternalId(
              symbol: entry.ticker,
              exchange: 'SEC',
            ),
            symbol: entry.ticker,
            name: entry.title,
            currency: Currency.usd,
            country: 'US',
            providerMappings: <ProviderMapping>[
              ProviderMapping(
                providerId: SecEdgarProvider.providerId,
                symbol: entry.ticker,
                providerInstrumentId: entry.cik,
              ),
            ],
          ),
        )
        .toList(growable: false);
  }
}

final class _SecDividendFact {
  const _SecDividendFact({
    required this.frame,
    required this.frameYear,
    required this.quarter,
    required this.periodStart,
    required this.periodEnd,
    required this.filedAt,
    required this.amount,
    required this.currency,
  });

  static _SecDividendFact? tryParse(
    Map<String, dynamic> json,
    Currency currency,
  ) {
    final Object? rawFrame = json['frame'];
    final Object? rawValue = json['val'];
    if (rawFrame is! String || rawValue is! num) {
      return null;
    }
    final RegExpMatch? quarter = SecEdgarProvider._quarterFrame.firstMatch(
      rawFrame,
    );
    final RegExpMatch? annual = SecEdgarProvider._annualFrame.firstMatch(
      rawFrame,
    );
    if (quarter == null && annual == null) {
      return null;
    }
    return _SecDividendFact(
      frame: rawFrame,
      frameYear: int.parse((quarter ?? annual)!.group(1)!),
      quarter: quarter == null ? null : int.parse(quarter.group(2)!),
      periodStart: SecEdgarProvider._date(json['start'], 'fact start'),
      periodEnd: SecEdgarProvider._date(json['end'], 'fact end'),
      filedAt: SecEdgarProvider._date(json['filed'], 'fact filed'),
      amount: Decimal.parse(rawValue.toString()),
      currency: currency,
    );
  }

  final String frame;
  final int frameYear;
  final int? quarter;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime filedAt;
  final Decimal amount;
  final Currency currency;
}
