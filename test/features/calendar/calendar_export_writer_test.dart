import 'dart:convert';

import 'package:dividendendackel/domain/use_cases/calendar_export.dart';
import 'package:dividendendackel/features/calendar/calendar_export_writer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('calendar-export-test');
  const CalendarExportDocument document = CalendarExportDocument(
    fileName: 'calendar.ics',
    contents: 'BEGIN:VCALENDAR\r\nEND:VCALENDAR\r\n',
    eventCount: 0,
  );

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('passes Android exports to the native document creator', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          received = call;
          return true;
        });
    final LocalCalendarExportWriter writer = LocalCalendarExportWriter(
      platform: TargetPlatform.android,
      androidChannel: channel,
    );

    expect(await writer.save(document), isTrue);
    expect(received?.method, 'createDocument');
    final Map<Object?, Object?> arguments =
        received?.arguments as Map<Object?, Object?>;
    expect(arguments['name'], document.fileName);
    expect(arguments['mimeType'], 'text/calendar');
    expect(utf8.decode(arguments['bytes']! as Uint8List), document.contents);
  });

  test('treats a cancelled Android document picker as no save', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async => false);
    final LocalCalendarExportWriter writer = LocalCalendarExportWriter(
      platform: TargetPlatform.android,
      androidChannel: channel,
    );

    expect(await writer.save(document), isFalse);
  });
}
