import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/drift.dart';

/// Drift-backed provider health and cache telemetry.
final class DriftProviderStatusRepository implements ProviderStatusRepository {
  /// Creates the repository over [db].
  DriftProviderStatusRepository(this.db);

  /// Local database.
  final AppDatabase db;

  @override
  Stream<List<ProviderStatus>> watchAll() =>
      (db.select(db.providerStates)
            ..orderBy(<OrderClauseGenerator<$ProviderStatesTable>>[
              ($ProviderStatesTable table) =>
                  OrderingTerm.asc(table.providerId),
            ]))
          .watch()
          .map(
            (List<DbProviderState> rows) =>
                rows.map(_toDomain).toList(growable: false),
          );

  @override
  Future<Result<void>> recordRequestStarted(String providerId, DateTime at) =>
      _mutate(providerId, (DbProviderState? current) {
        final DbProviderState state = current ?? _initial(providerId);
        return state.copyWith(lastRequestAt: Value<DateTime?>(at.toUtc()));
      });

  @override
  Future<Result<void>> recordSuccess(String providerId, DateTime at) =>
      _mutate(providerId, (DbProviderState? current) {
        final DbProviderState state = current ?? _initial(providerId);
        return state.copyWith(
          health: ProviderHealth.healthy.name,
          lastRequestAt: Value<DateTime?>(at.toUtc()),
          rateLimitResetAt: const Value<DateTime?>(null),
          lastErrorCategory: const Value<String?>(null),
          lastErrorDetail: const Value<String?>(null),
        );
      });

  @override
  Future<Result<void>> recordFailure(
    String providerId,
    DateTime at,
    Failure failure,
  ) => _mutate(providerId, (DbProviderState? current) {
    final DbProviderState state = current ?? _initial(providerId);
    return state.copyWith(
      health: _healthFor(failure.category).name,
      lastRequestAt: Value<DateTime?>(at.toUtc()),
      rateLimitResetAt: Value<DateTime?>(
        failure is RateLimitFailure ? failure.retryAt?.toUtc() : null,
      ),
      lastErrorCategory: Value<String?>(failure.category.name),
      // Failure.message is designed for display. Technical detail and cause
      // stay in developer logs and never enter this user-facing record.
      lastErrorDetail: Value<String?>(failure.message),
    );
  });

  @override
  Future<Result<void>> recordCacheAccess(
    String providerId, {
    required bool hit,
  }) => _mutate(providerId, (DbProviderState? current) {
    final DbProviderState state = current ?? _initial(providerId);
    return state.copyWith(
      cacheHits: hit ? state.cacheHits + 1 : state.cacheHits,
      cacheMisses: hit ? state.cacheMisses : state.cacheMisses + 1,
    );
  });

  Future<Result<void>> _mutate(
    String providerId,
    DbProviderState Function(DbProviderState? current) change,
  ) => Result.guardAsync<void>(() async {
    if (providerId.trim().isEmpty) {
      throw ArgumentError.value(providerId, 'providerId', 'must not be empty');
    }
    await db.transaction(() async {
      final DbProviderState? current =
          await (db.select(db.providerStates)..where(
                ($ProviderStatesTable table) =>
                    table.providerId.equals(providerId),
              ))
              .getSingleOrNull();
      await db
          .into(db.providerStates)
          .insertOnConflictUpdate(change(current).toCompanion(false));
    });
  });

  static DbProviderState _initial(String providerId) => DbProviderState(
    providerId: providerId,
    health: ProviderHealth.unknown.name,
    cacheHits: 0,
    cacheMisses: 0,
  );

  static ProviderHealth _healthFor(FailureCategory category) =>
      switch (category) {
        FailureCategory.network => ProviderHealth.offline,
        FailureCategory.rateLimited => ProviderHealth.rateLimited,
        FailureCategory.authentication => ProviderHealth.authenticationError,
        FailureCategory.cancelled => ProviderHealth.unknown,
        FailureCategory.invalidInstrument ||
        FailureCategory.noData => ProviderHealth.healthy,
        FailureCategory.timeout ||
        FailureCategory.providerUnavailable ||
        FailureCategory.parsing ||
        FailureCategory.stale ||
        FailureCategory.unexpected => ProviderHealth.degraded,
      };

  static ProviderStatus _toDomain(DbProviderState row) {
    final ProviderHealth? health = ProviderHealth.values
        .where((ProviderHealth value) => value.name == row.health)
        .firstOrNull;
    final FailureCategory? category = row.lastErrorCategory == null
        ? null
        : FailureCategory.values
              .where(
                (FailureCategory value) => value.name == row.lastErrorCategory,
              )
              .firstOrNull;
    if (health == null || (row.lastErrorCategory != null && category == null)) {
      throw ParsingFailure(
        technicalDetail: 'Unknown provider status value for ${row.providerId}',
      );
    }
    return ProviderStatus(
      providerId: row.providerId,
      health: health,
      lastRequestAt: row.lastRequestAt?.toUtc(),
      rateLimitResetAt: row.rateLimitResetAt?.toUtc(),
      lastErrorCategory: category,
      lastErrorMessage: row.lastErrorDetail,
      cacheHits: row.cacheHits,
      cacheMisses: row.cacheMisses,
    );
  }
}
