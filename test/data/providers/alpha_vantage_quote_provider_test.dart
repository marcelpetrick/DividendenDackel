import 'package:decimal/decimal.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/data/providers/alpha_vantage_quote_provider.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/fake_clock.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 28, 18);

  const Instrument allianz = Instrument(
    internalId: 'isin:DE0008404005',
    symbol: 'ALV',
    name: 'Allianz SE',
    currency: Currency.eur,
    exchange: 'GY',
    isin: 'DE0008404005',
    country: 'DE',
  );
  const Instrument apple = Instrument(
    internalId: 'cik:0000320193',
    symbol: 'AAPL',
    name: 'Apple Inc.',
    currency: Currency.usd,
    exchange: 'US',
    country: 'US',
  );

  AlphaVantageQuoteProvider providerWith(
    Future<http.Response> Function(http.Request) handler, {
    String? apiKey = 'user-key',
  }) => AlphaVantageQuoteProvider(
    MockClient(handler),
    FakeClock(now),
    () async => apiKey,
  );

  String body({
    String price = '451.20',
    String previous = '448.90',
    String day = '2026-08-28',
  }) =>
      '{"Global Quote":{"01. symbol":"ALV.DEX","05. price":"$price",'
      '"07. latest trading day":"$day","08. previous close":"$previous"}}';

  test('a German listing is requested with the Xetra suffix', () async {
    late Uri requested;
    final AlphaVantageQuoteProvider provider = providerWith((
      http.Request incoming,
    ) async {
      requested = incoming.url;
      return http.Response(body(), 200);
    });

    final Result<Quote> result = await provider.fetchQuote(
      allianz,
      cancellationToken: CancellationToken(),
    );

    expect(requested.queryParameters['symbol'], 'ALV.DEX');
    expect(requested.queryParameters['function'], 'GLOBAL_QUOTE');
    final Quote quote = result.valueOrNull!;
    expect(quote.price, Money(Decimal.parse('451.20'), Currency.eur));
    expect(quote.previousClose, Money(Decimal.parse('448.90'), Currency.eur));
    expect(quote.instrumentId, 'isin:DE0008404005');
  });

  test('a US listing keeps its plain symbol', () async {
    late Uri requested;
    final AlphaVantageQuoteProvider provider = providerWith((
      http.Request incoming,
    ) async {
      requested = incoming.url;
      return http.Response(body(), 200);
    });

    await provider.fetchQuote(apple, cancellationToken: CancellationToken());

    expect(requested.queryParameters['symbol'], 'AAPL');
  });

  test('a venue with no symbol rule is refused, not guessed', () async {
    // Alpha Vantage resolves a bare ticker as a US listing. Sending one for a
    // London line would return a different company's price under the right
    // name, which is the failure this app exists to avoid.
    const Instrument london = Instrument(
      internalId: 'isin:GB0007980591',
      symbol: 'BP',
      name: 'BP p.l.c.',
      currency: Currency.eur,
      exchange: 'LN',
      country: 'GB',
    );
    expect(AlphaVantageQuoteProvider.symbolFor(london), isNull);

    bool called = false;
    final AlphaVantageQuoteProvider provider = providerWith((_) async {
      called = true;
      return http.Response(body(), 200);
    });

    expect(
      (await provider.fetchQuote(
        london,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<NoDataFailure>(),
    );
    expect(called, isFalse, reason: 'no request, so no quota spent');
  });

  test('every German venue is priced from Xetra', () {
    for (final String venue in <String>['GY', 'GR', 'GF']) {
      final Instrument listing = Instrument(
        internalId: 'isin:DE0008404005',
        symbol: 'ALV',
        name: 'Allianz SE',
        currency: Currency.eur,
        exchange: venue,
        country: 'DE',
      );
      // A regional listing of the same security is the same company, and Xetra
      // is the reference venue, so this is deliberate rather than approximate.
      expect(AlphaVantageQuoteProvider.symbolFor(listing), 'ALV.DEX');
    }
  });

  test('country decides when a venue is absent', () {
    const Instrument noVenueDe = Instrument(
      internalId: 'isin:DE0008404005',
      symbol: 'ALV',
      name: 'Allianz SE',
      currency: Currency.eur,
      country: 'DE',
    );
    const Instrument noVenueUs = Instrument(
      internalId: 'cik:0000320193',
      symbol: 'AAPL',
      name: 'Apple Inc.',
      currency: Currency.usd,
      country: 'US',
    );
    const Instrument noVenueUnknown = Instrument(
      internalId: 'x',
      symbol: 'XYZ',
      name: 'Somewhere else',
      currency: Currency.eur,
    );

    expect(AlphaVantageQuoteProvider.symbolFor(noVenueDe), 'ALV.DEX');
    expect(AlphaVantageQuoteProvider.symbolFor(noVenueUs), 'AAPL');
    expect(AlphaVantageQuoteProvider.symbolFor(noVenueUnknown), isNull);
  });

  test('an explicit provider mapping wins over the venue guess', () {
    const Instrument mapped = Instrument(
      internalId: 'isin:DE0008404005',
      symbol: 'ALV',
      name: 'Allianz SE',
      currency: Currency.eur,
      exchange: 'GY',
      country: 'DE',
      providerMappings: <ProviderMapping>[
        ProviderMapping(providerId: 'alpha_vantage', symbol: 'ALV.FRK'),
      ],
    );

    expect(AlphaVantageQuoteProvider.symbolFor(mapped), 'ALV.FRK');
  });

  test('the quote is dated by its trading day, not by download time', () async {
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response(body(day: '2026-08-27'), 200),
    );

    final Quote quote = (await provider.fetchQuote(
      allianz,
      cancellationToken: CancellationToken(),
    )).valueOrNull!;

    // The free tier returns a closing price. Stamping it with "now" would
    // present yesterday's close as the current market price.
    expect(quote.asOf, DateTime.utc(2026, 8, 27));
    expect(quote.provenance.fetchedAt, now);
  });

  test('a missing credential fails before any request is made', () async {
    bool called = false;
    final AlphaVantageQuoteProvider provider = providerWith((_) async {
      called = true;
      return http.Response(body(), 200);
    }, apiKey: null);

    final Result<Quote> result = await provider.fetchQuote(
      allianz,
      cancellationToken: CancellationToken(),
    );

    expect(result.failureOrNull, isA<AuthenticationFailure>());
    expect(called, isFalse);
  });

  test(
    'an exhausted quota reported as 200 OK becomes RateLimitFailure',
    () async {
      // Alpha Vantage answers 200 with an advisory string instead of 429.
      final AlphaVantageQuoteProvider provider = providerWith(
        (_) async => http.Response(
          '{"Information":"We have detected your API key ... and our standard '
          'API rate limit is 25 requests per day."}',
          200,
        ),
      );

      expect(
        (await provider.fetchQuote(
          allianz,
          cancellationToken: CancellationToken(),
        )).failureOrNull,
        isA<RateLimitFailure>(),
      );
    },
  );

  test('the legacy Note advisory is also a rate limit', () async {
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response(
        '{"Note":"Thank you for using Alpha Vantage! Our standard API call '
        'frequency is 5 calls per minute and 500 calls per day."}',
        200,
      ),
    );

    expect(
      (await provider.fetchQuote(
        allianz,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<RateLimitFailure>(),
    );
  });

  test(
    'the demo key refusal asks for a key rather than reporting an outage',
    () async {
      // Verbatim from a live call with apikey=demo against a non-demo symbol.
      // Reported as an outage it would look like something to wait out; it is
      // something the user can fix in a minute.
      final AlphaVantageQuoteProvider provider = providerWith(
        (_) async => http.Response(
          '{"Information":"The **demo** API key is for demo purposes only. '
          'Please claim your free API key at '
          '(https://www.alphavantage.co/support/#api-key) to explore our full '
          'API offerings. It takes fewer than 20 seconds."}',
          200,
        ),
      );

      expect(
        (await provider.fetchQuote(
          allianz,
          cancellationToken: CancellationToken(),
        )).failureOrNull,
        isA<AuthenticationFailure>(),
      );
    },
  );

  test('a live GLOBAL_QUOTE response parses field for field', () async {
    // Captured from https://www.alphavantage.co/query with apikey=demo, so the
    // field names here are the provider's own rather than a reading of its
    // documentation.
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response(
        '{"Global Quote":{"01. symbol":"IBM","02. open":"232.8000",'
        '"03. high":"240.8065","04. low":"231.4500","05. price":"238.7900",'
        '"06. volume":"5505922","07. latest trading day":"2026-08-27",'
        '"08. previous close":"229.8700","09. change":"8.9200",'
        '"10. change percent":"3.8805%"}}',
        200,
      ),
    );

    final Quote quote = (await provider.fetchQuote(
      apple,
      cancellationToken: CancellationToken(),
    )).valueOrNull!;

    expect(quote.price, Money(Decimal.parse('238.7900'), Currency.usd));
    expect(quote.previousClose, Money(Decimal.parse('229.8700'), Currency.usd));
    expect(quote.asOf, DateTime.utc(2026, 8, 27));
  });

  test('an unknown symbol is NoDataFailure, not a provider outage', () async {
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response(
        '{"Error Message":"Invalid API call. Please retry."}',
        200,
      ),
    );

    expect(
      (await provider.fetchQuote(
        allianz,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<NoDataFailure>(),
    );
  });

  test('an empty Global Quote is NoDataFailure, not a zero price', () async {
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response('{"Global Quote":{}}', 200),
    );

    expect(
      (await provider.fetchQuote(
        allianz,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<NoDataFailure>(),
    );
  });

  test('a zero or negative price is refused rather than shown', () async {
    for (final String bad in <String>['0', '0.00', '-3.10']) {
      final AlphaVantageQuoteProvider provider = providerWith(
        (_) async => http.Response(body(price: bad), 200),
      );

      expect(
        (await provider.fetchQuote(
          allianz,
          cancellationToken: CancellationToken(),
        )).failureOrNull,
        isA<ParsingFailure>(),
        reason: '$bad is not a price',
      );
    }
  });

  test('a non-numeric price is refused', () async {
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response(body(price: 'n/a'), 200),
    );

    expect(
      (await provider.fetchQuote(
        allianz,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<ParsingFailure>(),
    );
  });

  test('an unusable previous close is dropped, not invented', () async {
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response(body(previous: '0.00'), 200),
    );

    final Quote quote = (await provider.fetchQuote(
      allianz,
      cancellationToken: CancellationToken(),
    )).valueOrNull!;

    expect(quote.previousClose, isNull);
    expect(quote.price, Money(Decimal.parse('451.20'), Currency.eur));
  });

  test('an HTTP error becomes ProviderUnavailableFailure', () async {
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response('gateway', 502),
    );

    expect(
      (await provider.fetchQuote(
        allianz,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<ProviderUnavailableFailure>(),
    );
  });

  test('malformed JSON becomes ParsingFailure', () async {
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response('<html>nope</html>', 200),
    );

    expect(
      (await provider.fetchQuote(
        allianz,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<ParsingFailure>(),
    );
  });

  test('a transport failure becomes NetworkFailure', () async {
    final AlphaVantageQuoteProvider provider = providerWith((_) async {
      throw http.ClientException('connection reset');
    });

    expect(
      (await provider.fetchQuote(
        allianz,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<NetworkFailure>(),
    );
  });

  test('the adapter declares only quotes', () {
    final AlphaVantageQuoteProvider provider = providerWith(
      (_) async => http.Response(body(), 200),
    );

    expect(provider.capabilities, <ProviderDataType>{ProviderDataType.quote});
    expect(provider.id, 'alpha_vantage');
    expect(AlphaVantageQuoteProvider.freeTierDailyRequests, 25);
  });
}
