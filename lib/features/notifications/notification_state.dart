import 'dart:async';

import 'package:dividendendackel/app/providers.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-selected amount of notification activity.
enum NotificationMode { disabled, importantOnly, all }

/// Importance used by the app's conservative filtering rules.
enum PortfolioNotificationImportance { normal, important }

/// One due, factual local notification.
final class PortfolioNotification {
  const PortfolioNotification({
    required this.key,
    required this.title,
    required this.body,
    required this.importance,
  });
  final String key;
  final String title;
  final String body;
  final PortfolioNotificationImportance importance;

  int get platformId {
    var hash = 0x811c9dc5;
    for (final int unit in key.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}

/// Deterministically selects due events and uses descriptive, non-urgent copy.
abstract final class PortfolioNotificationPlanner {
  static List<PortfolioNotification> plan({
    required NotificationMode mode,
    required DateTime now,
    required Map<String, Instrument> instruments,
    required List<DividendEvent> dividends,
    required List<EarningsEvent> earnings,
    required List<CorporateEvent> corporateEvents,
    required List<Filing> filings,
  }) {
    if (mode == NotificationMode.disabled) {
      return const <PortfolioNotification>[];
    }
    final DateTime today = _day(now);
    final DateTime tomorrow = today.add(const Duration(days: 1));
    final List<PortfolioNotification> result = <PortfolioNotification>[];
    String name(String id) => instruments[id]?.name ?? 'A followed company';

    for (final DividendEvent event in dividends) {
      if (_dayOrNull(event.paymentDate) == today) {
        result.add(
          PortfolioNotification(
            key: _dividendKey('payment', event, today),
            title: 'Dividend payment expected today',
            body:
                '${name(event.instrumentId)} has a ${event.status.name} '
                'payment of ${event.amountPerShare.format(withSymbol: true)} '
                'per share scheduled for today.',
            importance: PortfolioNotificationImportance.important,
          ),
        );
      }
      if (_dayOrNull(event.exDate) == tomorrow) {
        result.add(
          PortfolioNotification(
            key: _dividendKey('ex-date', event, tomorrow),
            title: 'Ex-dividend date tomorrow',
            body:
                '${name(event.instrumentId)} has a ${event.status.name} '
                'ex-dividend date tomorrow.',
            importance: PortfolioNotificationImportance.normal,
          ),
        );
      }
    }
    for (final EarningsEvent event in earnings) {
      final DateTime day = _day(event.scheduledFor);
      if (day == today || day == tomorrow) {
        final bool isToday = day == today;
        result.add(
          PortfolioNotification(
            key: 'earnings:${event.instrumentId}:${day.toIso8601String()}',
            title: 'Earnings ${isToday ? 'today' : 'tomorrow'}',
            body:
                '${name(event.instrumentId)} is scheduled to report '
                '${isToday ? 'today' : 'tomorrow'}; timing is '
                '${_earningsTiming(event.timing)}.',
            importance: isToday
                ? PortfolioNotificationImportance.important
                : PortfolioNotificationImportance.normal,
          ),
        );
      }
    }
    for (final CorporateEvent event in corporateEvents) {
      final DateTime day = _day(event.scheduledFor);
      if (day == today || day == tomorrow) {
        result.add(
          PortfolioNotification(
            key: 'company-event:${event.id}:$day',
            title: day == today
                ? 'Company event today'
                : 'Company event tomorrow',
            body: '${name(event.instrumentId)}: ${event.title}.',
            importance: PortfolioNotificationImportance.normal,
          ),
        );
      }
    }
    for (final Filing filing in filings) {
      if (filing.isMaterialForm && _day(filing.filedAt) == today) {
        result.add(
          PortfolioNotification(
            key: 'filing:${filing.id}',
            title: 'New ${filing.formType} filing',
            body:
                '${name(filing.instrumentId)} filed ${filing.formType} today.',
            importance: PortfolioNotificationImportance.important,
          ),
        );
      }
    }
    return List<PortfolioNotification>.unmodifiable(
      mode == NotificationMode.importantOnly
          ? result.where(
              (item) =>
                  item.importance == PortfolioNotificationImportance.important,
            )
          : result,
    );
  }

  static DateTime _day(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);
  static DateTime? _dayOrNull(DateTime? value) =>
      value == null ? null : _day(value);
  static String _dividendKey(String kind, DividendEvent event, DateTime day) =>
      <Object?>[
        kind,
        event.instrumentId,
        day.toIso8601String(),
        event.amountPerShare.currency.code,
        event.amountPerShare.amount,
        event.exDate?.toUtc().toIso8601String(),
        event.paymentDate?.toUtc().toIso8601String(),
        event.declarationDate?.toUtc().toIso8601String(),
        event.recordDate?.toUtc().toIso8601String(),
        event.reportedPeriodStart?.toUtc().toIso8601String(),
        event.reportedPeriodEnd?.toUtc().toIso8601String(),
      ].join(':');
  static String _earningsTiming(EarningsTiming timing) => switch (timing) {
    EarningsTiming.beforeMarketOpen => 'before market open',
    EarningsTiming.afterMarketClose => 'after market close',
    EarningsTiming.duringMarketHours => 'during market hours',
    EarningsTiming.unspecified => 'not supplied',
  };
}

abstract interface class NotificationPreferenceStore {
  Future<NotificationMode> loadMode();
  Future<void> saveMode(NotificationMode mode);
  Future<Set<String>> loadDelivered();
  Future<void> markDelivered(String key);
}

final class PlatformNotificationPreferenceStore
    implements NotificationPreferenceStore {
  PlatformNotificationPreferenceStore({
    Future<SharedPreferences> Function()? preferences,
  }) : _preferences = preferences ?? SharedPreferences.getInstance;
  static const String _modeKey = 'notifications.mode';
  static const String _deliveredKey = 'notifications.delivered';
  final Future<SharedPreferences> Function() _preferences;

  @override
  Future<NotificationMode> loadMode() async {
    final String? saved = (await _preferences()).getString(_modeKey);
    return NotificationMode.values
            .where((mode) => mode.name == saved)
            .firstOrNull ??
        NotificationMode.disabled;
  }

  @override
  Future<void> saveMode(NotificationMode mode) async {
    if (!await (await _preferences()).setString(_modeKey, mode.name)) {
      throw StateError('The platform preference store rejected the write.');
    }
  }

  @override
  Future<Set<String>> loadDelivered() async =>
      ((await _preferences()).getStringList(_deliveredKey) ?? const <String>[])
          .toSet();

  @override
  Future<void> markDelivered(String key) async {
    final SharedPreferences preferences = await _preferences();
    final List<String> delivered = <String>{
      ...preferences.getStringList(_deliveredKey) ?? const <String>[],
      key,
    }.toList(growable: false);
    final List<String> bounded = delivered.length <= 250
        ? delivered
        : delivered.sublist(delivered.length - 250);
    if (!await preferences.setStringList(_deliveredKey, bounded)) {
      throw StateError('The platform preference store rejected the write.');
    }
  }
}

abstract interface class LocalNotificationGateway {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> show(PortfolioNotification notification);
}

/// Serializes notification reconciliation so simultaneous startup, resume and
/// settings changes cannot deliver the same event more than once.
final class NotificationReconciler {
  NotificationReconciler({required this.store, required this.gateway});

  final NotificationPreferenceStore store;
  final LocalNotificationGateway gateway;
  Future<void>? _inFlight;

  Future<void> reconcile(
    Future<List<PortfolioNotification>> Function() loadPlanned,
  ) async {
    final Future<void>? existing = _inFlight;
    if (existing != null) return existing;
    final Future<void> current = _reconcile(loadPlanned);
    _inFlight = current;
    try {
      await current;
    } finally {
      if (identical(_inFlight, current)) _inFlight = null;
    }
  }

  Future<void> _reconcile(
    Future<List<PortfolioNotification>> Function() loadPlanned,
  ) async {
    final List<PortfolioNotification> planned = await loadPlanned();
    final Set<String> delivered = await store.loadDelivered();
    for (final PortfolioNotification notification in planned) {
      if (delivered.contains(notification.key)) continue;
      await gateway.show(notification);
      await store.markDelivered(notification.key);
      delivered.add(notification.key);
    }
  }
}

final class PluginLocalNotificationGateway implements LocalNotificationGateway {
  PluginLocalNotificationGateway([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        linux: LinuxInitializationSettings(defaultActionName: 'Open'),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await initialize();
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  @override
  Future<void> show(PortfolioNotification notification) async {
    await initialize();
    await _plugin.show(
      id: notification.platformId,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'portfolio_events',
          'Portfolio events',
          channelDescription: 'Factual events for followed companies',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        linux: LinuxNotificationDetails(),
      ),
      payload: notification.key,
    );
  }
}

final class NotificationSettingsState {
  const NotificationSettingsState({
    this.mode = NotificationMode.disabled,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });
  final NotificationMode mode;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
}

final Provider<NotificationPreferenceStore>
notificationPreferenceStoreProvider = Provider(
  (Ref ref) => PlatformNotificationPreferenceStore(),
);
final Provider<LocalNotificationGateway> localNotificationGatewayProvider =
    Provider((Ref ref) => PluginLocalNotificationGateway());
final Provider<NotificationReconciler> notificationReconcilerProvider =
    Provider(
      (Ref ref) => NotificationReconciler(
        store: ref.watch(notificationPreferenceStoreProvider),
        gateway: ref.watch(localNotificationGatewayProvider),
      ),
    );

final class NotificationSettingsController
    extends Notifier<NotificationSettingsState> {
  bool _disposed = false;

  @override
  NotificationSettingsState build() {
    ref.onDispose(() => _disposed = true);
    unawaited(_load());
    return const NotificationSettingsState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final NotificationMode mode = await ref
          .read(notificationPreferenceStoreProvider)
          .loadMode();
      if (!_disposed) {
        state = NotificationSettingsState(mode: mode);
        if (mode != NotificationMode.disabled) unawaited(sync());
      }
    } on Object {
      if (!_disposed) {
        state = const NotificationSettingsState(
          errorMessage: 'Could not load notification settings.',
        );
      }
    }
  }

  Future<void> select(NotificationMode mode) async {
    state = NotificationSettingsState(mode: state.mode, isSaving: true);
    try {
      if (mode != NotificationMode.disabled &&
          !await ref
              .read(localNotificationGatewayProvider)
              .requestPermission()) {
        if (!_disposed) {
          state = NotificationSettingsState(
            mode: state.mode,
            errorMessage:
                'Notification permission was not granted. The setting was not changed.',
          );
        }
        return;
      }
      await ref.read(notificationPreferenceStoreProvider).saveMode(mode);
      if (!_disposed) state = NotificationSettingsState(mode: mode);
      if (mode != NotificationMode.disabled) unawaited(sync());
    } on Object {
      if (!_disposed) {
        state = NotificationSettingsState(
          mode: state.mode,
          errorMessage: 'Could not save notification settings.',
        );
      }
    }
  }

  Future<void> sync() async {
    final NotificationMode mode = state.mode;
    if (mode == NotificationMode.disabled || state.isLoading) return;
    try {
      await ref.read(notificationReconcilerProvider).reconcile(() async {
        final DateTime now = ref.read(clockProvider).now().toUtc();
        final Set<String> followed = await ref.read(
          followedInstrumentIdsProvider.future,
        );
        return PortfolioNotificationPlanner.plan(
          mode: mode,
          now: now,
          instruments: await ref.read(instrumentsByIdProvider.future),
          dividends: <DividendEvent>{
            ...await ref.read(upcomingDividendsProvider(2).future),
            ...await ref.read(upcomingDividendPaymentsProvider(2).future),
          }.toList(growable: false),
          earnings: await ref.read(upcomingEarningsProvider(2).future),
          corporateEvents: await ref.read(
            upcomingCorporateEventsProvider(2).future,
          ),
          filings: await ref
              .read(marketDataRepositoryProvider)
              .watchRecentFilings(instrumentIds: followed, limit: 50)
              .first,
        );
      });
    } on Object {
      if (!_disposed) {
        state = NotificationSettingsState(
          mode: mode,
          errorMessage:
              'Could not reconcile notifications. Saved portfolio data remains unchanged.',
        );
      }
    }
  }
}

final NotifierProvider<
  NotificationSettingsController,
  NotificationSettingsState
>
notificationSettingsProvider =
    NotifierProvider<NotificationSettingsController, NotificationSettingsState>(
      NotificationSettingsController.new,
    );
