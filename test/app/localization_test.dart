import 'dart:io';

import 'package:dividendendackel/app/localization/language_preference.dart';
import 'package:dividendendackel/app/localization/localized_material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('language preference', () {
    test(
      'uses a supported platform locale and persists an explicit choice',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final SharedPreferencesLanguagePreferenceStore store =
            SharedPreferencesLanguagePreferenceStore(
              platformLocale: () => const Locale('hr', 'HR'),
            );

        expect(await store.load(), AppLanguage.croatian);
        await store.save(AppLanguage.german);

        expect(await store.load(), AppLanguage.german);
      },
    );

    test('falls back to English for an unsupported platform locale', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferencesLanguagePreferenceStore store =
          SharedPreferencesLanguagePreferenceStore(
            platformLocale: () => const Locale('fr'),
          );

      expect(await store.load(), AppLanguage.english);
    });
  });

  group('translation catalog', () {
    const AppLocalizations german = AppLocalizations(Locale('de'));
    const AppLocalizations croatian = AppLocalizations(Locale('hr'));

    test('translates navigation, disclosures and dynamic values', () {
      expect(german.text('Today'), 'Heute');
      expect(croatian.text('Settings'), 'Postavke');
      expect(german.text('Match this device'), 'An dieses Gerät anpassen');
      expect(
        croatian.text('Your portfolio stays on this device'),
        'Vaš portfelj ostaje na ovom uređaju',
      );
      expect(
        german.text('Could not open the original source.'),
        'Die Originalquelle konnte nicht geöffnet werden.',
      );
      expect(german.text('Version 0.51.0'), 'Version 0.51.0');
      expect(croatian.text('3 payments'), '3 isplate');
      expect(german.text('September 2026'), 'September 2026');
      expect(croatian.text('September 2026'), 'rujan 2026');
      expect(
        german.text(
          'The app works without an API key. Optional keys are stored only on this device.',
        ),
        contains('ohne API-Schlüssel'),
      );
      expect(
        croatian.text(
          'Security-only total return. Purchases and opening balances are capital in; sales and actual dividends are capital out; taxes and fees are costs. Cash deposits and withdrawals are shown but excluded because this app does not value a cash balance.',
        ),
        contains('Ukupni prinos'),
      );
    });

    test('substitutes a phrase once, never its own output', () {
      // 'dividend' -> 'Dividende' used to be re-matched by 'Dividend', so
      // 'ex-dividend' came out of the catalog as 'ex-Dividendee'.
      expect(german.text('0 ex-dividend date(s)'), '0 ex-Dividende date(s)');
      expect(german.text('0 ex-Dividend date(s)'), '0 ex-Dividende date(s)');
      expect(croatian.text('0 ex-dividend date(s)'), '0 ex-dividenda date(s)');
    });

    test('substitutes whole words, not fragments inside them', () {
      // 'net' -> 'netto' used to fire inside any word containing it.
      expect(german.text('internet'), 'internet');
      expect(german.text('network value'), 'network Wert');
      expect(croatian.text('internet'), 'internet');
      // The same phrase still applies where it really is a word.
      expect(german.text('net'), 'netto');
    });

    test('falls back to the English source for an uncarried language', () {
      // The default arm used to return German, so an unsupported locale
      // rendered a German app instead of the canonical source copy.
      const AppLocalizations french = AppLocalizations(Locale('fr'));
      expect(french.text('Today'), 'Today');
      expect(french.text('3 payments'), '3 payments');
    });

    test('keys parameterised messages by pattern, not by result', () {
      // The assembled string can never match a catalog entry, which is why
      // interpolating before translating produced half-English output.
      expect(
        german.format('{count} more activities', <String, Object?>{'count': 7}),
        '7 weitere Aktivitäten',
      );
      expect(
        croatian.format('{count} more activities', <String, Object?>{
          'count': 7,
        }),
        '7 dodatnih aktivnosti',
      );
    });

    test('never translates the substituted values', () {
      // Values are amounts, codes and user content, not application copy.
      expect(
        german.format('Line {line}', <String, Object?>{'line': 'net'}),
        'Zeile net',
      );
    });

    test('leaves an unknown placeholder visible rather than dropping it', () {
      expect(
        german.format('Line {line}', const <String, Object?>{'other': 1}),
        'Zeile {line}',
      );
    });

    test('returns the pattern untouched for English', () {
      const AppLocalizations english = AppLocalizations(Locale('en'));
      expect(
        english.format('{count} more activities', <String, Object?>{
          'count': 2,
        }),
        '2 more activities',
      );
    });

    testWidgets('Text.format resolves in the live locale', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Text.format('Line {line}', <String, Object?>{'line': 42}),
        ),
      );

      expect(find.text('Zeile 42'), findsOneWidget);
    });

    testWidgets('localizes app copy but preserves user content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('hr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Column(
            children: <Widget>[
              Text('Portfolio'),
              Text('Today', translate: false),
            ],
          ),
        ),
      );

      expect(find.text('Portfelj'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
    });

    test('no user-facing string interpolates before it is translated', () {
      // An assembled string can never match a catalog key, so it used to fall
      // through to the phrase table and come back part English. Runtime values
      // belong in a pattern's placeholders instead.
      final RegExp literal = RegExp(r"'((?:[^'\\\n]|\\.)*)'");
      final RegExp boundary = RegExp(
        r'(?:(?<![A-Za-z_])Text\(|Text\.rich\(|\.tr\(|trFormat\(|'
        r'semanticsLabel:|tooltip:|helperText:|hintText:|errorText:|'
        r'labelText:|label:|message:|title:|content:|SnackBar\()\s*$',
      );
      final RegExp keyLike = RegExp(r'^[a-z0-9]+[-:.]|ValueKey|Key\(');
      final List<String> offenders = <String>[];

      for (final String root in <String>['lib/app', 'lib/features']) {
        for (final FileSystemEntity entity in Directory(
          root,
        ).listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          if (entity.path.contains('/localization/')) continue;
          final String source = entity.readAsStringSync();
          for (final RegExpMatch match in literal.allMatches(source)) {
            final String value = match.group(1)!;
            if (!value.contains(r'$')) continue;
            final String withoutValues = value
                .replaceAll(RegExp(r'\$\{[^}]*\}'), '')
                .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), '');
            if (!RegExp('[A-Za-z]{3,}').hasMatch(withoutValues)) continue;
            if (keyLike.hasMatch(value)) continue;
            final int from = match.start < 200 ? 0 : match.start - 200;
            final String before = source.substring(from, match.start);
            if (!boundary.hasMatch(before)) continue;
            if (before.trimRight().endsWith('Text.format(')) continue;
            final int to = match.end + 160 > source.length
                ? source.length
                : match.end + 160;
            if (source.substring(match.end, to).contains('translate: false')) {
              continue;
            }
            offenders.add('${entity.path}: $value');
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'Use Text.format/trFormat with a {placeholder} pattern, or mark '
            'pure data with translate: false.',
      );
    });

    test('every language of a message carries the same placeholders', () {
      // A dropped placeholder silently deletes the value it stood for; an
      // invented one renders as literal braces in the running app.
      final String source = File('lib/app/localization/app_localizations.dart')
          .readAsStringSync();
      final RegExp placeholder = RegExp(r'\{[a-zA-Z][a-zA-Z0-9]*\}');
      final RegExp entry = RegExp(
        r"  '((?:[^'\\]|\\.)*)': _Translation\(\s*"
        r"'((?:[^'\\]|\\.)*)',\s*'((?:[^'\\]|\\.)*)',",
      );
      final List<String> mismatched = <String>[];
      for (final RegExpMatch match in entry.allMatches(source)) {
        Set<String> names(String value) => placeholder
            .allMatches(value)
            .map((RegExpMatch item) => item.group(0)!)
            .toSet();
        final Set<String> english = names(match.group(1)!);
        if (english.isEmpty) continue;
        if (names(match.group(2)!).difference(english).isNotEmpty ||
            english.difference(names(match.group(2)!)).isNotEmpty ||
            names(match.group(3)!).difference(english).isNotEmpty ||
            english.difference(names(match.group(3)!)).isNotEmpty) {
          mismatched.add(match.group(1)!);
        }
      }
      expect(mismatched, isEmpty);
    });

    test('every user-facing string has a catalog entry', () {
      // A string with no entry renders English in a translated app, or -- via
      // the phrase fallback -- part English, which is worse.
      final String catalog = File('lib/app/localization/app_localizations.dart')
          .readAsStringSync();
      final Set<String> keys = RegExp(
        r"'((?:[^'\\]|\\.)*)'\s*:\s*_Translation\(",
        dotAll: true,
      ).allMatches(catalog).map((RegExpMatch m) => m.group(1)!).toSet();

      final RegExp joined = RegExp(r"((?:'(?:[^'\\\n]|\\.)*'\s*)+)");
      final RegExp piece = RegExp(r"'((?:[^'\\\n]|\\.)*)'");
      final RegExp boundary = RegExp(
        r'(?:(?<![A-Za-z_])Text\(|Text\.format\(|\.tr\(|trFormat\(|'
        r'semanticsLabel:|tooltip:|helperText:|hintText:|errorText:|'
        r'labelText:|label:|title:|content:)\s*$',
      );
      final RegExp keyLike = RegExp(r'^[a-z0-9]+[-:.]|^/|^[A-Z]{2,4}$');
      final List<String> untranslated = <String>[];

      for (final String root in <String>['lib/app', 'lib/features']) {
        for (final FileSystemEntity entity in Directory(
          root,
        ).listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          if (entity.path.contains('/localization/')) continue;
          final String source = entity.readAsStringSync();
          for (final RegExpMatch match in joined.allMatches(source)) {
            final String value = piece
                .allMatches(match.group(1)!)
                .map((RegExpMatch m) => m.group(1)!)
                .join();
            if (value.isEmpty || value.contains(r'$')) continue;
            if (!RegExp('[A-Za-z]{3,}').hasMatch(value)) continue;
            if (keyLike.hasMatch(value)) continue;
            final int from = match.start < 200 ? 0 : match.start - 200;
            if (!boundary.hasMatch(source.substring(from, match.start))) {
              continue;
            }
            final int to = match.end + 160 > source.length
                ? source.length
                : match.end + 160;
            if (source.substring(match.end, to).contains('translate: false')) {
              continue;
            }
            if (keys.contains(value)) continue;
            untranslated.add('${entity.path}: $value');
          }
        }
      }

      expect(
        untranslated,
        isEmpty,
        reason: 'Add a German and Croatian entry, or mark it translate: false.',
      );
    });

    test('all feature Text widgets use the localization boundary', () {
      final List<File> files = <File>[
        for (final String root in <String>['lib/app', 'lib/features'])
          for (final FileSystemEntity entity in Directory(
            root,
          ).listSync(recursive: true))
            if (entity is File && entity.path.endsWith('.dart')) entity,
      ];
      final List<String> bypasses = <String>[];
      final RegExp rawProperty = RegExp(
        r'''(?:tooltip|semanticsLabel|helperText|hintText|errorText|labelText):\s*['"](?!EUR['"])''',
      );
      for (final File file in files) {
        if (file.path.contains('/localization/')) continue;
        final String source = file.readAsStringSync();
        if (source.contains("import 'package:flutter/material.dart';") ||
            rawProperty.hasMatch(source)) {
          bypasses.add(file.path);
        }
      }

      expect(
        bypasses,
        isEmpty,
        reason: 'User-facing text must use localized_material or context.tr().',
      );
    });
  });
}
