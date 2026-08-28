import 'package:dividendendackel/app/localization/app_localizations.dart';
import 'package:dividendendackel/features/settings/data_source_guide.dart';
import 'package:dividendendackel/features/settings/data_source_guide_sheet.dart';
import 'package:dividendendackel/features/settings/data_source_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataSourceGuide', () {
    test('every source that needs a key explains how to get one', () {
      // A provider that demands a credential without saying where to find it
      // is a dead end. Adding one to the enum now fails here until it has
      // instructions.
      for (final MarketDataSource source in MarketDataSource.values) {
        if (!source.requiresApiKey) continue;
        expect(
          DataSourceGuide.forSource(source),
          isNotNull,
          reason: '${source.name} requires a key but has no guide',
        );
      }
    });

    test('keyless sources have no guide, because there is nothing to do', () {
      for (final MarketDataSource source in MarketDataSource.values) {
        if (source.requiresApiKey) continue;
        expect(DataSourceGuide.forSource(source), isNull);
      }
    });

    test('each guide names a page, steps and what the key is for', () {
      for (final MarketDataSource source in MarketDataSource.values) {
        final DataSourceGuide? guide = DataSourceGuide.forSource(source);
        if (guide == null) continue;
        expect(guide.summary, isNotEmpty);
        expect(guide.steps, isNotEmpty);
        expect(guide.signUpUrl, startsWith('https://'));
        // The last step must bring the user back, or they are left holding a
        // key with nowhere to put it.
        expect(guide.steps.last.toLowerCase(), contains('add key'));
        for (final String step in guide.steps) {
          expect(step.trim(), step);
          expect(step, endsWith('.'));
        }
      }
    });
  });

  testWidgets('the sheet shows numbered steps and the quota caveat', (
    WidgetTester tester,
  ) async {
    final DataSourceGuide guide = DataSourceGuide.forSource(
      MarketDataSource.alphaVantage,
    )!;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: DataSourceGuideSheet(guide: guide)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Setting up Alpha Vantage'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('${guide.steps.length}.'), findsOneWidget);
    expect(find.text(guide.steps.first), findsOneWidget);
    // The 25-per-day limit shapes what the user can expect, so it is stated
    // before they spend effort rather than discovered afterwards.
    expect(find.textContaining('25 price requests per day'), findsOneWidget);
    expect(find.text('Open the sign-up page'), findsOneWidget);
    expect(
      find.textContaining('secure credential store'),
      findsOneWidget,
      reason: 'where the key goes is said where it is asked for',
    );
  });

  testWidgets('the guide is shown in the live locale', (
    WidgetTester tester,
  ) async {
    final DataSourceGuide guide = DataSourceGuide.forSource(
      MarketDataSource.alphaVantage,
    )!;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(body: DataSourceGuideSheet(guide: guide)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alpha Vantage einrichten'), findsOneWidget);
    expect(find.textContaining('Kursabfragen pro Tag'), findsOneWidget);
    expect(find.text('Registrierungsseite öffnen'), findsOneWidget);
  });
}
