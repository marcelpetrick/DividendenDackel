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

/// Keyless Frankfurter adapter restricted to official ECB reference rates.
final class FrankfurterFxProvider implements FxRateDataProvider {
  /// Creates the adapter with an injectable transport and time source.
  FrankfurterFxProvider(this._client, this._clock);

  /// Stable provider id used by settings and provenance.
  static const String providerId = 'frankfurter';

  final http.Client _client;
  final Clock _clock;

  @override
  String get id => providerId;

  @override
  Set<ProviderDataType> get capabilities => const <ProviderDataType>{
    ProviderDataType.fxRates,
  };

  @override
  Future<Result<List<FxRate>>> fetchFxRates(
    Currency base,
    Set<Currency> quotes,
    DateRange range, {
    required CancellationToken cancellationToken,
  }) => Result.guardAsync<List<FxRate>>(() async {
    if (quotes.isEmpty) {
      throw ArgumentError.value(quotes, 'quotes', 'must not be empty');
    }
    final List<String> quoteCodes =
        quotes.map((Currency currency) => currency.code).toSet().toList()
          ..sort();
    final DateTime startUtc = range.start.toUtc();
    final DateTime startDay = DateTime.utc(
      startUtc.year,
      startUtc.month,
      startUtc.day,
    );
    final DateTime firstIncludedDay = startUtc == startDay
        ? startDay
        : startDay.add(const Duration(days: 1));
    final DateTime inclusiveEnd = range.end.toUtc().subtract(
      const Duration(microseconds: 1),
    );
    if (firstIncludedDay.isAfter(inclusiveEnd)) {
      throw NoDataFailure(
        technicalDetail: 'No complete UTC reference-rate day exists in $range',
      );
    }
    final Uri uri = Uri.https(
      'api.frankfurter.dev',
      '/v2/rates',
      <String, String>{
        'from': _dateText(firstIncludedDay),
        'to': _dateText(inclusiveEnd),
        'base': base.code,
        'quotes': quoteCodes.join(','),
        // V2 blends providers by default. This filter is non-negotiable: the
        // product promises official ECB reference rates and attribution.
        'providers': 'ECB',
      },
    );
    final List<dynamic> json = await _getJsonArray(uri, cancellationToken);
    final Set<String> seen = <String>{};
    final List<FxRate> result = <FxRate>[];
    for (final Object? raw in json) {
      if (raw is! Map<String, dynamic>) {
        throw const ParsingFailure(
          technicalDetail: 'Frankfurter rate row is not a JSON object',
        );
      }
      final Currency rowBase = Currency.parse(_text(raw, 'base'));
      final Currency quote = Currency.parse(_text(raw, 'quote'));
      final DateTime observedAt = _date(raw, 'date');
      final Object? rawRate = raw['rate'];
      if (rawRate is! num) {
        throw const ParsingFailure(
          technicalDetail: 'Frankfurter rate is not numeric',
        );
      }
      final Decimal parsedRate = Decimal.parse(rawRate.toString());
      if (parsedRate <= Decimal.zero ||
          (rowBase == quote && parsedRate != Decimal.one)) {
        throw ParsingFailure(
          technicalDetail:
              'Frankfurter returned invalid ${rowBase.code}/${quote.code} '
              'rate $parsedRate',
        );
      }
      if (rowBase.code != base.code || !quoteCodes.contains(quote.code)) {
        throw ParsingFailure(
          technicalDetail:
              'Frankfurter returned unexpected pair '
              '${rowBase.code}/${quote.code}',
        );
      }
      if (!range.contains(observedAt)) {
        throw ParsingFailure(
          technicalDetail:
              'Frankfurter returned ${_dateText(observedAt)} outside $range',
        );
      }
      final String key = '${rowBase.code}:${quote.code}:$observedAt';
      if (!seen.add(key)) {
        throw ParsingFailure(
          technicalDetail: 'Frankfurter returned duplicate rate $key',
        );
      }
      result.add(
        FxRate(
          base: rowBase,
          quote: quote,
          rate: parsedRate,
          observedAt: observedAt,
          provenance: Provenance(
            source: providerId,
            fetchedAt: _clock.now(),
            updatedAt: observedAt,
            reportedCurrency: quote,
          ),
        ),
      );
    }
    if (result.isEmpty) {
      throw NoDataFailure(
        technicalDetail:
            'Frankfurter/ECB has no ${base.code}/${quoteCodes.join(',')} '
            'rates inside $range',
      );
    }
    result.sort((FxRate a, FxRate b) {
      final int dateOrder = a.observedAt.compareTo(b.observedAt);
      return dateOrder != 0 ? dateOrder : a.quote.code.compareTo(b.quote.code);
    });
    return result;
  });

  Future<List<dynamic>> _getJsonArray(
    Uri uri,
    CancellationToken cancellationToken,
  ) async {
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
        throw RateLimitFailure(
          retryAt: _retryAt(response.headers[HttpHeaders.retryAfterHeader]),
          technicalDetail: 'Frankfurter HTTP 429',
        );
      }
      if (response.statusCode == HttpStatus.badRequest ||
          response.statusCode == HttpStatus.unprocessableEntity) {
        throw InvalidInstrumentFailure(
          technicalDetail: 'Frankfurter rejected request $uri',
        );
      }
      if (response.statusCode == HttpStatus.notFound) {
        throw NoDataFailure(
          technicalDetail: 'Frankfurter returned 404 for $uri',
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ProviderUnavailableFailure(
          statusCode: response.statusCode,
          technicalDetail: 'Frankfurter request failed for $uri',
        );
      }
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List<dynamic>) {
        throw const ParsingFailure(
          technicalDetail: 'Frankfurter response is not a JSON array',
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

  static String _text(Map<String, dynamic> json, String field) {
    final Object? value = json[field];
    if (value is! String || value.trim().isEmpty) {
      throw ParsingFailure(technicalDetail: 'Frankfurter $field is missing');
    }
    return value;
  }

  static DateTime _date(Map<String, dynamic> json, String field) {
    final String value = _text(json, field);
    try {
      return DateTime.parse('${value}T00:00:00Z');
    } on FormatException catch (error) {
      throw ParsingFailure(
        technicalDetail: 'Frankfurter $field is not an ISO date: $value',
        cause: error,
      );
    }
  }

  static String _dateText(DateTime date) {
    final DateTime utc = date.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
  }
}
