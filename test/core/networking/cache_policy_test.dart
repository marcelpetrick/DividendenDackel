import 'package:dividendendackel/core/networking/cache_policy.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fetchedAt = DateTime.utc(2026, 8, 22, 12);

  group('CachePolicy', () {
    test('defines a positive lifetime for every data type', () {
      final CachePolicy policy = CachePolicy();

      expect(policy.lifetimes.keys, containsAll(CacheDataType.values));
      for (final CacheDataType dataType in CacheDataType.values) {
        expect(policy.lifetimeFor(dataType), greaterThan(Duration.zero));
      }
      expect(
        policy.lifetimeFor(CacheDataType.fxRates),
        const Duration(hours: 12),
      );
    });

    test(
      'accepts a per-data-type override without changing other defaults',
      () {
        final CachePolicy policy = CachePolicy(
          overrides: const <CacheDataType, Duration>{
            CacheDataType.quotes: Duration(seconds: 30),
          },
        );

        expect(
          policy.lifetimeFor(CacheDataType.quotes),
          const Duration(seconds: 30),
        );
        expect(
          policy.lifetimeFor(CacheDataType.news),
          CachePolicy.defaultLifetimes[CacheDataType.news],
        );
      },
    );

    test('rejects zero and negative overrides', () {
      expect(
        () => CachePolicy(
          overrides: const <CacheDataType, Duration>{
            CacheDataType.news: Duration.zero,
          },
        ),
        throwsArgumentError,
      );
      expect(
        () => CachePolicy(
          overrides: const <CacheDataType, Duration>{
            CacheDataType.news: Duration(seconds: -1),
          },
        ),
        throwsArgumentError,
      );
    });

    test('resolves missing when no fetch time exists', () {
      final CacheResolution result = CachePolicy().resolve(
        dataType: CacheDataType.news,
        now: fetchedAt,
      );

      expect(result.state, CacheState.missing);
      expect(result.canServeCached, isFalse);
      expect(result.shouldRevalidate, isTrue);
      expect(result.expiresAt, isNull);
    });

    test('resolves fresh before the configured expiry', () {
      final CachePolicy policy = CachePolicy();
      final CacheResolution result = policy.resolve(
        dataType: CacheDataType.news,
        fetchedAt: fetchedAt,
        now: fetchedAt.add(const Duration(minutes: 9, seconds: 59)),
      );

      expect(result.state, CacheState.fresh);
      expect(result.canServeCached, isTrue);
      expect(result.shouldRevalidate, isFalse);
      expect(result.expiresAt, fetchedAt.add(const Duration(minutes: 10)));
    });

    test('resolves stale at the exact expiry boundary', () {
      final CachePolicy policy = CachePolicy();
      final DateTime expiresAt = policy.expiresAt(
        CacheDataType.announcedDividends,
        fetchedAt,
      );

      final CacheResolution result = policy.resolve(
        dataType: CacheDataType.announcedDividends,
        fetchedAt: fetchedAt,
        now: expiresAt,
      );

      expect(result.state, CacheState.stale);
      expect(result.canServeCached, isTrue);
      expect(result.shouldRevalidate, isTrue);
    });

    test('honours an explicit persisted expiry', () {
      final DateTime explicit = fetchedAt.add(const Duration(hours: 1));
      final CacheResolution result = CachePolicy().resolve(
        dataType: CacheDataType.instrumentMetadata,
        fetchedAt: fetchedAt,
        expiresAt: explicit,
        now: explicit.subtract(const Duration(seconds: 1)),
      );

      expect(result.state, CacheState.fresh);
      expect(result.expiresAt, explicit);
    });
  });

  group('CacheMetadataEntry', () {
    test('resolves existing entry freshness', () {
      final CacheMetadataEntry entry = CacheMetadataEntry(
        cacheKey: 'news:portfolio',
        dataType: CacheDataType.news,
        source: 'provider',
        fetchedAt: fetchedAt,
        expiresAt: fetchedAt.add(const Duration(minutes: 10)),
      );

      expect(entry.stateAt(fetchedAt), CacheState.fresh);
      expect(
        entry.stateAt(fetchedAt.add(const Duration(minutes: 10))),
        CacheState.stale,
      );
    });

    test('validates identity, source and timestamp order', () {
      expect(
        () => CacheMetadataEntry(
          cacheKey: ' ',
          dataType: CacheDataType.news,
          source: 'provider',
          fetchedAt: fetchedAt,
          expiresAt: fetchedAt,
        ),
        throwsArgumentError,
      );
      expect(
        () => CacheMetadataEntry(
          cacheKey: 'key',
          dataType: CacheDataType.news,
          source: '',
          fetchedAt: fetchedAt,
          expiresAt: fetchedAt,
        ),
        throwsArgumentError,
      );
      expect(
        () => CacheMetadataEntry(
          cacheKey: 'key',
          dataType: CacheDataType.news,
          source: 'provider',
          fetchedAt: fetchedAt,
          expiresAt: fetchedAt.subtract(const Duration(seconds: 1)),
        ),
        throwsArgumentError,
      );
    });
  });
}
