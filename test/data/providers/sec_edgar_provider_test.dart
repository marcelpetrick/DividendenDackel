import 'dart:io';

import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/data/providers/sec_edgar_provider.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../../support/fake_clock.dart';

void main() {
  const String tickersPath = 'test/fixtures/sec/company_tickers.json';
  const String factsPath = 'test/fixtures/sec/companyfacts.json';
  const String submissionsPath = 'test/fixtures/sec/submissions.json';
  final DateTime now = DateTime.utc(2026, 8, 22, 12);
  final DateRange historyRange = DateRange(
    DateTime.utc(2024),
    DateTime.utc(2026),
  );

  test(
    'search parses the official ticker contract and declares the bot',
    () async {
      late http.Request request;
      final SecEdgarProvider provider = SecEdgarProvider(
        MockClient((http.Request incoming) async {
          request = incoming;
          return http.Response(await File(tickersPath).readAsString(), 200);
        }),
        FakeClock(now),
      );

      final Result<List<Instrument>> result = await provider.searchInstruments(
        'aapl',
        limit: 2,
        cancellationToken: CancellationToken(),
      );

      expect(
        request.url.toString(),
        'https://www.sec.gov/files/company_tickers.json',
      );
      expect(
        request.headers[HttpHeaders.userAgentHeader],
        SecEdgarProvider.userAgent,
      );
      expect(SecEdgarProvider.userAgent, contains('mail@marcelpetrick.it'));
      expect(result.valueOrNull, hasLength(1));
      final Instrument instrument = result.valueOrNull!.single;
      expect(instrument.symbol, 'AAPL');
      expect(
        instrument.providerMappings.single.providerInstrumentId,
        '0000320193',
      );
    },
  );

  test('search respects the requested result limit', () async {
    final SecEdgarProvider provider = SecEdgarProvider(
      MockClient(
        (_) async => http.Response(await File(tickersPath).readAsString(), 200),
      ),
      FakeClock(now),
    );

    final Result<List<Instrument>> result = await provider.searchInstruments(
      'Apple',
      limit: 1,
      cancellationToken: CancellationToken(),
    );

    expect(result.valueOrNull, hasLength(1));
  });

  test(
    'normalizes discrete dividend facts without inventing event dates',
    () async {
      final SecEdgarProvider provider = SecEdgarProvider(
        MockClient((http.Request request) async {
          expect(
            request.url.path,
            contains('/companyfacts/CIK0000320193.json'),
          );
          return http.Response(await File(factsPath).readAsString(), 200);
        }),
        FakeClock(now),
      );

      final Result<List<DividendEvent>> result = await provider.fetchDividends(
        _apple,
        DateRange(DateTime.utc(2024), DateTime.utc(2024, 7)),
        cancellationToken: CancellationToken(),
      );

      final List<DividendEvent> events = result.valueOrNull!;
      expect(events, hasLength(1));
      expect(events.first.amountPerShare.amount.toString(), '0.26');
      expect(events.first.frequency, DividendFrequency.quarterly);
      expect(events.first.exDate, isNull);
      expect(events.first.paymentDate, isNull);
      expect(events.first.declarationDate, isNull);
      expect(events.first.reportedPeriodEnd, DateTime.utc(2024, 3, 31));
      expect(events.first.provenance.source, 'sec');
      expect(events.first.provenance.updatedAt, DateTime.utc(2025, 4, 20));
      expect(events.first.provenance.fetchedAt, now);
    },
  );

  test('prefers annual totals over overlapping quarterly facts', () async {
    final SecEdgarProvider provider = SecEdgarProvider(
      MockClient(
        (_) async => http.Response(await File(factsPath).readAsString(), 200),
      ),
      FakeClock(now),
    );

    final Result<List<DividendEvent>> result = await provider.fetchDividends(
      _apple,
      historyRange,
      cancellationToken: CancellationToken(),
    );

    final List<DividendEvent> events = result.valueOrNull!;
    expect(events, hasLength(2));
    expect(
      events.map(
        (DividendEvent event) => event.amountPerShare.amount.toString(),
      ),
      <String>['1', '1.2'],
    );
    expect(
      events.every(
        (DividendEvent event) => event.frequency == DividendFrequency.annual,
      ),
      isTrue,
    );
  });

  test(
    'resolves an unmapped instrument by exact ticker before facts',
    () async {
      final List<Uri> requests = <Uri>[];
      final SecEdgarProvider provider = SecEdgarProvider(
        MockClient((http.Request request) async {
          requests.add(request.url);
          if (request.url.path.endsWith('company_tickers.json')) {
            return http.Response(await File(tickersPath).readAsString(), 200);
          }
          return http.Response(await File(factsPath).readAsString(), 200);
        }),
        FakeClock(now),
      );

      final Result<List<DividendEvent>> result = await provider.fetchDividends(
        _apple.copyWith(providerMappings: const <ProviderMapping>[]),
        historyRange,
        cancellationToken: CancellationToken(),
      );

      expect(result.isSuccess, isTrue);
      expect(requests, hasLength(2));
      expect(requests.last.path, contains('CIK0000320193'));
    },
  );

  test('normalizes filings and builds canonical archive links', () async {
    final SecEdgarProvider provider = SecEdgarProvider(
      MockClient(
        (_) async =>
            http.Response(await File(submissionsPath).readAsString(), 200),
      ),
      FakeClock(now),
    );

    final Result<List<Filing>> result = await provider.fetchFilings(
      _apple,
      DateRange(DateTime.utc(2026), DateTime.utc(2027)),
      cancellationToken: CancellationToken(),
    );

    final Filing filing = result.valueOrNull!.single;
    expect(filing.id, '0000320193-26-000001');
    expect(filing.formType, '10-Q');
    expect(filing.periodOfReport, DateTime.utc(2026, 6, 27));
    expect(
      filing.url.toString(),
      'https://www.sec.gov/Archives/edgar/data/320193/'
      '000032019326000001/aapl-20260627.htm',
    );
  });

  test('maps rate limiting with Retry-After to a typed failure', () async {
    final SecEdgarProvider provider = SecEdgarProvider(
      MockClient(
        (_) async => http.Response(
          '',
          429,
          headers: <String, String>{'retry-after': '30'},
        ),
      ),
      FakeClock(now),
    );

    final Result<List<DividendEvent>> result = await provider.fetchDividends(
      _apple,
      historyRange,
      cancellationToken: CancellationToken(),
    );

    expect(result.failureOrNull, isA<RateLimitFailure>());
    expect(
      (result.failureOrNull! as RateLimitFailure).retryAt,
      now.add(const Duration(seconds: 30)),
    );
  });

  test('maps missing and malformed responses to typed failures', () async {
    final SecEdgarProvider missing = SecEdgarProvider(
      MockClient((_) async => http.Response('', 404)),
      FakeClock(now),
    );
    final SecEdgarProvider malformed = SecEdgarProvider(
      MockClient((_) async => http.Response('{broken', 200)),
      FakeClock(now),
    );

    expect(
      (await missing.fetchDividends(
        _apple,
        historyRange,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<NoDataFailure>(),
    );
    expect(
      (await malformed.fetchDividends(
        _apple,
        historyRange,
        cancellationToken: CancellationToken(),
      )).failureOrNull,
      isA<ParsingFailure>(),
    );
  });
}

const Instrument _apple = Instrument(
  internalId: 'isin:US0378331005',
  symbol: 'AAPL',
  name: 'Apple Inc.',
  currency: Currency.usd,
  mic: 'XNAS',
  isin: 'US0378331005',
  country: 'US',
  providerMappings: <ProviderMapping>[
    ProviderMapping(
      providerId: 'sec',
      symbol: 'AAPL',
      providerInstrumentId: '0000320193',
    ),
  ],
);
