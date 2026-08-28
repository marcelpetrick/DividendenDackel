import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/logging/logging.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/domain/entities/entities.dart';

/// Builds the text a user can paste into a defect report.
///
/// A release build shows its diagnostics on screen but had no way to get them
/// off the device, so a report came down to describing symptoms from memory.
///
/// Every record here has already passed the redactor, which removes credentials
/// and portfolio content (Vision.md §34, §80). Nothing is added afterwards that
/// could reintroduce either, so the result is safe to paste anywhere.
String buildDiagnosticReport({
  required List<LogRecord> records,
  required List<ProviderStatus> statuses,
  required List<RequestStatus> operations,
  required DateTime now,
  int recordLimit = 100,
}) {
  final StringBuffer buffer = StringBuffer()
    ..writeln('DividendenDackel diagnostics')
    ..writeln('Generated: ${now.toUtc().toIso8601String()}')
    ..writeln()
    ..writeln('## Data sources');

  if (statuses.isEmpty) {
    buffer.writeln('(none recorded)');
  } else {
    for (final ProviderStatus status in statuses) {
      buffer
        ..write('- ')
        ..write(status.providerId)
        ..write(': ')
        ..write(status.health.name);
      if (status.lastErrorCategory case final FailureCategory category) {
        buffer
          ..write(' [')
          ..write(category.name)
          ..write(']');
      }
      if (status.lastErrorMessage case final String message
          when message.isNotEmpty) {
        buffer
          ..write(' — ')
          ..write(message);
      }
      if (status.rateLimitResetAt case final DateTime resetAt) {
        buffer
          ..write(' (resets ')
          ..write(resetAt.toUtc().toIso8601String())
          ..write(')');
      }
      buffer.writeln();
    }
  }

  buffer
    ..writeln()
    ..writeln('## Recent requests');
  if (operations.isEmpty) {
    buffer.writeln('(none active)');
  } else {
    for (final RequestStatus operation in operations) {
      buffer
        ..write('- ')
        ..write(operation.provider)
        ..write(' ')
        ..write(operation.operation)
        ..write(': ')
        ..write(operation.lifecycle.name)
        ..write(' attempt ')
        ..write(operation.attempt);
      if (operation.failureMessage case final String message
          when message.isNotEmpty) {
        buffer
          ..write(' — ')
          ..write(message);
      }
      buffer.writeln();
    }
  }

  buffer
    ..writeln()
    ..writeln('## Log (newest last)');
  final List<LogRecord> recent = records.length > recordLimit
      ? records.sublist(records.length - recordLimit)
      : records;
  if (recent.isEmpty) {
    buffer.writeln('(empty)');
  } else {
    for (final LogRecord record in recent) {
      buffer.writeln(record.format());
    }
  }
  return buffer.toString();
}
