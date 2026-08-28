import 'dart:convert';
import 'dart:io';

import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/data/providers/market_data_provider.dart';
import 'package:dividendendackel/data/providers/open_figi_provider.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const String mappingFixture = 'test/fixtures/openfigi/mapping_allianz.json';
  const String searchFixture = 'test/fixtures/openfigi/search_hannover.json';

  OpenFigiProvider providerReturning(
    Future<http.Response> Function(http.Request) handler,
  ) => OpenFigiProvider(MockClient(handler));

  test('an ISIN is resolved through the mapping endpoint', () async {
    late http.Request sent;
    final OpenFigiProvider provider = providerReturning((
      http.Request incoming,
    ) async {
      sent = incoming;
      return http.Response(await File(mappingFixture).readAsString(), 200);
    });

    final Result<List<Instrument>> result = await provider.searchInstruments(
      'DE0008404005',
      limit: 10,
      cancellationToken: CancellationToken(),
    );

    expect(sent.url.path, '/v3/mapping');
    final List<dynamic> body = jsonDecode(sent.body) as List<dynamic>;
    expect((body.single as Map<String, dynamic>)['idType'], 'ID_ISIN');
    expect((body.single as Map<String, dynamic>)['idValue'], 'DE0008404005');

    final List<Instrument> found = result.valueOrNull!;
    expect(found, hasLength(1), reason: 'venues collapse to one instrument');
    expect(found.single.symbol, 'ALV');
    expect(found.single.name, 'ALLIANZ SE-REG');
    expect(found.single.isin, 'DE0008404005');
    expect(found.single.internalId, 'isin:DE0008404005');
    expect(found.single.currency, Currency.eur);
  });

  test('a lower-case ISIN is still recognised as one', () async {
    late http.Request sent;
    final OpenFigiProvider provider = providerReturning((
      http.Request incoming,
    ) async {
      sent = incoming;
      return http.Response(await File(mappingFixture).readAsString(), 200);
    });

    await provider.searchInstruments(
      'de0008404005',
      limit: 10,
      cancellationToken: CancellationToken(),
    );

    expect(sent.url.path, '/v3/mapping');
    final List<dynamic> body = jsonDecode(sent.body) as List<dynamic>;
    expect((body.single as Map<String, dynamic>)['idValue'], 'DE0008404005');
  });

  test('non-equity and non-German rows are discarded', () async {
    final OpenFigiProvider provider = providerReturning(
      (_) async =>
          http.Response(await File(mappingFixture).readAsString(), 200),
    );

    final List<Instrument> found = (await provider.searchInstruments(
      'DE0008404005',
      limit: 10,
      cancellationToken: CancellationToken(),
    )).valueOrNull!;

    // The fixture carries a US listing and a corporate bond alongside the
    // German equity rows; neither belongs in an equity search for a German
    // listing, and the bond shares neither ticker nor market sector.
    expect(found.map((Instrument i) => i.symbol), <String>['ALV']);
    expect(found.single.exchange, 'GY', reason: 'Xetra is preferred');
  });

  test('a plain name falls back to the search endpoint', () async {
    final List<String> paths = <String>[];
    final OpenFigiProvider provider = providerReturning((
      http.Request incoming,
    ) async {
      paths.add(incoming.url.path);
      return http.Response(await File(searchFixture).readAsString(), 200);
    });

    final List<Instrument> found = (await provider.searchInstruments(
      'Hannover Rueck',
      limit: 10,
      cancellationToken: CancellationToken(),
    )).valueOrNull!;

    expect(paths, <String>['/v3/search']);
    expect(found.single.symbol, 'HNR1');
    expect(found.single.name, 'HANNOVER RUECK SE');
    expect(found.single.internalId, startsWith('figi:'));
  });

  test(
    'venues are tried in order and stop at the first that answers',
    () async {
      final List<String> exchanges = <String>[];
      final OpenFigiProvider provider = providerReturning((
        http.Request incoming,
      ) async {
        final Map<String, dynamic> body =
            jsonDecode(incoming.body) as Map<String, dynamic>;
        exchanges.add(body['exchCode'] as String);
        // Xetra answers nothing; the next venue does.
        return http.Response(
          body['exchCode'] == 'GY'
              ? '{"data":[]}'
              : await File(searchFixture).readAsString(),
          200,
        );
      });

      final List<Instrument> found = (await provider.searchInstruments(
        'Hannover Rueck',
        limit: 10,
        cancellationToken: CancellationToken(),
      )).valueOrNull!;

      expect(exchanges, <String>['GY', 'GR']);
      expect(found, hasLength(1));
    },
  );

  test('the requested limit is honoured', () async {
    final OpenFigiProvider provider = providerReturning(
      (_) async =>
          http.Response(await File(mappingFixture).readAsString(), 200),
    );

    final List<Instrument> found = (await provider.searchInstruments(
      'DE0008404005',
      limit: 1,
      cancellationToken: CancellationToken(),
    )).valueOrNull!;

    expect(found, hasLength(1));
  });

  test('nothing found is NoDataFailure, not an empty success', () async {
    final OpenFigiProvider provider = providerReturning(
      (_) async => http.Response('{"data":[]}', 200),
    );

    final Result<List<Instrument>> result = await provider.searchInstruments(
      'Nothing Listed Here',
      limit: 10,
      cancellationToken: CancellationToken(),
    );

    expect(result.failureOrNull, isA<NoDataFailure>());
  });

  test('an empty query is refused before any request is made', () async {
    bool called = false;
    final OpenFigiProvider provider = providerReturning((_) async {
      called = true;
      return http.Response('[]', 200);
    });

    final Result<List<Instrument>> result = await provider.searchInstruments(
      '   ',
      limit: 10,
      cancellationToken: CancellationToken(),
    );

    expect(result.failureOrNull, isA<InvalidInstrumentFailure>());
    expect(called, isFalse);
  });

  test('429 becomes a RateLimitFailure carrying the reset time', () async {
    final OpenFigiProvider provider = providerReturning(
      (_) async => http.Response(
        'rate limited',
        429,
        headers: const <String, String>{'ratelimit-reset': '60'},
      ),
    );

    final Result<List<Instrument>> result = await provider.searchInstruments(
      'DE0008404005',
      limit: 10,
      cancellationToken: CancellationToken(),
    );

    final Failure? failure = result.failureOrNull;
    expect(failure, isA<RateLimitFailure>());
    expect((failure! as RateLimitFailure).retryAt, isNotNull);
  });

  test('other HTTP errors become ProviderUnavailableFailure', () async {
    final OpenFigiProvider provider = providerReturning(
      (_) async => http.Response('boom', 503),
    );

    expect(
      (await provider.searchInstruments(
        'DE0008404005',
        limit: 10,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<ProviderUnavailableFailure>(),
    );
  });

  test('malformed JSON becomes ParsingFailure, never a crash', () async {
    final OpenFigiProvider provider = providerReturning(
      (_) async => http.Response('not json at all', 200),
    );

    expect(
      (await provider.searchInstruments(
        'DE0008404005',
        limit: 10,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<ParsingFailure>(),
    );
  });

  test('a response of the wrong shape becomes ParsingFailure', () async {
    final OpenFigiProvider provider = providerReturning(
      (_) async => http.Response('{"unexpected":true}', 200),
    );

    expect(
      (await provider.searchInstruments(
        'DE0008404005',
        limit: 10,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<ParsingFailure>(),
    );
  });

  test(
    'rows missing required fields are skipped rather than fabricated',
    () async {
      final OpenFigiProvider provider = providerReturning(
        (_) async => http.Response(
          '[{"data":[{"ticker":null,"name":"NO TICKER","exchCode":"GY",'
          '"marketSector":"Equity"},'
          '{"figi":"BBG1","ticker":"OK","name":"REAL ONE","exchCode":"GY",'
          '"compositeFIGI":"BBG1","marketSector":"Equity"}]}]',
          200,
        ),
      );

      final List<Instrument> found = (await provider.searchInstruments(
        'DE0008404005',
        limit: 10,
        cancellationToken: CancellationToken(),
      )).valueOrNull!;

      expect(found.map((Instrument i) => i.symbol), <String>['OK']);
    },
  );

  test('a transport failure surfaces as NetworkFailure', () async {
    final OpenFigiProvider provider = providerReturning((_) async {
      throw http.ClientException('connection reset');
    });

    expect(
      (await provider.searchInstruments(
        'DE0008404005',
        limit: 10,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<NetworkFailure>(),
    );
  });

  test(
    'a non-positive limit fails rather than returning an empty list',
    () async {
      bool called = false;
      final OpenFigiProvider provider = providerReturning((_) async {
        called = true;
        return http.Response('[]', 200);
      });

      // guardAsync turns the ArgumentError into a typed failure, matching the
      // SEC adapter. What matters is that it fails loudly and spends no quota.
      final Result<List<Instrument>> result = await provider.searchInstruments(
        'DE0008404005',
        limit: 0,
        cancellationToken: CancellationToken(),
      );

      expect(result.isSuccess, isFalse);
      expect(called, isFalse);
    },
  );

  test('the adapter declares only instrument search, never quotes', () {
    final OpenFigiProvider provider = OpenFigiProvider(
      MockClient((_) async {
        throw StateError('no request expected');
      }),
    );

    // OpenFIGI answers what an instrument is, never what it is worth. If this
    // ever gains a quote capability the app would present identity data as a
    // price, which is exactly the defect the sample dataset had.
    expect(provider.capabilities, <ProviderDataType>{
      ProviderDataType.instrumentSearch,
    });
    expect(provider.id, 'openfigi');
  });
}
