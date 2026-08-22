import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_cache_metadata_repository.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late CacheMetadataRepository repository;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = DriftCacheMetadataRepository(db);
  });

  tearDown(() => db.close());

  test('returns null for a cache miss', () async {
    expect((await repository.find('missing')).valueOrNull, isNull);
  });

  test('round-trips exact metadata', () async {
    final CacheMetadataEntry entry = CacheMetadataEntry(
      cacheKey: 'dividends:isin:DE0008404005',
      dataType: CacheDataType.announcedDividends,
      source: 'sec',
      fetchedAt: DateTime.utc(2026, 8, 22, 12),
      expiresAt: DateTime.utc(2026, 8, 23),
      etag: '"abc123"',
    );

    expect((await repository.save(entry)).isSuccess, isTrue);
    expect((await repository.find(entry.cacheKey)).valueOrNull, entry);
  });

  test('updates an existing cache key instead of duplicating it', () async {
    final CacheMetadataEntry first = CacheMetadataEntry(
      cacheKey: 'quotes:portfolio',
      dataType: CacheDataType.quotes,
      source: 'provider-a',
      fetchedAt: DateTime.utc(2026, 8, 22, 12),
      expiresAt: DateTime.utc(2026, 8, 22, 12, 5),
    );
    final CacheMetadataEntry second = CacheMetadataEntry(
      cacheKey: first.cacheKey,
      dataType: CacheDataType.quotes,
      source: 'provider-b',
      fetchedAt: DateTime.utc(2026, 8, 22, 13),
      expiresAt: DateTime.utc(2026, 8, 22, 13, 5),
    );

    await repository.save(first);
    await repository.save(second);

    expect(await db.select(db.cacheMetadata).get(), hasLength(1));
    expect((await repository.find(first.cacheKey)).valueOrNull, second);
  });

  test('removes metadata', () async {
    final CacheMetadataEntry entry = CacheMetadataEntry(
      cacheKey: 'news:portfolio',
      dataType: CacheDataType.news,
      source: 'provider',
      fetchedAt: DateTime.utc(2026, 8, 22, 12),
      expiresAt: DateTime.utc(2026, 8, 22, 12, 10),
    );
    await repository.save(entry);

    expect((await repository.remove(entry.cacheKey)).isSuccess, isTrue);
    expect((await repository.find(entry.cacheKey)).valueOrNull, isNull);
  });

  test('maps an unknown stored data type to a parsing failure', () async {
    await db
        .into(db.cacheMetadata)
        .insert(
          CacheMetadataCompanion.insert(
            cacheKey: 'future:type',
            dataType: 'notKnown',
            source: 'provider',
            fetchedAt: DateTime.utc(2026, 8, 22),
            expiresAt: DateTime.utc(2026, 8, 23),
            etag: const Value<String?>.absent(),
          ),
        );

    final result = await repository.find('future:type');

    expect(result.failureOrNull, isA<ParsingFailure>());
  });
}
