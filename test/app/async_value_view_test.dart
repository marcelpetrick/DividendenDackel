import 'package:dividendendackel/app/widgets/async_value_view.dart';
import 'package:dividendendackel/core/errors/failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, AsyncValue<List<String>> value) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueView<List<String>>(
              value: value,
              isEmpty: (List<String> items) => items.isEmpty,
              emptyTitle: 'No items',
              emptyMessage: 'Add one first.',
              builder: (BuildContext context, List<String> items) => ListView(
                children: <Widget>[for (final String item in items) Text(item)],
              ),
            ),
          ),
        ),
      );

  testWidgets('shows an explicit loading state', (WidgetTester tester) async {
    await pump(tester, const AsyncLoading<List<String>>());

    expect(find.bySemanticsLabel('Loading saved data'), findsOneWidget);
  });

  testWidgets('shows an actionable empty state', (WidgetTester tester) async {
    await pump(tester, const AsyncData<List<String>>(<String>[]));

    expect(find.text('No items'), findsOneWidget);
    expect(find.text('Add one first.'), findsOneWidget);
  });

  testWidgets('uses typed user-safe failure copy', (WidgetTester tester) async {
    await pump(
      tester,
      AsyncError<List<String>>(
        const ProviderUnavailableFailure(),
        StackTrace.empty,
      ),
    );

    expect(find.text('Data unavailable'), findsOneWidget);
    expect(find.text('Provider temporarily unavailable.'), findsOneWidget);
  });

  testWidgets('keeps previous data visible when a refresh fails', (
    WidgetTester tester,
  ) async {
    // Riverpod exposes no public constructor for the combined value/error
    // state produced by a failed provider refresh.
    final AsyncError<List<String>> failed = AsyncError<List<String>>(
      const RateLimitFailure(),
      StackTrace.empty,
    );
    // ignore: invalid_use_of_internal_member
    final AsyncValue<List<String>> value = failed.copyWithPrevious(
      const AsyncData<List<String>>(<String>['Cached item']),
    );

    await pump(tester, value);

    expect(find.text('Cached item'), findsOneWidget);
    expect(
      find.text('Data source limit reached. Next refresh available later.'),
      findsOneWidget,
    );
  });

  testWidgets('keeps previous data visible while refreshing', (
    WidgetTester tester,
  ) async {
    // Riverpod exposes no public constructor for its loading-with-value state.
    const AsyncLoading<List<String>> loading = AsyncLoading<List<String>>();
    // ignore: invalid_use_of_internal_member
    final AsyncValue<List<String>> value = loading.copyWithPrevious(
      const AsyncData<List<String>>(<String>['Cached item']),
    );

    await pump(tester, value);

    expect(find.text('Cached item'), findsOneWidget);
    expect(find.text('Updating saved data…'), findsOneWidget);
  });
}
