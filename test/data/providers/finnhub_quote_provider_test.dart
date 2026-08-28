import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/data/providers/finnhub_quote_provider.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/fake_clock.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 28, 18);

  const Instrument apple = Instrument(
    internalId: 'cik:0000320193',
    symbol: 'AAPL',
    name: 'Apple Inc.',
    currency: Currency.usd,
    exchange: 'US',
    country: 'US',
  );
  const Instrument allianz = Instrument(
    internalId: 'isin:DE0008404005',
    symbol: 'ALV',
    name: 'Allianz SE',
    currency: Currency.eur,
    exchange: 'GY',
    country: 'DE',
  );

  FinnhubQuoteProvider providerWith(
    Future<http.Response> Function(http.Request) handler, {
    String? apiKey = 'user-key',
  }) => FinnhubQuoteProvider(
    MockClient(handler),
    FakeClock(now),
    () async => apiKey,
  );

  test('reads the price, previous close and quote time', () async {
    late Uri requested;
    final FinnhubQuoteProvider provider = providerWith((
      http.Request incoming,
    ) async {
      requested = incoming.url;
      return http.Response(
        '{"c":231.5,"d":1.2,"dp":0.52,"h":232,"l":229,"o":230,'
        '"pc":230.3,"t":1787000000}',
        200,
      );
    });

    final Quote quote = (await provider.fetchQuote(
      apple,
      cancellationToken: CancellationToken(),
    )).valueOrNull!;

    expect(requested.queryParameters['symbol'], 'AAPL');
    expect(requested.queryParameters['token'], 'user-key');
    expect(quote.price, Money(Decimal.parse('231.5'), Currency.usd));
    expect(quote.previousClose, Money(Decimal.parse('230.3'), Currency.usd));
    expect(
      quote.asOf,
      DateTime.fromMillisecondsSinceEpoch(1787000000 * 1000, isUtc: true),
    );
    expect(quote.provenance.source, 'finnhub');
  });

  test('an all-zero response is no data, not a company worth nothing', () async {
    // Finnhub answers 200 with every field zero for a symbol it does not know.
    final FinnhubQuoteProvider provider = providerWith(
      (_) async => http.Response(
        '{"c":0,"d":null,"dp":null,"h":0,"l":0,"o":0,"pc":0,"t":0}',
        200,
      ),
    );

    expect(
      (await provider.fetchQuote(
        apple,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<NoDataFailure>(),
    );
  });

  test(
    'a German listing is refused rather than priced from a US ticker',
    () async {
      expect(FinnhubQuoteProvider.symbolFor(allianz), isNull);

      bool called = false;
      final FinnhubQuoteProvider provider = providerWith((_) async {
        called = true;
        return http.Response('{"c":1,"pc":1,"t":1787000000}', 200);
      });

      expect(
        (await provider.fetchQuote(
          allianz,
          cancellationToken: CancellationToken(),
        )).failureOrNull,
        isA<NoDataFailure>(),
      );
      expect(called, isFalse, reason: 'no request, so no quota spent');
    },
  );

  test('an explicit mapping overrides the venue rule', () {
    const Instrument mapped = Instrument(
      internalId: 'isin:DE0008404005',
      symbol: 'ALV',
      name: 'Allianz SE',
      currency: Currency.eur,
      exchange: 'GY',
      country: 'DE',
      providerMappings: <ProviderMapping>[
        ProviderMapping(providerId: 'finnhub', symbol: 'ALV.DE'),
      ],
    );

    expect(FinnhubQuoteProvider.symbolFor(mapped), 'ALV.DE');
  });

  test('a missing credential fails before any request', () async {
    bool called = false;
    final FinnhubQuoteProvider provider = providerWith((_) async {
      called = true;
      return http.Response('{"c":1}', 200);
    }, apiKey: null);

    expect(
      (await provider.fetchQuote(
        apple,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<AuthenticationFailure>(),
    );
    expect(called, isFalse);
  });

  test('an invalid key reported in a 200 body is an auth failure', () async {
    final FinnhubQuoteProvider provider = providerWith(
      (_) async => http.Response('{"error":"Invalid API key."}', 200),
    );

    expect(
      (await provider.fetchQuote(
        apple,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<AuthenticationFailure>(),
    );
  });

  test('401 and 403 are credential problems, not outages', () async {
    for (final int status in <int>[401, 403]) {
      final FinnhubQuoteProvider provider = providerWith(
        (_) async => http.Response('denied', status),
      );
      expect(
        (await provider.fetchQuote(
          apple,
          cancellationToken: CancellationToken(),
        )).failureOrNull,
        isA<AuthenticationFailure>(),
        reason: 'HTTP $status',
      );
    }
  });

  test('429 is a rate limit', () async {
    final FinnhubQuoteProvider provider = providerWith(
      (_) async => http.Response('slow down', 429),
    );

    expect(
      (await provider.fetchQuote(
        apple,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<RateLimitFailure>(),
    );
  });

  test('other HTTP errors are provider outages', () async {
    final FinnhubQuoteProvider provider = providerWith(
      (_) async => http.Response('boom', 503),
    );

    expect(
      (await provider.fetchQuote(
        apple,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<ProviderUnavailableFailure>(),
    );
  });

  test('malformed and wrongly shaped JSON are parsing failures', () async {
    for (final String body in <String>['not json', '[1,2,3]']) {
      final FinnhubQuoteProvider provider = providerWith(
        (_) async => http.Response(body, 200),
      );
      expect(
        (await provider.fetchQuote(
          apple,
          cancellationToken: CancellationToken(),
        )).failureOrNull,
        isA<ParsingFailure>(),
        reason: body,
      );
    }
  });

  test(
    'a missing timestamp falls back to the clock, never to a guess',
    () async {
      final FinnhubQuoteProvider provider = providerWith(
        (_) async => http.Response('{"c":10,"pc":9}', 200),
      );

      final Quote quote = (await provider.fetchQuote(
        apple,
        cancellationToken: CancellationToken(),
      )).valueOrNull!;

      expect(quote.asOf, now);
    },
  );

  test('an unusable previous close is dropped rather than invented', () async {
    final FinnhubQuoteProvider provider = providerWith(
      (_) async => http.Response('{"c":10,"pc":0,"t":1787000000}', 200),
    );

    final Quote quote = (await provider.fetchQuote(
      apple,
      cancellationToken: CancellationToken(),
    )).valueOrNull!;

    expect(quote.previousClose, isNull);
  });

  test('the adapter declares only quotes', () {
    final FinnhubQuoteProvider provider = providerWith(
      (_) async => http.Response('{"c":1}', 200),
    );

    expect(provider.capabilities, <ProviderDataType>{ProviderDataType.quote});
    expect(provider.id, 'finnhub');
  });
}
