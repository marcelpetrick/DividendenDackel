import 'dart:async';

import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/notifications/notification_settings_screen.dart';
import 'package:dividendendackel/features/notifications/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23, 12);
  final Provenance provenance = Provenance(source: 'test', fetchedAt: now);
  const Instrument instrument = Instrument(
    internalId: 'asset',
    symbol: 'AST',
    name: 'Example AG',
    currency: Currency.eur,
  );

  List<PortfolioNotification> plan(NotificationMode mode) =>
      PortfolioNotificationPlanner.plan(
        mode: mode,
        now: now,
        instruments: const <String, Instrument>{'asset': instrument},
        dividends: <DividendEvent>[
          DividendEvent(
            instrumentId: 'asset',
            amountPerShare: Money.parse('2', Currency.eur),
            status: DividendStatus.confirmed,
            paymentDate: now,
            exDate: now.add(const Duration(days: 1)),
            provenance: provenance,
          ),
        ],
        earnings: <EarningsEvent>[
          EarningsEvent(
            instrumentId: 'asset',
            scheduledFor: now,
            status: EarningsStatus.confirmed,
            provenance: provenance,
          ),
          EarningsEvent(
            instrumentId: 'asset',
            scheduledFor: now.add(const Duration(days: 1)),
            status: EarningsStatus.confirmed,
            provenance: provenance,
          ),
        ],
        corporateEvents: <CorporateEvent>[
          CorporateEvent(
            id: 'meeting',
            instrumentId: 'asset',
            scheduledFor: now,
            type: CorporateEventType.shareholderMeeting,
            status: CorporateEventStatus.confirmed,
            title: 'Shareholder meeting',
            provenance: provenance,
          ),
        ],
        filings: <Filing>[
          Filing(
            id: 'filing',
            instrumentId: 'asset',
            formType: '8-K',
            filedAt: now,
            url: Uri.parse('https://example.test/filing'),
            provenance: provenance,
          ),
        ],
      );

  test('disabled mode plans nothing', () {
    expect(plan(NotificationMode.disabled), isEmpty);
  });

  test('important-only excludes tomorrow and routine company events', () {
    final List<PortfolioNotification> notifications = plan(
      NotificationMode.importantOnly,
    );

    expect(notifications.map((item) => item.title), <String>[
      'Dividend payment expected today',
      'Earnings today',
      'New 8-K filing',
    ]);
  });

  test('all mode includes every due factual category with stable ids', () {
    final List<PortfolioNotification> first = plan(NotificationMode.all);
    final List<PortfolioNotification> second = plan(NotificationMode.all);

    expect(first, hasLength(6));
    expect(
      first.map((item) => item.platformId),
      second.map((item) => item.platformId),
    );
    final String copy = first
        .expand((item) => <String>[item.title, item.body])
        .join(' ')
        .toLowerCase();
    expect(copy, isNot(contains('buy')));
    expect(copy, isNot(contains('sell')));
    expect(copy, isNot(contains('urgent')));
  });

  test('same-day dividend payments retain distinct delivery identities', () {
    final List<PortfolioNotification> notifications =
        PortfolioNotificationPlanner.plan(
          mode: NotificationMode.all,
          now: now,
          instruments: const <String, Instrument>{'asset': instrument},
          dividends: <DividendEvent>[
            for (final String amount in <String>['1', '2'])
              DividendEvent(
                instrumentId: 'asset',
                amountPerShare: Money.parse(amount, Currency.eur),
                status: DividendStatus.confirmed,
                paymentDate: now,
                provenance: provenance,
              ),
          ],
          earnings: const <EarningsEvent>[],
          corporateEvents: const <CorporateEvent>[],
          filings: const <Filing>[],
        );

    expect(notifications, hasLength(2));
    expect(notifications.map((item) => item.key).toSet(), hasLength(2));
    expect(notifications.map((item) => item.platformId).toSet(), hasLength(2));
  });

  test('overlapping sync requests share one reconciliation', () async {
    final _BlockingStore store = _BlockingStore();
    final _Gateway gateway = _Gateway(permission: true);
    final NotificationReconciler reconciler = NotificationReconciler(
      store: store,
      gateway: gateway,
    );
    int planLoads = 0;
    Future<List<PortfolioNotification>> loadPlan() async {
      planLoads += 1;
      return const <PortfolioNotification>[
        PortfolioNotification(
          key: 'payment:asset:today',
          title: 'Dividend payment expected today',
          body: 'Example AG has a confirmed payment today.',
          importance: PortfolioNotificationImportance.important,
        ),
      ];
    }

    final Future<void> first = reconciler.reconcile(loadPlan);
    final Future<void> second = reconciler.reconcile(loadPlan);
    await Future<void>.delayed(Duration.zero);

    expect(planLoads, 1);
    expect(store.deliveredLoads, 1);
    store.release.complete();
    await Future.wait(<Future<void>>[first, second]);

    expect(store.deliveredLoads, 1);
    expect(gateway.shown, hasLength(1));
  });

  test('permission denial keeps notifications disabled', () async {
    final _Store store = _Store();
    final _Gateway gateway = _Gateway(permission: false);
    final ProviderContainer container = ProviderContainer(
      overrides: [
        notificationPreferenceStoreProvider.overrideWithValue(store),
        localNotificationGatewayProvider.overrideWithValue(gateway),
      ],
    );
    addTearDown(container.dispose);
    container.read(notificationSettingsProvider);
    await Future<void>.delayed(Duration.zero);

    await container
        .read(notificationSettingsProvider.notifier)
        .select(NotificationMode.all);

    final NotificationSettingsState state = container.read(
      notificationSettingsProvider,
    );
    expect(state.mode, NotificationMode.disabled);
    expect(state.errorMessage, contains('not granted'));
    expect(store.mode, NotificationMode.disabled);
  });

  testWidgets('settings screen asks for permission after explicit opt-in', (
    WidgetTester tester,
  ) async {
    final _Store store = _Store();
    final _Gateway gateway = _Gateway(permission: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationPreferenceStoreProvider.overrideWithValue(store),
          localNotificationGatewayProvider.overrideWithValue(gateway),
        ],
        child: const MaterialApp(home: NotificationSettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(gateway.permissionRequests, 0);
    await tester.tap(find.text('Important only'));
    await tester.pumpAndSettle();

    expect(gateway.permissionRequests, 1);
    expect(store.mode, NotificationMode.disabled);
    expect(find.textContaining('was not granted'), findsOneWidget);
  });
}

final class _Store implements NotificationPreferenceStore {
  NotificationMode mode = NotificationMode.disabled;
  final Set<String> delivered = <String>{};

  @override
  Future<Set<String>> loadDelivered() async => delivered;

  @override
  Future<NotificationMode> loadMode() async => mode;

  @override
  Future<void> markDelivered(String key) async => delivered.add(key);

  @override
  Future<void> saveMode(NotificationMode value) async => mode = value;
}

final class _Gateway implements LocalNotificationGateway {
  _Gateway({required this.permission});
  final bool permission;
  final List<PortfolioNotification> shown = <PortfolioNotification>[];
  int permissionRequests = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    permissionRequests += 1;
    return permission;
  }

  @override
  Future<void> show(PortfolioNotification notification) async =>
      shown.add(notification);
}

final class _BlockingStore implements NotificationPreferenceStore {
  final Completer<void> release = Completer<void>();
  final Set<String> delivered = <String>{};
  int deliveredLoads = 0;

  @override
  Future<Set<String>> loadDelivered() async {
    deliveredLoads += 1;
    await release.future;
    return delivered;
  }

  @override
  Future<NotificationMode> loadMode() async => NotificationMode.importantOnly;

  @override
  Future<void> markDelivered(String key) async => delivered.add(key);

  @override
  Future<void> saveMode(NotificationMode mode) async {}
}
