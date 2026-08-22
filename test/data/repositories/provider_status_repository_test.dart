import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_provider_status_repository.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderStatusRepository repository;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = DriftProviderStatusRepository(db);
  });

  tearDown(() => db.close());

  test('starts empty and retains the latest request time', () async {
    expect(await repository.watchAll().first, isEmpty);

    final DateTime startedAt = DateTime.utc(2026, 8, 23, 10);
    expect(
      (await repository.recordRequestStarted('sec', startedAt)).isSuccess,
      isTrue,
    );

    final ProviderStatus status = (await repository.watchAll().first).single;
    expect(status.providerId, 'sec');
    expect(status.health, ProviderHealth.unknown);
    expect(status.lastRequestAt, startedAt);
  });

  test('records and then clears a privacy-safe provider error', () async {
    final DateTime retryAt = DateTime.utc(2026, 8, 23, 11);
    await repository.recordFailure(
      'frankfurter',
      DateTime.utc(2026, 8, 23, 10),
      RateLimitFailure(
        retryAt: retryAt,
        technicalDetail: 'secret diagnostic must not be persisted',
      ),
    );

    ProviderStatus status = (await repository.watchAll().first).single;
    expect(status.health, ProviderHealth.rateLimited);
    expect(status.rateLimitResetAt, retryAt);
    expect(status.lastErrorCategory, FailureCategory.rateLimited);
    expect(
      status.lastErrorMessage,
      'Data source limit reached. Next refresh available later.',
    );
    expect(status.lastErrorMessage, isNot(contains('secret diagnostic')));

    await repository.recordSuccess(
      'frankfurter',
      DateTime.utc(2026, 8, 23, 12),
    );
    status = (await repository.watchAll().first).single;
    expect(status.health, ProviderHealth.healthy);
    expect(status.rateLimitResetAt, isNull);
    expect(status.lastErrorCategory, isNull);
    expect(status.lastErrorMessage, isNull);
  });

  test('increments cache counters without losing provider health', () async {
    await repository.recordSuccess('sec', DateTime.utc(2026, 8, 23));
    await repository.recordCacheAccess('sec', hit: true);
    await repository.recordCacheAccess('sec', hit: true);
    await repository.recordCacheAccess('sec', hit: false);

    final ProviderStatus status = (await repository.watchAll().first).single;
    expect(status.health, ProviderHealth.healthy);
    expect(status.cacheHits, 2);
    expect(status.cacheMisses, 1);
    expect(status.cacheHitRate, closeTo(2 / 3, 0.0001));
  });
}
