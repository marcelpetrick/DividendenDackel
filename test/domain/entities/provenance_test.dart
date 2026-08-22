import 'package:dividendendackel/domain/entities/provenance.dart';
import 'package:dividendendackel/domain/value_objects/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fetchedAt = DateTime.utc(2026, 8, 22, 17, 22);

  group('Provenance', () {
    test('defaults to fresh and high confidence', () {
      final Provenance provenance = Provenance(
        source: 'fmp',
        fetchedAt: fetchedAt,
      );

      expect(provenance.cacheState, CacheState.fresh);
      expect(provenance.confidence, Confidence.high);
      expect(provenance.isStale, isFalse);
      expect(provenance.isUserProvided, isFalse);
    });

    test('marks user-entered data as needing no provider', () {
      final Provenance provenance = Provenance.user(fetchedAt);

      expect(provenance.source, Provenance.userSource);
      expect(provenance.isUserProvided, isTrue);
    });

    test('marks bundled sample data', () {
      expect(Provenance.sample(fetchedAt).source, Provenance.sampleSource);
    });

    test('reports its age, which drives the "last updated" copy', () {
      final Provenance provenance = Provenance(
        source: 'fmp',
        fetchedAt: fetchedAt,
      );

      expect(
        provenance.ageAt(fetchedAt.add(const Duration(minutes: 42))),
        const Duration(minutes: 42),
      );
    });

    test('distinguishes retrieval time from content time', () {
      final Provenance provenance = Provenance(
        source: 'fmp',
        fetchedAt: fetchedAt,
        updatedAt: fetchedAt.subtract(const Duration(days: 3)),
      );

      expect(provenance.fetchedAt, fetchedAt);
      expect(provenance.updatedAt, isNot(provenance.fetchedAt));
    });

    test('reports staleness', () {
      final Provenance provenance = Provenance(
        source: 'fmp',
        fetchedAt: fetchedAt,
        cacheState: CacheState.stale,
      );

      expect(provenance.isStale, isTrue);
    });

    test('keeps the provider-reported symbol, exchange and currency', () {
      final Provenance provenance = Provenance(
        source: 'fmp',
        fetchedAt: fetchedAt,
        reportedCurrency: Currency.usd,
        originalSymbol: 'ALV.DE',
        exchange: 'XETRA',
      );

      expect(provenance.reportedCurrency, Currency.usd);
      expect(provenance.originalSymbol, 'ALV.DE');
      expect(provenance.exchange, 'XETRA');
    });

    test('copyWith replaces only the named fields', () {
      final Provenance provenance = Provenance(
        source: 'fmp',
        fetchedAt: fetchedAt,
        originalSymbol: 'ALV.DE',
      );
      final Provenance stale = provenance.copyWith(
        cacheState: CacheState.stale,
      );

      expect(stale.cacheState, CacheState.stale);
      expect(stale.source, 'fmp');
      expect(stale.originalSymbol, 'ALV.DE');
      expect(stale.fetchedAt, fetchedAt);
    });

    test('compares by value', () {
      expect(
        Provenance(source: 'fmp', fetchedAt: fetchedAt),
        Provenance(source: 'fmp', fetchedAt: fetchedAt),
      );
      expect(
        Provenance(source: 'fmp', fetchedAt: fetchedAt).hashCode,
        Provenance(source: 'fmp', fetchedAt: fetchedAt).hashCode,
      );
      expect(
        Provenance(source: 'fmp', fetchedAt: fetchedAt),
        isNot(Provenance(source: 'sec', fetchedAt: fetchedAt)),
      );
    });

    test('covers the confidence levels the vision names', () {
      expect(Confidence.values, <Confidence>[
        Confidence.high,
        Confidence.medium,
        Confidence.low,
      ]);
    });
  });
}
