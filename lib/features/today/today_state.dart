import 'dart:convert';

import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locally persisted, privacy-safe baseline for “since last refresh”.
final class TodaySnapshot {
  /// Creates a snapshot.
  const TodaySnapshot({
    required this.capturedAt,
    required this.holdings,
    required this.dividends,
    required this.quotes,
  });
  final DateTime capturedAt;
  final Map<String, String> holdings;
  final Map<String, String> dividends;
  final Map<String, String> quotes;
}

/// Visible difference from the previously persisted snapshot.
final class TodayChanges {
  /// Creates a comparison result.
  const TodayChanges({
    required this.previousAt,
    required this.holdingChanges,
    required this.dividendChanges,
    required this.quoteChanges,
  });
  final DateTime? previousAt;
  final int holdingChanges;
  final int dividendChanges;
  final int quoteChanges;

  /// Whether this is the first locally captured baseline.
  bool get isFirstSnapshot => previousAt == null;

  /// Total changed records, without pretending they share a unit.
  bool get hasChanges =>
      holdingChanges > 0 || dividendChanges > 0 || quoteChanges > 0;
}

/// Snapshot persistence boundary.
abstract interface class TodaySnapshotStore {
  /// Loads the previous snapshot.
  Future<TodaySnapshot?> load();

  /// Atomically replaces the baseline.
  Future<void> save(TodaySnapshot snapshot);
}

/// SharedPreferences implementation for Android and Linux.
final class PlatformTodaySnapshotStore implements TodaySnapshotStore {
  /// Creates the platform store.
  PlatformTodaySnapshotStore({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;

  static const String _key = 'today.snapshot.v1';
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<TodaySnapshot?> load() async {
    final String? value = (await _preferences()).getString(_key);
    return value == null ? null : TodaySnapshotCodec.decode(value);
  }

  @override
  Future<void> save(TodaySnapshot snapshot) async {
    if (!await (await _preferences()).setString(
      _key,
      TodaySnapshotCodec.encode(snapshot),
    )) {
      throw StateError('The platform preference store rejected the write.');
    }
  }
}

/// Stable snapshot JSON codec.
abstract final class TodaySnapshotCodec {
  /// Encodes one snapshot.
  static String encode(TodaySnapshot value) => jsonEncode(<String, Object>{
    'capturedAt': value.capturedAt.toIso8601String(),
    'holdings': value.holdings,
    'dividends': value.dividends,
    'quotes': value.quotes,
  });

  /// Decodes one snapshot and rejects malformed persisted data.
  static TodaySnapshot decode(String source) {
    final Object? decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Today snapshot must be an object.');
    }
    Map<String, String> strings(String field) {
      final Object? raw = decoded[field];
      if (raw is! Map<String, dynamic>) {
        throw FormatException('Today snapshot $field must be an object.');
      }
      return <String, String>{
        for (final MapEntry<String, dynamic> entry in raw.entries)
          if (entry.value is String) entry.key: entry.value as String,
      };
    }

    return TodaySnapshot(
      capturedAt: DateTime.parse(decoded['capturedAt'] as String),
      holdings: strings('holdings'),
      dividends: strings('dividends'),
      quotes: strings('quotes'),
    );
  }
}

/// Creates and compares deterministic snapshots.
abstract final class TodayChangesCalculator {
  /// Builds current state without storing user-visible names or notes.
  static TodaySnapshot snapshot({
    required DateTime capturedAt,
    required Iterable<Holding> holdings,
    required Iterable<DividendEvent> dividends,
    required Map<String, Quote> quotes,
  }) => TodaySnapshot(
    capturedAt: capturedAt,
    holdings: <String, String>{
      for (final Holding holding in holdings)
        holding.instrumentId: holding.quantity.toString(),
    },
    dividends: <String, String>{
      for (final DividendEvent event in dividends)
        _eventKey(event): _eventValue(event),
    },
    quotes: <String, String>{
      for (final MapEntry<String, Quote> entry in quotes.entries)
        entry.key:
            '${entry.value.price.currency.code}:${entry.value.price.amount}',
    },
  );

  /// Compares keyed values, counting additions, removals and modifications.
  static TodayChanges compare(TodaySnapshot? previous, TodaySnapshot current) =>
      TodayChanges(
        previousAt: previous?.capturedAt,
        holdingChanges: _changed(previous?.holdings, current.holdings),
        dividendChanges: _changed(previous?.dividends, current.dividends),
        quoteChanges: _changed(previous?.quotes, current.quotes),
      );

  static int _changed(Map<String, String>? before, Map<String, String> after) {
    if (before == null) return 0;
    final Set<String> keys = <String>{...before.keys, ...after.keys};
    return keys.where((String key) => before[key] != after[key]).length;
  }

  static String _eventKey(DividendEvent event) => <Object?>[
    event.instrumentId,
    event.exDate?.toIso8601String(),
    event.paymentDate?.toIso8601String(),
  ].join('|');

  static String _eventValue(DividendEvent event) => <Object>[
    event.amountPerShare.currency.code,
    event.amountPerShare.amount,
    event.status.name,
  ].join('|');
}

/// Platform store, overridden by tests.
final Provider<TodaySnapshotStore> todaySnapshotStoreProvider =
    Provider<TodaySnapshotStore>((Ref ref) => PlatformTodaySnapshotStore());

/// Changes since the prior successful local refresh baseline.
final FutureProvider<TodayChanges> todayChangesProvider =
    FutureProvider<TodayChanges>((Ref ref) async {
      final Future<List<Holding>> holdings = ref.watch(holdingsProvider.future);
      final Future<List<DividendEvent>> dividends = ref.watch(
        upcomingDividendPaymentsProvider(365).future,
      );
      final Future<Map<String, Quote>> quotes = ref.watch(
        quotesProvider.future,
      );
      final TodaySnapshotStore store = ref.watch(todaySnapshotStoreProvider);
      final TodaySnapshot current = TodayChangesCalculator.snapshot(
        capturedAt: ref.watch(clockProvider).now(),
        holdings: await holdings,
        dividends: await dividends,
        quotes: await quotes,
      );
      TodaySnapshot? previous;
      try {
        previous = await store.load();
      } on Object {
        previous = null;
      }
      final TodayChanges changes = TodayChangesCalculator.compare(
        previous,
        current,
      );
      await store.save(current);
      return changes;
    });
