import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/cache_policy.dart';
import 'package:dividendendackel/core/networking/stale_while_revalidate.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23, 12);
  late _MemoryMetadata metadata;
  late StaleWhileRevalidateExecutor executor;

  setUp(() {
    metadata = _MemoryMetadata();
    executor = StaleWhileRevalidateExecutor(
      metadata: metadata,
      policy: CachePolicy(
        overrides: const <CacheDataType, Duration>{
          CacheDataType.news: Duration(minutes: 10),
        },
      ),
    );
  });

  test('serves fresh cache without fetching', () async {
    metadata.entries['news:a'] = CacheMetadataEntry(
      cacheKey: 'news:a',
      dataType: CacheDataType.news,
      source: 'provider',
      fetchedAt: now.subtract(const Duration(minutes: 2)),
      expiresAt: now.add(const Duration(minutes: 8)),
    );
    var fetched = false;

    final Result<RevalidationOutcome<String>> result = await executor.run(
      cacheKey: 'news:a',
      dataType: CacheDataType.news,
      now: now,
      fetch: () async {
        fetched = true;
        return const Success<String>('new');
      },
      persist: (String value) async => const Success<void>(null),
      sourceOf: (String value) => 'provider',
    );

    expect(fetched, isFalse);
    expect(
      result.valueOrNull?.disposition,
      RevalidationDisposition.skippedFresh,
    );
  });

  test('fetches stale cache, persists it and advances metadata', () async {
    final DateTime old = now.subtract(const Duration(hours: 1));
    String? persisted;

    final Result<RevalidationOutcome<String>> result = await executor.run(
      cacheKey: 'news:a',
      dataType: CacheDataType.news,
      now: now,
      cachedFetchedAt: old,
      cachedSource: 'old-provider',
      fetch: () async => const Success<String>('new'),
      persist: (String value) async {
        persisted = value;
        return const Success<void>(null);
      },
      sourceOf: (String value) => 'new-provider',
    );

    expect(result.isSuccess, isTrue);
    expect(persisted, 'new');
    expect(metadata.entries['news:a']?.source, 'new-provider');
    expect(metadata.entries['news:a']?.fetchedAt, now);
    expect(
      metadata.entries['news:a']?.expiresAt,
      now.add(const Duration(minutes: 10)),
    );
  });

  test('provider failure leaves cached metadata untouched', () async {
    final CacheMetadataEntry old = CacheMetadataEntry(
      cacheKey: 'news:a',
      dataType: CacheDataType.news,
      source: 'provider',
      fetchedAt: now.subtract(const Duration(hours: 1)),
      expiresAt: now.subtract(const Duration(minutes: 50)),
    );
    metadata.entries['news:a'] = old;
    var persisted = false;

    final Result<RevalidationOutcome<String>> result = await executor.run(
      cacheKey: 'news:a',
      dataType: CacheDataType.news,
      now: now,
      fetch: () async => const Failed<String>(NetworkFailure()),
      persist: (String value) async {
        persisted = true;
        return const Success<void>(null);
      },
      sourceOf: (String value) => 'provider',
    );

    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(persisted, isFalse);
    expect(metadata.entries['news:a'], old);
  });

  test('force bypasses otherwise fresh metadata', () async {
    metadata.entries['news:a'] = CacheMetadataEntry(
      cacheKey: 'news:a',
      dataType: CacheDataType.news,
      source: 'provider',
      fetchedAt: now,
      expiresAt: now.add(const Duration(minutes: 10)),
    );
    var fetched = false;

    await executor.run(
      cacheKey: 'news:a',
      dataType: CacheDataType.news,
      now: now,
      force: true,
      fetch: () async {
        fetched = true;
        return const Success<String>('new');
      },
      persist: (String value) async => const Success<void>(null),
      sourceOf: (String value) => 'provider',
    );

    expect(fetched, isTrue);
  });

  test('captures thrown fetch errors as typed failures', () async {
    final Result<RevalidationOutcome<String>> result = await executor.run(
      cacheKey: 'news:a',
      dataType: CacheDataType.news,
      now: now,
      fetch: () => throw StateError('boom'),
      persist: (String value) async => const Success<void>(null),
      sourceOf: (String value) => 'provider',
    );

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });
}

final class _MemoryMetadata implements CacheMetadataRepository {
  final Map<String, CacheMetadataEntry> entries =
      <String, CacheMetadataEntry>{};

  @override
  Future<Result<CacheMetadataEntry?>> find(String cacheKey) async =>
      Success<CacheMetadataEntry?>(entries[cacheKey]);

  @override
  Future<Result<void>> remove(String cacheKey) async {
    entries.remove(cacheKey);
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> save(CacheMetadataEntry entry) async {
    entries[entry.cacheKey] = entry;
    return const Success<void>(null);
  }
}
