import 'package:flutter/services.dart' show rootBundle;

/// One release in the changelog, with its grouped entries.
final class ChangelogRelease {
  /// Creates a release entry.
  const ChangelogRelease({
    required this.version,
    required this.sections,
    this.date,
  });

  /// Semantic version, or `Unreleased` for work not yet published.
  final String version;

  /// Release date, absent while the section is still unreleased.
  final DateTime? date;

  /// Grouped changes, in the order the document lists them.
  final List<ChangelogSection> sections;

  /// Whether this section describes work that has not shipped yet.
  bool get isUnreleased => date == null;
}

/// A Keep a Changelog group such as Added, Changed or Fixed.
final class ChangelogSection {
  /// Creates a group.
  const ChangelogSection({required this.title, required this.entries});

  /// Group heading exactly as written.
  final String title;

  /// One string per bullet, with wrapped lines joined back together.
  final List<String> entries;
}

/// Reads `CHANGELOG.md` — the same file the repository keeps — for the app.
///
/// The document is the single source. Nothing is generated into a second
/// format for the app to read, because two copies of a changelog become two
/// different changelogs: the file is shipped as an asset and parsed here.
final class ChangelogParser {
  /// Path of the bundled document, identical to the repository's copy.
  static const String assetPath = 'CHANGELOG.md';

  static final RegExp _release = RegExp(
    r'^##\s+\[([^\]]+)\]\s*(?:-\s*(\d{4}-\d{2}-\d{2}))?\s*$',
  );
  static final RegExp _section = RegExp(r'^###\s+(.+?)\s*$');
  static final RegExp _bullet = RegExp(r'^-\s+(.*)$');

  /// Loads and parses the bundled changelog.
  static Future<List<ChangelogRelease>> load() async =>
      parse(await rootBundle.loadString(assetPath));

  /// Parses Keep a Changelog [markdown] into releases, newest first.
  ///
  /// Only the structure the project actually uses is recognised: a release
  /// heading, group headings beneath it, and bullets whose wrapped lines are
  /// indented. Anything before the first release heading is preamble and is
  /// skipped, so the file keeps its human introduction.
  static List<ChangelogRelease> parse(String markdown) {
    final List<ChangelogRelease> releases = <ChangelogRelease>[];
    final List<ChangelogSection> sections = <ChangelogSection>[];
    final List<String> entries = <String>[];
    final StringBuffer current = StringBuffer();

    String? version;
    DateTime? date;
    String? sectionTitle;

    void flushEntry() {
      final String text = current.toString().trim();
      current.clear();
      if (text.isNotEmpty) entries.add(text);
    }

    void flushSection() {
      flushEntry();
      if (sectionTitle != null && entries.isNotEmpty) {
        sections.add(
          ChangelogSection(
            title: sectionTitle!,
            entries: List<String>.unmodifiable(entries),
          ),
        );
      }
      entries.clear();
      sectionTitle = null;
    }

    void flushRelease() {
      flushSection();
      if (version != null && sections.isNotEmpty) {
        releases.add(
          ChangelogRelease(
            version: version!,
            date: date,
            sections: List<ChangelogSection>.unmodifiable(sections),
          ),
        );
      }
      sections.clear();
      version = null;
      date = null;
    }

    for (final String line in markdown.split('\n')) {
      final RegExpMatch? release = _release.firstMatch(line);
      if (release != null) {
        flushRelease();
        version = release.group(1);
        final String? day = release.group(2);
        date = day == null ? null : DateTime.tryParse(day);
        continue;
      }
      if (version == null) continue;

      final RegExpMatch? section = _section.firstMatch(line);
      if (section != null) {
        flushSection();
        sectionTitle = section.group(1);
        continue;
      }
      if (sectionTitle == null) continue;

      final RegExpMatch? bullet = _bullet.firstMatch(line);
      if (bullet != null) {
        flushEntry();
        current.write(bullet.group(1));
        continue;
      }
      if (line.trim().isEmpty) {
        flushEntry();
        continue;
      }
      // A wrapped continuation of the bullet above.
      if (current.isNotEmpty) current.write(' ');
      current.write(line.trim());
    }
    flushRelease();
    return List<ChangelogRelease>.unmodifiable(releases);
  }
}
