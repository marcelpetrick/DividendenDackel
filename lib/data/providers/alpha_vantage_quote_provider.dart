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
import 'package:http/http.dart' as http;

/// Quotes from Alpha Vantage, using a credential the user supplies.
///
/// This exists because no keyless source prices German listings. Stooq now
/// serves a bot challenge, Yahoo's endpoints are unofficial, and the free
/// tiers of Twelve Data, Finnhub and FMP cover US equities only. Alpha Vantage
/// is the one free tier that answers for Xetra, through a `.DEX` suffix.
///
/// The free tier allows 25 requests per day and returns one symbol per call,
/// which is why the coordinator carries a daily budget: without it a single
/// portfolio refresh spends a user's whole day.
///
/// The tier also returns end-of-day prices rather than live ones. That suits a
/// dividend tracker, but it means a quote is a closing price and is labelled by
/// its own trading day, never as the current market price.
final class AlphaVantageQuoteProvider implements QuoteDataProvider {
  /// Creates the adapter with an injectable transport, clock and credential.
  AlphaVantageQuoteProvider(this._client, this._clock, this._readApiKey);

  /// Stable provider id used in mappings, settings and provenance.
  static const String providerId = 'alpha_vantage';

  /// Free-tier quota, published by Alpha Vantage as 25 requests per day.
  static const int freeTierDailyRequests = 25;

  /// Suffix Alpha Vantage uses for Xetra-listed shares, e.g. `ALV.DEX`.
  static const String xetraSuffix = '.DEX';

  /// Venue codes this adapter treats as German, matching the OpenFIGI adapter.
  static const Set<String> germanExchangeCodes = <String>{'GY', 'GR', 'GF'};

  static final Uri _base = Uri.parse('https://www.alphavantage.co/query');

  final http.Client _client;
  final Clock _clock;
  final Future<String?> Function() _readApiKey;

  @override
  String get id => providerId;

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.quote,
  };

  /// The symbol Alpha Vantage expects for [instrument].
  ///
  /// A German listing needs the venue suffix; anything else is sent as-is, so
  /// a US ticker keeps working unchanged.
  static String symbolFor(Instrument instrument) {
    final String? mapped = instrument.providerMappings
        .where((ProviderMapping m) => m.providerId == providerId)
        .map((ProviderMapping m) => m.symbol)
        .firstOrNull;
    if (mapped != null && mapped.isNotEmpty) return mapped;
    final bool german =
        germanExchangeCodes.contains(instrument.exchange) ||
        instrument.country == 'DE';
    return german ? '${instrument.symbol}$xetraSuffix' : instrument.symbol;
  }

  @override
  Future<Result<Quote>> fetchQuote(
    Instrument instrument, {
    required CancellationToken cancellationToken,
  }) => Result.guardAsync<Quote>(() async {
    final String? apiKey = await _readApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const AuthenticationFailure(
        technicalDetail: 'No Alpha Vantage credential is stored',
      );
    }
    final String symbol = symbolFor(instrument);
    final Map<String, dynamic> json = await _getJson(
      _base.replace(
        queryParameters: <String, String>{
          'function': 'GLOBAL_QUOTE',
          'symbol': symbol,
          'apikey': apiKey,
        },
      ),
      cancellationToken,
      symbol: symbol,
    );

    final Object? quote = json['Global Quote'];
    if (quote is! Map<String, dynamic> || quote.isEmpty) {
      throw NoDataFailure(
        technicalDetail: 'Alpha Vantage returned no quote for $symbol',
      );
    }
    return _parse(quote, instrument: instrument, symbol: symbol);
  });

  Quote _parse(
    Map<String, dynamic> quote, {
    required Instrument instrument,
    required String symbol,
  }) {
    final Decimal? price = _decimal(quote['05. price']);
    if (price == null) {
      throw ParsingFailure(
        technicalDetail: 'Alpha Vantage quote for $symbol has no usable price',
      );
    }
    // A closing price of zero is not a price. Passing it through would put a
    // confident wrong number in front of the user, which is the defect the
    // bundled sample data had.
    if (price <= Decimal.zero) {
      throw ParsingFailure(
        technicalDetail:
            'Alpha Vantage reported a non-positive price for '
            '$symbol',
      );
    }
    final Decimal? previous = _decimal(quote['08. previous close']);
    final DateTime asOf =
        _tradingDay(quote['07. latest trading day']) ?? _clock.now().toUtc();
    return Quote(
      instrumentId: instrument.internalId,
      price: Money(price, instrument.currency),
      previousClose: previous == null || previous <= Decimal.zero
          ? null
          : Money(previous, instrument.currency),
      // The free tier reports a closing price, so the quote is dated by its
      // trading day rather than by when it happened to be downloaded.
      asOf: asOf,
      provenance: Provenance(
        source: providerId,
        fetchedAt: _clock.now().toUtc(),
        confidence: Confidence.high,
      ),
    );
  }

  static Decimal? _decimal(Object? raw) {
    if (raw is! String) return null;
    final String trimmed = raw.trim();
    return trimmed.isEmpty ? null : Decimal.tryParse(trimmed);
  }

  static DateTime? _tradingDay(Object? raw) {
    if (raw is! String) return null;
    final DateTime? parsed = DateTime.tryParse(raw.trim());
    return parsed == null
        ? null
        : DateTime.utc(parsed.year, parsed.month, parsed.day);
  }

  Future<Map<String, dynamic>> _getJson(
    Uri uri,
    CancellationToken cancellationToken, {
    required String symbol,
  }) async {
    cancellationToken.throwIfCancelled();
    try {
      final http.Response response = await Future.any(<Future<http.Response>>[
        _client.get(
          uri,
          headers: const <String, String>{
            HttpHeaders.acceptHeader: 'application/json',
          },
        ),
        cancellationToken.whenCancelled.then<http.Response>(
          (_) => throw const CancelledFailure(),
        ),
      ]);
      cancellationToken.throwIfCancelled();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ProviderUnavailableFailure(
          technicalDetail: 'Alpha Vantage HTTP ${response.statusCode}',
        );
      }
      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ParsingFailure(
          technicalDetail:
              'Alpha Vantage returned ${decoded.runtimeType} for '
              '$symbol, wanted an object',
        );
      }
      _throwOnAdvisory(decoded, symbol: symbol);
      return decoded;
    } on FormatException catch (error) {
      throw ParsingFailure(technicalDetail: 'Alpha Vantage response: $error');
    } on http.ClientException catch (error) {
      throw NetworkFailure(technicalDetail: '$error');
    } on SocketException catch (error) {
      throw NetworkFailure(technicalDetail: '$error');
    }
  }

  /// Alpha Vantage answers 200 OK for errors, so the body decides the failure.
  ///
  /// An exhausted quota, an unknown symbol and a rejected key all arrive as a
  /// success with an advisory string. Treating those as data would cache a
  /// missing price as though it were a real answer.
  static void _throwOnAdvisory(
    Map<String, dynamic> body, {
    required String symbol,
  }) {
    // `Note` is the throttling message and has been for years, whatever
    // wording it carries -- matching on phrases like "requests per day" missed
    // the older "5 calls per minute and 500 calls per day" text.
    final Object? note = body['Note'];
    if (note is String && note.isNotEmpty) {
      throw RateLimitFailure(technicalDetail: 'Alpha Vantage: $note');
    }
    // `Information` carries both the newer quota notice and genuine advisories
    // such as an endpoint being premium-only, so here the wording decides.
    final Object? information = body['Information'];
    if (information is String && information.isNotEmpty) {
      final String lower = information.toLowerCase();
      final bool throttled =
          lower.contains('rate limit') ||
          lower.contains('per day') ||
          lower.contains('per minute') ||
          lower.contains('call frequency') ||
          lower.contains('call volume');
      throw throttled
          ? RateLimitFailure(technicalDetail: 'Alpha Vantage: $information')
          : ProviderUnavailableFailure(
              technicalDetail: 'Alpha Vantage: $information',
            );
    }
    final Object? error = body['Error Message'];
    if (error is String && error.isNotEmpty) {
      // An unrecognised symbol is reported this way, which for this app means
      // the venue suffix did not match rather than that the provider is down.
      throw NoDataFailure(
        technicalDetail: 'Alpha Vantage rejected $symbol: $error',
      );
    }
  }
}
