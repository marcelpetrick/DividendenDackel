import 'dart:io';

import 'package:dividendendackel/features/settings/changelog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChangelogParser', () {
    test('reads releases, dates and grouped entries', () {
      final List<ChangelogRelease> releases = ChangelogParser.parse('''
# Changelog

Some preamble that is not a release.

## [Unreleased]

### Added

- A thing that spans
  two source lines.
- A second thing.

### Fixed

- Something repaired.

## [0.2.0] - 2026-08-20

### Changed

- An older change.
''');

      expect(releases, hasLength(2));
      final ChangelogRelease unreleased = releases.first;
      expect(unreleased.version, 'Unreleased');
      expect(unreleased.date, isNull);
      expect(unreleased.isUnreleased, isTrue);
      expect(unreleased.sections.map((ChangelogSection s) => s.title), <String>[
        'Added',
        'Fixed',
      ]);
      // A wrapped bullet is one entry, not two.
      expect(unreleased.sections.first.entries, <String>[
        'A thing that spans two source lines.',
        'A second thing.',
      ]);

      final ChangelogRelease older = releases.last;
      expect(older.version, '0.2.0');
      expect(older.date, DateTime.parse('2026-08-20'));
      expect(older.isUnreleased, isFalse);
      expect(older.sections.single.entries, <String>['An older change.']);
    });

    test('preamble before the first release is skipped', () {
      final List<ChangelogRelease> releases = ChangelogParser.parse('''
# Changelog

- A bullet in the introduction, belonging to no release.

## [1.0.0] - 2026-01-01

### Added

- The only entry.
''');

      expect(releases, hasLength(1));
      expect(releases.single.sections.single.entries, <String>[
        'The only entry.',
      ]);
    });

    test('a release with no entries is dropped rather than shown empty', () {
      final List<ChangelogRelease> releases = ChangelogParser.parse('''
## [9.9.9] - 2026-02-02

## [1.0.0] - 2026-01-01

### Added

- Real content.
''');

      expect(releases.map((ChangelogRelease r) => r.version), <String>[
        '1.0.0',
      ]);
    });

    test('empty or heading-free input yields no releases', () {
      expect(ChangelogParser.parse(''), isEmpty);
      expect(ChangelogParser.parse('Just prose, no headings.'), isEmpty);
    });

    test('the repository changelog itself parses', () {
      // The app reads this exact file, so a formatting change that the parser
      // cannot read must fail here rather than in front of a user.
      final List<ChangelogRelease> releases = ChangelogParser.parse(
        File(ChangelogParser.assetPath).readAsStringSync(),
      );

      expect(releases, isNotEmpty);
      for (final ChangelogRelease release in releases) {
        expect(release.version, isNotEmpty);
        expect(release.sections, isNotEmpty);
        for (final ChangelogSection section in release.sections) {
          expect(section.title, isNotEmpty);
          expect(section.entries, isNotEmpty);
          for (final String entry in section.entries) {
            expect(entry.trim(), entry);
            expect(entry, isNot(contains('\n')));
          }
        }
      }
    });

    test('the bundled asset is registered so the app can read it', () {
      final String pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- ${ChangelogParser.assetPath}'));
    });
  });
}
