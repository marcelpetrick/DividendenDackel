import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/app/widgets/value_labels.dart';
import 'package:dividendendackel/features/refresh/portfolio_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 23, 12);

  Future<void> pump(WidgetTester tester, PortfolioRefreshState state) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: DataFreshnessBanner(state: state, now: now),
        ),
      ),
    );
  }

  testWidgets('explains that saved data is available before first refresh', (
    WidgetTester tester,
  ) async {
    await pump(tester, const PortfolioRefreshState());

    expect(find.text('Last updated saved data'), findsOneWidget);
    expect(find.byIcon(Icons.offline_pin_outlined), findsOneWidget);
  });

  testWidgets('shows age and background refresh without hiding content', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      PortfolioRefreshState(
        isRefreshing: true,
        lastCompletedAt: now.subtract(const Duration(minutes: 42)),
      ),
    );

    expect(find.text('Last updated 42 min ago — refreshing…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('states that cached data remains visible after failures', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      PortfolioRefreshState(
        lastCompletedAt: now.subtract(const Duration(hours: 2)),
        failureCount: 2,
      ),
    );

    expect(
      find.text(
        'Last updated 2 h ago · 2 source failures; saved data remains visible',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
  });
}
