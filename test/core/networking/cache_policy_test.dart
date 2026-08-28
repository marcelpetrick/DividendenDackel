import 'package:dividendendackel/core/networking/cache_policy.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('end-of-day quote cadence', () {
    final CachePolicy policy = CachePolicy();

    test('a quote fetched before the close expires at that close', () {
      // Tuesday 09:00 UTC: the price on hand is Monday's close, and a new one
      // arrives at today's close.
      expect(
        policy.expiresAt(CacheDataType.quotes, DateTime.utc(2026, 8, 25, 9)),
        DateTime.utc(2026, 8, 25, 16, 30),
      );
    });

    test('a quote fetched after the close holds until the next one', () {
      expect(
        policy.expiresAt(CacheDataType.quotes, DateTime.utc(2026, 8, 25, 18)),
        DateTime.utc(2026, 8, 26, 16, 30),
      );
    });

    test('a Friday close carries across the weekend', () {
      // 2026-08-28 is a Friday. A fixed lifetime would refetch all weekend and
      // spend a 25-request day on prices that cannot have changed.
      expect(
        policy.expiresAt(CacheDataType.quotes, DateTime.utc(2026, 8, 28, 18)),
        DateTime.utc(2026, 8, 31, 16, 30),
      );
    });

    test('a weekend refresh still waits for Monday', () {
      expect(
        policy.expiresAt(CacheDataType.quotes, DateTime.utc(2026, 8, 29, 12)),
        DateTime.utc(2026, 8, 31, 16, 30),
      );
    });

    test('a quote stays fresh until its session close', () {
      final DateTime fetched = DateTime.utc(2026, 8, 25, 18);
      expect(
        policy
            .resolve(
              dataType: CacheDataType.quotes,
              now: DateTime.utc(2026, 8, 26, 16, 29),
              fetchedAt: fetched,
              expiresAt: policy.expiresAt(CacheDataType.quotes, fetched),
            )
            .state,
        CacheState.fresh,
      );
      expect(
        policy
            .resolve(
              dataType: CacheDataType.quotes,
              now: DateTime.utc(2026, 8, 26, 16, 31),
              fetchedAt: fetched,
              expiresAt: policy.expiresAt(CacheDataType.quotes, fetched),
            )
            .state,
        CacheState.stale,
      );
    });

    test('an intraday source keeps the short fixed lifetime', () {
      final CachePolicy intraday = CachePolicy(
        quoteCadence: QuoteCadence.intraday,
      );
      final DateTime fetched = DateTime.utc(2026, 8, 25, 9);
      expect(
        intraday.expiresAt(CacheDataType.quotes, fetched),
        fetched.add(intraday.lifetimeFor(CacheDataType.quotes)),
      );
    });

    test('other data types are unaffected by the quote cadence', () {
      final DateTime fetched = DateTime.utc(2026, 8, 25, 9);
      expect(
        policy.expiresAt(CacheDataType.fxRates, fetched),
        fetched.add(policy.lifetimeFor(CacheDataType.fxRates)),
      );
    });
  });

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
