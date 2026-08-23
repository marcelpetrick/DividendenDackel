import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/cache_policy.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';

/// What a stale-while-revalidate operation did.
enum RevalidationDisposition { skippedFresh, refreshed }

/// Successful stale-while-revalidate result.
final class RevalidationOutcome<T> {
  /// Creates an outcome.
  const RevalidationOutcome({required this.disposition, this.value});

  /// Whether fresh cache was kept or new provider data was persisted.
  final RevalidationDisposition disposition;

  /// Newly fetched value, absent when fresh cache was kept.
  final T? value;
}

/// Coordinates cache expiry, provider fetch and persistence.
///
/// The executor deliberately never clears the caller's cached payload. A stale
/// value therefore remains observable while the asynchronous fetch runs and
/// also remains available when either fetching or persistence fails.
final class StaleWhileRevalidateExecutor {
  /// Creates an executor.
  const StaleWhileRevalidateExecutor({
    required this.metadata,
    required this.policy,
  });

  /// Persisted cache bookkeeping.
  final CacheMetadataRepository metadata;

  /// Time-to-live policy.
  final CachePolicy policy;

  /// Revalidates one logical cached request.
  Future<Result<RevalidationOutcome<T>>> run<T>({
    required String cacheKey,
    required CacheDataType dataType,
    required DateTime now,
    required Future<Result<T>> Function() fetch,
    required Future<Result<void>> Function(T value) persist,
    required String Function(T value) sourceOf,
    DateTime? cachedFetchedAt,
    String? cachedSource,
    bool force = false,
  }) async {
    final Result<CacheMetadataEntry?> metadataResult = await metadata.find(
      cacheKey,
    );
    if (metadataResult case Failed<CacheMetadataEntry?>(:final failure)) {
      return Failed<RevalidationOutcome<T>>(failure);
    }

    final CacheMetadataEntry? saved = metadataResult.valueOrNull;
    final DateTime? fetchedAt = saved?.fetchedAt ?? cachedFetchedAt;
    final CacheResolution resolution = policy.resolve(
      dataType: dataType,
      now: now,
      fetchedAt: fetchedAt,
      expiresAt: saved?.expiresAt,
    );
    if (!force && !resolution.shouldRevalidate) {
      return Success<RevalidationOutcome<T>>(
        RevalidationOutcome<T>(
          disposition: RevalidationDisposition.skippedFresh,
        ),
      );
    }

    final Result<T> fetched = await Result.guardAsync<Result<T>>(fetch).then(
      (Result<Result<T>> guarded) => switch (guarded) {
        Success<Result<T>>(:final value) => value,
        Failed<Result<T>>(:final failure) => Failed<T>(failure),
      },
    );
    if (fetched case Failed<T>(:final failure)) {
      return Failed<RevalidationOutcome<T>>(failure);
    }

    final T value = fetched.valueOrNull as T;
    final Result<void> persisted =
        await Result.guardAsync<Result<void>>(() => persist(value)).then(
          (Result<Result<void>> guarded) => switch (guarded) {
            Success<Result<void>>(:final value) => value,
            Failed<Result<void>>(:final failure) => Failed<void>(failure),
          },
        );
    if (persisted case Failed<void>(:final failure)) {
      return Failed<RevalidationOutcome<T>>(failure);
    }

    final String fetchedSource = sourceOf(value).trim();
    final String source = fetchedSource.isNotEmpty
        ? fetchedSource
        : (cachedSource?.trim().isNotEmpty ?? false)
        ? cachedSource!.trim()
        : 'unknown';
    final Result<void> metadataSaved = await metadata.save(
      CacheMetadataEntry(
        cacheKey: cacheKey,
        dataType: dataType,
        source: source,
        fetchedAt: now.toUtc(),
        expiresAt: policy.expiresAt(dataType, now.toUtc()),
      ),
    );
    if (metadataSaved case Failed<void>(:final failure)) {
      return Failed<RevalidationOutcome<T>>(failure);
    }

    return Success<RevalidationOutcome<T>>(
      RevalidationOutcome<T>(
        disposition: RevalidationDisposition.refreshed,
        value: value,
      ),
    );
  }
}
