import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:http/http.dart' as http;

/// Keyless adapter for OpenFIGI, so instruments outside the US can be found.
///
/// The app could previously only discover what SEC EDGAR lists plus the ten
/// entries in the bundled reference file, so a user searching for a German
/// listing was told "no matching instrument found" and had no way forward.
///
/// OpenFIGI maps ISINs and tickers to listings on every venue it knows,
/// including the German ones, and needs no credential. It answers *what an
/// instrument is*, never what it is worth: there are no prices here, and a
/// found instrument still shows no value until a quote source covers it.
final class OpenFigiProvider implements InstrumentSearchProvider {
  /// Creates the adapter with an injectable transport.
  OpenFigiProvider(this._client);

  /// Stable provider id used in mappings, settings and provenance.
  static const String providerId = 'openfigi';

  /// Declared identity, as the SEC adapter does. OpenFIGI does not require it.
  static const String userAgent = 'DividendenDackel mail@marcelpetrick.it';

  /// Unauthenticated quota, reported by the API as `ratelimit-policy: 25;w=60`.
  ///
  /// Kept here so [RequestCoordinator] can be configured from the documented
  /// number rather than a guess.
  static const int requestsPerMinute = 25;

  /// Venue codes searched for a plain-text query, most specific first.
  ///
  /// `GY` is Xetra, which is the reference venue for German equities; the
  /// others are the regional German exchanges. US venues are covered by SEC
  /// EDGAR, so this adapter deliberately complements rather than duplicates it.
  static const List<String> germanExchangeCodes = <String>['GY', 'GR', 'GF'];

  static final Uri _mappingUri = Uri.parse(
    'https://api.openfigi.com/v3/mapping',
  );
  static final Uri _searchUri = Uri.parse('https://api.openfigi.com/v3/search');
  static final RegExp _isin = RegExp(r'^[A-Z]{2}[A-Z0-9]{9}[0-9]$');

  final http.Client _client;

  @override
  String get id => providerId;

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.instrumentSearch,
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
        message: 'Enter a symbol, company name or ISIN.',
      );
    }
    if (limit <= 0) {
      throw ArgumentError.value(limit, 'limit', 'must be positive');
    }

    // An ISIN identifies one security exactly, so it is worth a precise
    // mapping call before falling back to a text search over names.
    final List<Instrument> found = _isin.hasMatch(normalized.toUpperCase())
        ? await _byIsin(normalized.toUpperCase(), cancellationToken)
        : await _byText(normalized, limit: limit, token: cancellationToken);

    if (found.isEmpty) {
      throw NoDataFailure(
        technicalDetail: 'OpenFIGI has no listing matching $normalized',
      );
    }
    return found.take(limit).toList(growable: false);
  });

  Future<List<Instrument>> _byIsin(
    String isin,
    CancellationToken cancellationToken,
  ) async {
    final List<dynamic> payload = await _post(
      _mappingUri,
      <Map<String, String>>[
        <String, String>{'idType': 'ID_ISIN', 'idValue': isin},
      ],
      cancellationToken,
    );
    final List<Map<String, dynamic>> rows = <Map<String, dynamic>>[];
    for (final dynamic job in payload) {
      if (job is! Map<String, dynamic>) continue;
      final Object? data = job['data'];
      if (data is List<dynamic>) {
        rows.addAll(data.whereType<Map<String, dynamic>>());
      }
    }
    return _instrumentsFrom(rows, isin: isin);
  }

  Future<List<Instrument>> _byText(
    String query, {
    required int limit,
    required CancellationToken token,
  }) async {
    // One request per venue would spend the quota quickly, so the venues are
    // tried in order and the first that answers wins.
    for (final String exchange in germanExchangeCodes) {
      final Object? payload = await _postObject(_searchUri, <String, String>{
        'query': query,
        'exchCode': exchange,
      }, token);
      if (payload is! Map<String, dynamic>) continue;
      final Object? data = payload['data'];
      if (data is! List<dynamic>) continue;
      final List<Instrument> found = _instrumentsFrom(
        data.whereType<Map<String, dynamic>>().toList(growable: false),
      );
      if (found.isNotEmpty) return found;
    }
    return const <Instrument>[];
  }

  /// Collapses OpenFIGI's per-venue rows into one instrument per ticker.
  ///
  /// A single ISIN maps to well over a hundred listings — Allianz alone
  /// returns more than a hundred — because every venue and every share class
  /// is its own record. Showing that list would be useless, so rows are
  /// reduced to one entry per ticker, preferring the earliest venue in
  /// [germanExchangeCodes].
  List<Instrument> _instrumentsFrom(
    List<Map<String, dynamic>> rows, {
    String? isin,
  }) {
    final Map<String, _Listing> best = <String, _Listing>{};
    for (final Map<String, dynamic> row in rows) {
      if (row['marketSector'] != 'Equity') continue;
      final Object? ticker = row['ticker'];
      final Object? name = row['name'];
      final Object? exchange = row['exchCode'];
      if (ticker is! String ||
          name is! String ||
          exchange is! String ||
          ticker.isEmpty ||
          name.isEmpty) {
        continue;
      }
      final int rank = germanExchangeCodes.indexOf(exchange);
      if (rank < 0) continue;
      final _Listing? existing = best[ticker];
      if (existing == null || rank < existing.rank) {
        best[ticker] = _Listing(
          rank: rank,
          instrument: Instrument(
            // FIGI is stable and venue-specific; ISIN identifies the security
            // across venues, so it is preferred when the caller supplied one.
            internalId: isin == null
                ? 'figi:${row['compositeFIGI'] ?? row['figi']}'
                : 'isin:$isin',
            symbol: ticker,
            name: name,
            // OpenFIGI does not report a trading currency. German venues quote
            // in EUR, and the venue filter above admits only those, so this is
            // asserted from the venue rather than invented.
            currency: Currency.eur,
            exchange: exchange,
            isin: isin,
            country: 'DE',
            providerMappings: <ProviderMapping>[
              ProviderMapping(
                providerId: providerId,
                symbol: ticker,
                providerInstrumentId: row['figi'] as String?,
              ),
            ],
          ),
        );
      }
    }
    final List<_Listing> ordered = best.values.toList(growable: false)
      ..sort((_Listing a, _Listing b) {
        final int byRank = a.rank.compareTo(b.rank);
        return byRank != 0
            ? byRank
            : a.instrument.name.compareTo(b.instrument.name);
      });
    return ordered
        .map((_Listing listing) => listing.instrument)
        .toList(growable: false);
  }

  Future<List<dynamic>> _post(
    Uri uri,
    List<Map<String, String>> body,
    CancellationToken cancellationToken,
  ) async {
    final Object? decoded = await _send(uri, body, cancellationToken);
    if (decoded is! List<dynamic>) {
      throw ParsingFailure(
        technicalDetail:
            'OpenFIGI returned ${decoded.runtimeType}, wanted a '
            'list from $uri',
      );
    }
    return decoded;
  }

  Future<Object?> _postObject(
    Uri uri,
    Map<String, String> body,
    CancellationToken cancellationToken,
  ) => _send(uri, body, cancellationToken);

  Future<Object?> _send(
    Uri uri,
    Object body,
    CancellationToken cancellationToken,
  ) async {
    cancellationToken.throwIfCancelled();
    try {
      final http.Response response = await Future.any(<Future<http.Response>>[
        _client.post(
          uri,
          headers: const <String, String>{
            HttpHeaders.userAgentHeader: userAgent,
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.acceptHeader: 'application/json',
          },
          body: jsonEncode(body),
        ),
        cancellationToken.whenCancelled.then<http.Response>(
          (_) => throw const CancelledFailure(),
        ),
      ]);
      cancellationToken.throwIfCancelled();
      if (response.statusCode == HttpStatus.tooManyRequests) {
        throw RateLimitFailure(
          retryAt: _retryAt(response.headers['ratelimit-reset']),
          technicalDetail: 'OpenFIGI HTTP 429',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ProviderUnavailableFailure(
          technicalDetail: 'OpenFIGI HTTP ${response.statusCode} for $uri',
        );
      }
      return jsonDecode(response.body);
    } on FormatException catch (error) {
      throw ParsingFailure(technicalDetail: 'OpenFIGI response: $error');
    } on http.ClientException catch (error) {
      throw NetworkFailure(technicalDetail: '$error');
    } on SocketException catch (error) {
      throw NetworkFailure(technicalDetail: '$error');
    }
  }

  /// Reads `ratelimit-reset`, which OpenFIGI reports in whole seconds.
  static DateTime? _retryAt(String? header) {
    final int? seconds = header == null ? null : int.tryParse(header.trim());
    return seconds == null
        ? null
        : DateTime.now().toUtc().add(Duration(seconds: seconds));
  }
}

/// One venue's listing, kept with its venue preference for deduplication.
final class _Listing {
  const _Listing({required this.rank, required this.instrument});

  final int rank;
  final Instrument instrument;
}
