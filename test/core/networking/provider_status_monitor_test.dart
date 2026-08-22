import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/core/networking/provider_status_monitor.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/data/database/app_database.dart';
import 'package:dividendendackel/data/repositories/drift_provider_status_repository.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftProviderStatusRepository repository;
  late RequestCoordinator coordinator;
  late ProviderStatusMonitor monitor;

  setUp(() {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repository = DriftProviderStatusRepository(db);
    coordinator = RequestCoordinator(
      defaultPolicy: ProviderRequestPolicy(maxAttempts: 1),
    );
    monitor = ProviderStatusMonitor(
      coordinator: coordinator,
      repository: repository,
    );
  });

  tearDown(() async {
    await coordinator.dispose();
    await monitor.dispose();
    await db.close();
  });

  test('persists successful coordinator outcomes', () async {
    final CoordinatedRequest<int> request = coordinator.submit<int>(
      CoordinatorRequest<int>(
        key: 'sec:test',
        provider: 'sec',
        operation: 'test',
        execute: (_) async => const Success<int>(42),
      ),
    );

    expect((await request.result).valueOrNull, 42);
    await monitor.dispose();

    final ProviderStatus status = (await repository.watchAll().first).single;
    expect(status.health, ProviderHealth.healthy);
    expect(status.lastRequestAt, isNotNull);
  });

  test('persists rate-limit reset time and safe error text', () async {
    final DateTime retryAt = DateTime.now().toUtc().add(
      const Duration(hours: 1),
    );
    final CoordinatedRequest<int> request = coordinator.submit<int>(
      CoordinatorRequest<int>(
        key: 'sec:limited',
        provider: 'sec',
        operation: 'test',
        execute: (_) async => Failed<int>(
          RateLimitFailure(retryAt: retryAt, technicalDetail: 'HTTP 429'),
        ),
      ),
    );

    expect((await request.result).failureOrNull, isA<RateLimitFailure>());
    await monitor.dispose();

    final ProviderStatus status = (await repository.watchAll().first).single;
    expect(status.health, ProviderHealth.rateLimited);
    expect(status.rateLimitResetAt, retryAt);
    expect(status.lastErrorMessage, isNot(contains('HTTP 429')));
  });
}
