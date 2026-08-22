import 'package:decimal/decimal.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 22, 17, 30);
  final Provenance provenance = Provenance(source: 'fmp', fetchedAt: now);

  group('Quote', () {
    Quote quoteOf(String price, {String? previousClose}) => Quote(
      instrumentId: 'isin:DE0008404005',
      price: Money.parse(price, Currency.eur),
      previousClose: previousClose == null
          ? null
          : Money.parse(previousClose, Currency.eur),
      asOf: now,
      provenance: provenance,
    );

    test('computes absolute and relative change', () {
      final Quote quote = quoteOf('287.50', previousClose: '286.35');

      expect(quote.change, Money.parse('1.15', Currency.eur));
      expect(quote.changePercent!.format(decimals: 2), '0.40%');
    });

    test('reports a fall as a negative change', () {
      final Quote quote = quoteOf('95.20', previousClose: '100.00');

      expect(quote.change, Money.parse('-4.80', Currency.eur));
      expect(quote.changePercent!.format(decimals: 1, withSign: true), '-4.8%');
    });

    test('stays usable without a previous close', () {
      final Quote quote = quoteOf('287.50');

      expect(quote.price, Money.parse('287.50', Currency.eur));
      expect(quote.change, isNull);
      expect(quote.changePercent, isNull);
    });

    test('does not divide by a zero previous close', () {
      expect(quoteOf('5', previousClose: '0').changePercent, isNull);
    });

    test('flags an unusual movement without asserting a cause', () {
      final Percentage threshold = Percentage.parsePercent('3');

      expect(
        quoteOf('95.20', previousClose: '100').movedAtLeast(threshold),
        isTrue,
      );
      expect(
        quoteOf('101', previousClose: '100').movedAtLeast(threshold),
        isFalse,
      );
      expect(quoteOf('101').movedAtLeast(threshold), isFalse);
    });
  });

  group('EarningsEvent', () {
    EarningsEvent earningsWith({
      EarningsStatus status = EarningsStatus.confirmed,
      String? epsEstimate,
      String? epsActual,
    }) => EarningsEvent(
      instrumentId: 'sym:NVDA',
      scheduledFor: now,
      status: status,
      timing: EarningsTiming.afterMarketClose,
      epsEstimate: epsEstimate == null
          ? null
          : Money.parse(epsEstimate, Currency.usd),
      epsActual: epsActual == null
          ? null
          : Money.parse(epsActual, Currency.usd),
      provenance: provenance,
    );

    test('records when during the day a company reports', () {
      expect(earningsWith().timing, EarningsTiming.afterMarketClose);
    });

    test('computes the EPS surprise once both numbers exist', () {
      final EarningsEvent event = earningsWith(
        status: EarningsStatus.reported,
        epsEstimate: '1.20',
        epsActual: '1.35',
      );

      expect(event.isReported, isTrue);
      expect(event.epsSurprise, Money.parse('0.15', Currency.usd));
    });

    test('returns null instead of guessing a surprise', () {
      expect(earningsWith(epsEstimate: '1.20').epsSurprise, isNull);
      expect(earningsWith().epsSurprise, isNull);
    });
  });

  group('NewsItem', () {
    NewsItem newsWith({
      NewsCategory category = NewsCategory.dividends,
      List<String> related = const <String>['isin:DE0008404005'],
    }) => NewsItem(
      id: 'news-1',
      headline: 'Allianz raises dividend',
      sourceName: 'Reuters',
      publishedAt: now,
      url: Uri.parse('https://example.invalid/allianz'),
      category: category,
      relatedInstrumentIds: related,
      provenance: provenance,
    );

    test('links to the source rather than carrying an article body', () {
      final NewsItem item = newsWith();

      expect(item.url.toString(), startsWith('https://'));
      expect(item.summary, isNull);
    });

    test('knows which instruments it concerns', () {
      final NewsItem item = newsWith();

      expect(item.concerns('isin:DE0008404005'), isTrue);
      expect(item.concerns('sym:AAPL'), isFalse);
    });

    test('carries no relevance until ranking assigns one', () {
      expect(newsWith().relevance, isNull);
      expect(newsWith().withRelevance(0.8).relevance, 0.8);
    });

    test('withRelevance preserves every other field', () {
      final NewsItem ranked = newsWith().withRelevance(0.8);

      expect(ranked.headline, 'Allianz raises dividend');
      expect(ranked.category, NewsCategory.dividends);
      expect(ranked.relatedInstrumentIds, <String>['isin:DE0008404005']);
    });

    test('covers every category the vision names', () {
      expect(NewsCategory.values, hasLength(11));
    });

    test('identity is the id, so providers can be deduplicated', () {
      expect(newsWith(), newsWith(category: NewsCategory.earnings));
    });
  });

  group('Filing', () {
    Filing filingOf(String formType) => Filing(
      id: '0000320193-26-000042',
      instrumentId: 'sym:AAPL',
      formType: formType,
      filedAt: now,
      url: Uri.parse('https://example.invalid/filing'),
      provenance: provenance,
    );

    test('recognises the forms that usually matter to a holder', () {
      expect(filingOf('10-K').isMaterialForm, isTrue);
      expect(filingOf('8-K').isMaterialForm, isTrue);
      expect(filingOf('10-q').isMaterialForm, isTrue);
      expect(filingOf('SC 13G').isMaterialForm, isFalse);
    });
  });
}
