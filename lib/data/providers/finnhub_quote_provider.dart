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

/// Quotes from Finnhub, using a credential the user supplies.
///
/// Complements Alpha Vantage rather than replacing it. Alpha Vantage is the
/// only free tier that prices German listings, but it allows 25 requests a day;
/// Finnhub's free tier is far more generous and covers US listings, so a
/// US-heavy portfolio can be refreshed properly.
///
/// Finnhub's personal plan is for personal use. Business use needs their
/// written approval and redistribution is prohibited, which is why the app
/// never ships a key, never forwards a quote anywhere, and says so where the
/// key is asked for.
final class FinnhubQuoteProvider implements QuoteDataProvider {
  /// Creates the adapter with an injectable transport, clock and credential.
  FinnhubQuoteProvider(this._client, this._clock, this._readApiKey);

  /// Stable provider id used in mappings, settings and provenance.
  static const String providerId = 'finnhub';

  /// Venue codes Finnhub answers for without a suffix.
  ///
  /// The free tier is US equities. Sending a German ticker unsuffixed would
  /// resolve a US listing of the same name, so anything else is refused rather
  /// than guessed (Vision.md §79).
  static const Set<String> supportedExchangeCodes = <String>{
    'US',
    'UN',
    'UQ',
    'UA',
    'UP',
    'UR',
    'UW',
  };

  static final Uri _base = Uri.parse('https://finnhub.io/api/v1/quote');

  final http.Client _client;
  final Clock _clock;
  final Future<String?> Function() _readApiKey;

  @override
  String get id => providerId;

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.quote,
  };

  /// The symbol Finnhub expects for [instrument], or null when unsupported.
  static String? symbolFor(Instrument instrument) {
    final String? mapped = instrument.providerMappings
        .where((ProviderMapping m) => m.providerId == providerId)
        .map((ProviderMapping m) => m.symbol)
        .firstOrNull;
    if (mapped != null && mapped.isNotEmpty) return mapped;
    final String? venue = instrument.exchange;
    if (supportedExchangeCodes.contains(venue) ||
        (venue == null && instrument.country == 'US')) {
      return instrument.symbol;
    }
    return null;
  }

  @override
  Future<Result<Quote>> fetchQuote(
    Instrument instrument, {
    required CancellationToken cancellationToken,
  }) => Result.guardAsync<Quote>(() async {
    final String? apiKey = await _readApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const AuthenticationFailure(
        technicalDetail: 'No Finnhub credential is stored',
      );
    }
    final String? symbol = symbolFor(instrument);
    if (symbol == null) {
      throw NoDataFailure(
        technicalDetail:
            'Finnhub covers US listings; no rule for venue '
            '${instrument.exchange ?? instrument.country ?? 'unknown'}',
      );
    }

    final Map<String, dynamic> json = await _getJson(
      _base.replace(
        queryParameters: <String, String>{'symbol': symbol, 'token': apiKey},
      ),
      cancellationToken,
      symbol: symbol,
    );

    final Decimal? price = _decimal(json['c']);
    // Finnhub answers 200 with every field zero for a symbol it does not know.
    // Treating that as a price would put 0.00 in front of the user as though a
    // real company were worth nothing.
    if (price == null || price <= Decimal.zero) {
      throw NoDataFailure(technicalDetail: 'Finnhub has no price for $symbol');
    }
    final Decimal? previous = _decimal(json['pc']);
    return Quote(
      instrumentId: instrument.internalId,
      price: Money(price, instrument.currency),
      previousClose: previous == null || previous <= Decimal.zero
          ? null
          : Money(previous, instrument.currency),
      asOf: _asOf(json['t']) ?? _clock.now().toUtc(),
      provenance: Provenance(
        source: providerId,
        fetchedAt: _clock.now().toUtc(),
        confidence: Confidence.high,
      ),
    );
  });

  static Decimal? _decimal(Object? raw) => switch (raw) {
    final num value => Decimal.tryParse(value.toString()),
    final String value when value.trim().isNotEmpty => Decimal.tryParse(
      value.trim(),
    ),
    _ => null,
  };

  /// Finnhub timestamps the quote in whole seconds since the epoch.
  static DateTime? _asOf(Object? raw) {
    final int? seconds = switch (raw) {
      final int value => value,
      final num value => value.toInt(),
      _ => null,
    };
    return seconds == null || seconds <= 0
        ? null
        : DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);
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
      if (response.statusCode == HttpStatus.tooManyRequests) {
        throw const RateLimitFailure(technicalDetail: 'Finnhub HTTP 429');
      }
      if (response.statusCode == HttpStatus.unauthorized ||
          response.statusCode == HttpStatus.forbidden) {
        throw AuthenticationFailure(
          technicalDetail:
              'Finnhub rejected the credential '
              '(HTTP ${response.statusCode})',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ProviderUnavailableFailure(
          technicalDetail: 'Finnhub HTTP ${response.statusCode}',
        );
      }
      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ParsingFailure(
          technicalDetail:
              'Finnhub returned ${decoded.runtimeType} for '
              '$symbol, wanted an object',
        );
      }
      // An invalid key is reported in the body with a 200 status.
      if (decoded['error'] case final String error when error.isNotEmpty) {
        throw AuthenticationFailure(technicalDetail: 'Finnhub: $error');
      }
      return decoded;
    } on FormatException catch (error) {
      throw ParsingFailure(technicalDetail: 'Finnhub response: $error');
    } on http.ClientException catch (error) {
      throw NetworkFailure(technicalDetail: '$error');
    } on SocketException catch (error) {
      throw NetworkFailure(technicalDetail: '$error');
    }
  }
}
