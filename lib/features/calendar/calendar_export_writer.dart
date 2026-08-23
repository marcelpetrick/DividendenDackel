import 'dart:convert';

import 'package:dividendendackel/domain/use_cases/calendar_export.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Saves an iCalendar snapshot to a user-selected local destination.
abstract interface class CalendarExportWriter {
  /// Returns `true` after saving and `false` when the dialog was cancelled.
  Future<bool> save(CalendarExportDocument document);
}

/// Native Android/Linux implementation backed by the platform save dialog.
final class LocalCalendarExportWriter implements CalendarExportWriter {
  /// Creates the Android/Linux calendar writer.
  LocalCalendarExportWriter({
    this.platform,
    this.androidChannel = const MethodChannel(
      'it.marcelpetrick.dividendendackel/calendar_export',
    ),
  });

  /// Platform override used by tests; production follows Flutter's target.
  final TargetPlatform? platform;

  /// Android native document-creation channel.
  final MethodChannel androidChannel;

  @override
  Future<bool> save(CalendarExportDocument document) =>
      (platform ?? defaultTargetPlatform) == TargetPlatform.android
      ? _saveAndroid(document)
      : _saveDesktop(document);

  Future<bool> _saveAndroid(CalendarExportDocument document) async {
    final bool? saved = await androidChannel.invokeMethod<bool>(
      'createDocument',
      <String, Object>{
        'name': document.fileName,
        'mimeType': 'text/calendar',
        'bytes': Uint8List.fromList(utf8.encode(document.contents)),
      },
    );
    return saved ?? false;
  }

  Future<bool> _saveDesktop(CalendarExportDocument document) async {
    const XTypeGroup calendarFiles = XTypeGroup(
      label: 'iCalendar file',
      extensions: <String>['ics'],
      mimeTypes: <String>['text/calendar'],
      uniformTypeIdentifiers: <String>['public.calendar-event'],
    );
    final FileSaveLocation? destination = await getSaveLocation(
      acceptedTypeGroups: const <XTypeGroup>[calendarFiles],
      suggestedName: document.fileName,
      confirmButtonText: 'Export',
    );
    if (destination == null) return false;

    final XFile file = XFile.fromData(
      Uint8List.fromList(utf8.encode(document.contents)),
      mimeType: 'text/calendar',
      name: document.fileName,
    );
    await file.saveTo(destination.path);
    return true;
  }
}

/// Overridable file boundary used by the calendar screen.
final Provider<CalendarExportWriter> calendarExportWriterProvider =
    Provider<CalendarExportWriter>((Ref ref) => LocalCalendarExportWriter());
