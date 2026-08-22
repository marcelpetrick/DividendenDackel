import 'dart:io';

import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/data/providers/frankfurter_fx_provider.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/fake_clock.dart';

void main() {
  const String fixturePath = 'test/fixtures/frankfurter/ecb_rates.json';
  final DateTime now = DateTime.utc(2026, 8, 22, 12);
  final DateRange range = DateRange(
    DateTime.utc(2026, 8, 10),
    DateTime.utc(2026, 8, 12),
  );

  test('requests only ECB rates and normalizes the v2 contract', () async {
    late http.Request request;
    final FrankfurterFxProvider provider = FrankfurterFxProvider(
      MockClient((http.Request incoming) async {
        request = incoming;
        return http.Response(await File(fixturePath).readAsString(), 200);
      }),
      FakeClock(now),
    );

    final Result<List<FxRate>> result = await provider.fetchFxRates(
      Currency.eur,
      <Currency>{Currency.usd, Currency.gbp},
      range,
      cancellationToken: CancellationToken(),
    );

    expect(request.url.path, '/v2/rates');
    expect(request.url.queryParameters['providers'], 'ECB');
    expect(request.url.queryParameters['base'], 'EUR');
    expect(request.url.queryParameters['quotes'], 'GBP,USD');
    expect(request.url.queryParameters['from'], '2026-08-10');
    expect(
      request.url.queryParameters['to'],
      '2026-08-11',
      reason: 'provider range is inclusive; domain range is half-open',
    );
    final List<FxRate> rates = result.valueOrNull!;
    expect(rates, hasLength(4));
    expect(rates.first.quote, Currency.gbp);
    expect(rates.first.rate.toString(), '0.85565');
    expect(rates.last.observedAt, DateTime.utc(2026, 8, 11));
    expect(rates.last.provenance.source, 'frankfurter');
    expect(rates.last.provenance.fetchedAt, now);
    expect(rates.last.provenance.reportedCurrency, Currency.usd);
  });

  test('rejects rows outside the requested pairs', () async {
    final FrankfurterFxProvider provider = FrankfurterFxProvider(
      MockClient(
        (_) async => http.Response(
          '[{"date":"2026-08-10","base":"EUR",'
          '"quote":"JPY","rate":180}]',
          200,
        ),
      ),
      FakeClock(now),
    );

    final Result<List<FxRate>> result = await provider.fetchFxRates(
      Currency.eur,
      <Currency>{Currency.usd},
      range,
      cancellationToken: CancellationToken(),
    );

    expect(result.failureOrNull, isA<ParsingFailure>());
  });

  test('rejects duplicate rows instead of silently choosing one', () async {
    const String duplicate =
        '[{"date":"2026-08-10","base":"EUR",'
        '"quote":"USD","rate":1.1},'
        '{"date":"2026-08-10","base":"EUR",'
        '"quote":"USD","rate":1.2}]';
    final FrankfurterFxProvider provider = FrankfurterFxProvider(
      MockClient((_) async => http.Response(duplicate, 200)),
      FakeClock(now),
    );

    final Result<List<FxRate>> result = await provider.fetchFxRates(
      Currency.eur,
      <Currency>{Currency.usd},
      range,
      cancellationToken: CancellationToken(),
    );

    expect(result.failureOrNull, isA<ParsingFailure>());
  });

  test('maps an invalid provider rate to a parsing failure', () async {
    final FrankfurterFxProvider provider = FrankfurterFxProvider(
      MockClient(
        (_) async => http.Response(
          '[{"date":"2026-08-10","base":"EUR",'
          '"quote":"USD","rate":0}]',
          200,
        ),
      ),
      FakeClock(now),
    );

    final Result<List<FxRate>> result = await provider.fetchFxRates(
      Currency.eur,
      <Currency>{Currency.usd},
      range,
      cancellationToken: CancellationToken(),
    );

    expect(result.failureOrNull, isA<ParsingFailure>());
  });

  test('maps provider validation and throttling to typed failures', () async {
    final FrankfurterFxProvider invalid = FrankfurterFxProvider(
      MockClient((_) async => http.Response('{"message":"bad"}', 422)),
      FakeClock(now),
    );
    final FrankfurterFxProvider limited = FrankfurterFxProvider(
      MockClient(
        (_) async => http.Response(
          '',
          429,
          headers: <String, String>{'retry-after': '60'},
        ),
      ),
      FakeClock(now),
    );

    final Result<List<FxRate>> invalidResult = await invalid.fetchFxRates(
      Currency.eur,
      <Currency>{Currency.usd},
      range,
      cancellationToken: CancellationToken(),
    );
    final Result<List<FxRate>> limitedResult = await limited.fetchFxRates(
      Currency.eur,
      <Currency>{Currency.usd},
      range,
      cancellationToken: CancellationToken(),
    );

    expect(invalidResult.failureOrNull, isA<InvalidInstrumentFailure>());
    expect(limitedResult.failureOrNull, isA<RateLimitFailure>());
    expect(
      (limitedResult.failureOrNull! as RateLimitFailure).retryAt,
      now.add(const Duration(minutes: 1)),
    );
  });

  test('returns no-data for an empty successful response', () async {
    final FrankfurterFxProvider provider = FrankfurterFxProvider(
      MockClient((_) async => http.Response('[]', 200)),
      FakeClock(now),
    );

    final Result<List<FxRate>> result = await provider.fetchFxRates(
      Currency.eur,
      <Currency>{Currency.usd},
      range,
      cancellationToken: CancellationToken(),
    );

    expect(result.failureOrNull, isA<NoDataFailure>());
  });
}
