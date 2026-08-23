import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/core/errors/result.dart';
import 'package:dividendendackel/domain/analytics/analytics.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/domain/repositories/repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persists complete/partial local valuation evidence at most once per value.
final class PortfolioValuationRecorder {
  /// Creates the recorder.
  PortfolioValuationRecorder(this.repository);

  final PortfolioRepository repository;
  final Set<String> _pending = <String>{};
  final Map<String, String> _lastValues = <String, String>{};

  /// Records same-day quote snapshots without turning stale quotes into today.
  Future<Result<void>> record({
    required String scopeId,
    required PortfolioOverview overview,
    required List<PortfolioActivity> activities,
    required Map<String, Currency> instrumentCurrencies,
  }) async {
    final String activityRevision = activities
        .map(
          (PortfolioActivity activity) =>
              '${activity.id ?? 'new'}:${activity.type.name}:'
              '${activity.occurredAt.toUtc().toIso8601String()}',
        )
        .join('|');
    final List<PortfolioValuationSnapshot> snapshots =
        PortfolioPerformanceCalculator.currentValuations(
          scopeId: scopeId,
          overview: overview,
          activities: activities,
          instrumentCurrencies: instrumentCurrencies,
        );
    final List<PortfolioValuationSnapshot> changed =
        <PortfolioValuationSnapshot>[];
    for (final PortfolioValuationSnapshot snapshot in snapshots) {
      final String key =
          '${snapshot.scopeId}|${snapshot.currency.code}|${snapshot.observedAt.toIso8601String()}';
      final String value =
          '${snapshot.value.amount}|${snapshot.positionCount}|'
          '${snapshot.pricedPositionCount}|$activityRevision';
      if (_lastValues[key] != value && !_pending.contains(key)) {
        _pending.add(key);
        changed.add(snapshot);
      }
    }
    if (changed.isEmpty) return const Result<void>.success(null);
    final Result<void> result = await repository.saveValuationSnapshots(
      changed,
    );
    for (final PortfolioValuationSnapshot snapshot in changed) {
      final String key =
          '${snapshot.scopeId}|${snapshot.currency.code}|${snapshot.observedAt.toIso8601String()}';
      _pending.remove(key);
      if (result.isSuccess) {
        _lastValues[key] =
            '${snapshot.value.amount}|${snapshot.positionCount}|'
            '${snapshot.pricedPositionCount}|$activityRevision';
      }
    }
    return result;
  }
}

/// Recorder dependency; tests can disable automatic writes independently.
final Provider<PortfolioValuationRecorder> portfolioValuationRecorderProvider =
    Provider<PortfolioValuationRecorder>(
      (Ref ref) =>
          PortfolioValuationRecorder(ref.watch(portfolioRepositoryProvider)),
    );

/// Allows hermetic widget tests and special embeds to suppress snapshots.
final Provider<bool> automaticPortfolioValuationEnabledProvider =
    Provider<bool>((Ref ref) => true);
