import 'package:dividendendackel/app/theme/app_theme.dart';
import 'package:dividendendackel/features/onboarding/onboarding_screen.dart';
import 'package:dividendendackel/features/onboarding/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('completion is false by default and persists locally', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final PlatformOnboardingStore store = PlatformOnboardingStore();

    expect(await store.isComplete(), isFalse);
    await store.complete();
    expect(await store.isComplete(), isTrue);
  });

  testWidgets('shows exactly three short steps then completes', (
    WidgetTester tester,
  ) async {
    var completions = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: OnboardingScreen(
          onComplete: () async {
            completions++;
          },
        ),
      ),
    );

    expect(find.text('1 / 3'), findsOneWidget);
    expect(find.textContaining('stays on this device'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.textContaining('Follow only what matters'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text('3 / 3'), findsOneWidget);
    expect(find.textContaining('Facts keep their context'), findsOneWidget);
    expect(find.text('Go to Today'), findsOneWidget);

    await tester.tap(find.text('Go to Today'));
    await tester.pump();
    expect(completions, 1);
  });

  testWidgets('keeps the final step open when persistence fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingScreen(
          onComplete: () async => throw StateError('storage unavailable'),
        ),
      ),
    );
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.tap(find.text('Go to Today'));
    await tester.pump();

    expect(find.text('Could not save completion. Try again.'), findsOneWidget);
    expect(find.text('Go to Today'), findsOneWidget);
  });

  testWidgets('remains usable at large text on a phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(home: OnboardingScreen(onComplete: () async {})),
    );

    expect(find.text('Next'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
