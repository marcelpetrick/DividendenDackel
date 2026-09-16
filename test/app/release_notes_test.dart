import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'release notes warn against destructive Android reinstall upgrades',
    () async {
      final ProcessResult result = await Process.run('bash', <String>[
        'tool/release-notes.sh',
        '0.65.9',
      ]);
      expect(result.exitCode, 0, reason: result.stderr.toString());
      final String notes = result.stdout.toString();
      expect(notes, contains('### Android upgrade warning'));
      expect(notes, contains('Debug signing keys are not persisted'));
      expect(notes, contains('Do not uninstall'));
      expect(
        notes,
        contains('uninstalling removes local portfolio data and credentials'),
      );
      expect(notes, contains('maintainer-provided keystore'));
      expect(notes, contains('SHA256SUMS'));
    },
  );
}
