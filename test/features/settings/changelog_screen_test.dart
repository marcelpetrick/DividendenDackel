import 'package:dividendendackel/app/localization/app_localizations.dart';
import 'package:dividendendackel/features/settings/changelog.dart';
import 'package:dividendendackel/features/settings/changelog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<ChangelogRelease> sample = <ChangelogRelease>[
    const ChangelogRelease(
      version: 'Unreleased',
      sections: <ChangelogSection>[
        ChangelogSection(title: 'Added', entries: <String>['A pending thing.']),
      ],
    ),
    ChangelogRelease(
      version: '0.2.0',
      date: DateTime.utc(2026, 8, 20),
      sections: <ChangelogSection>[
        ChangelogSection(
          title: 'Fixed',
          entries: <String>['A repaired thing.'],
        ),
      ],
    ),
  ];

  Widget harness({
    required List<ChangelogRelease> releases,
    Locale locale = const Locale('en'),
  }) => ProviderScope(
    overrides: [changelogProvider.overrideWith((Ref ref) async => releases)],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ChangelogScreen(),
    ),
  );

  testWidgets('shows every release with its grouped entries', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(releases: sample));
    await tester.pumpAndSettle();

    expect(find.text('0.2.0'), findsOneWidget);
    expect(find.text('2026-08-20'), findsOneWidget);
    expect(find.text('Added'), findsOneWidget);
    expect(find.text('Fixed'), findsOneWidget);
    expect(find.text('A pending thing.'), findsOneWidget);
    expect(find.text('A repaired thing.'), findsOneWidget);
  });

  testWidgets('unreleased work is labelled, not shown as a version', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(releases: sample));
    await tester.pumpAndSettle();

    // "Unreleased" is a document convention, not something to put in front of
    // a user beside real version numbers.
    expect(find.text('Unreleased'), findsNothing);
    expect(find.text('In development'), findsOneWidget);
    expect(
      find.text('Finished and merged, not yet in a published build.'),
      findsOneWidget,
    );
  });

  testWidgets('an empty changelog states so instead of showing a blank page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(harness(releases: const <ChangelogRelease>[]));
    await tester.pumpAndSettle();

    expect(find.text('No release notes are available.'), findsOneWidget);
  });

  testWidgets('the screen chrome is localized but the notes stay English', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      harness(releases: sample, locale: const Locale('de')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Was sich geändert hat'), findsWidgets);
    expect(find.text('In Entwicklung'), findsOneWidget);
    // Release notes are the repository's own record. Translating them per
    // build would either fabricate history or silently go stale.
    expect(find.text('A repaired thing.'), findsOneWidget);
    expect(find.text('0.2.0'), findsOneWidget);
  });
}
