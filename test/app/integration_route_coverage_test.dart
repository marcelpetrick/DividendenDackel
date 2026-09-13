import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every application route has a compiled integration journey', () {
    final String router = File('lib/app/navigation/app_router.dart')
        .readAsStringSync();
    final Set<String> applicationRoutes = RegExp(r"path: '([^']+)'")
        .allMatches(router)
        .map((RegExpMatch match) => match.group(1)!)
        .toSet();

    final Set<String> journeyRoutes = Directory('integration_test')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .expand(
          (File file) =>
              RegExp(r'Covers route: (\S+)')
                  .allMatches(file.readAsStringSync()),
        )
        .map((RegExpMatch match) => match.group(1)!)
        .toSet();

    expect(applicationRoutes, isNotEmpty);
    expect(
      journeyRoutes,
      applicationRoutes,
      reason:
          'Each route in app_router.dart must have a matching '
          '`Covers route:` marker beside the integration journey that '
          'renders and exercises it.',
    );
  });
}
