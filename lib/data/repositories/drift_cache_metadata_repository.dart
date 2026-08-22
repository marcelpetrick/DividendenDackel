import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart';

/// Drift-backed cache-expiry bookkeeping.
final class DriftCacheMetadataRepository implements CacheMetadataRepository {
  /// Creates the repository over [db].
  DriftCacheMetadataRepository(this.db);

  /// Local database.
  final AppDatabase db;

  @override
  Future<Result<CacheMetadataEntry?>> find(String cacheKey) =>
      Result.guardAsync<CacheMetadataEntry?>(() async {
        final DbCacheMetadata? row =
            await (db.select(db.cacheMetadata)..where(
                  ($CacheMetadataTable table) =>
                      table.cacheKey.equals(cacheKey),
                ))
                .getSingleOrNull();
        return row == null ? null : _toDomain(row);
      });

  @override
  Future<Result<void>> save(CacheMetadataEntry entry) =>
      Result.guardAsync<void>(() async {
        await db
            .into(db.cacheMetadata)
            .insertOnConflictUpdate(
              CacheMetadataCompanion.insert(
                cacheKey: entry.cacheKey,
                dataType: entry.dataType.name,
                source: entry.source,
                fetchedAt: entry.fetchedAt.toUtc(),
                expiresAt: entry.expiresAt.toUtc(),
                etag: Value<String?>(entry.etag),
              ),
            );
      });

  @override
  Future<Result<void>> remove(String cacheKey) =>
      Result.guardAsync<void>(() async {
        await (db.delete(db.cacheMetadata)..where(
              ($CacheMetadataTable table) => table.cacheKey.equals(cacheKey),
            ))
            .go();
      });

  static CacheMetadataEntry _toDomain(DbCacheMetadata row) {
    final CacheDataType? dataType = CacheDataType.values
        .where((CacheDataType value) => value.name == row.dataType)
        .firstOrNull;
    if (dataType == null) {
      throw ParsingFailure(
        technicalDetail: 'Unknown cache data type: ${row.dataType}',
      );
    }
    return CacheMetadataEntry(
      cacheKey: row.cacheKey,
      dataType: dataType,
      source: row.source,
      fetchedAt: row.fetchedAt.toUtc(),
      expiresAt: row.expiresAt.toUtc(),
      etag: row.etag,
    );
  }
}
