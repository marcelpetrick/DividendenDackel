import 'package:dividendendackel/core/errors/failure.dart';
import 'package:dividendendackel/core/logging/logging.dart';
import 'package:dividendendackel/core/networking/request_coordinator.dart';
import 'package:dividendendackel/domain/entities/entities.dart';
import 'package:dividendendackel/features/status/diagnostic_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 8, 28, 15);

  test('names the provider, its health and why it last failed', () {
    final String report = buildDiagnosticReport(
      records: const <LogRecord>[],
      statuses: <ProviderStatus>[
        ProviderStatus(
          providerId: 'alpha_vantage',
          health: ProviderHealth.degraded,
          lastErrorCategory: FailureCategory.authentication,
          lastErrorMessage: 'No credential is stored',
          rateLimitResetAt: DateTime.utc(2026, 8, 29),
        ),
      ],
      operations: const <RequestStatus>[],
      now: now,
    );

    expect(report, contains('alpha_vantage'));
    expect(report, contains('degraded'));
    expect(report, contains('authentication'));
    expect(report, contains('No credential is stored'));
    expect(report, contains('2026-08-29'));
    expect(report, contains('2026-08-28T15:00:00.000Z'));
  });

  test('says so when there is nothing rather than emitting a blank section', () {
    final String report = buildDiagnosticReport(
      records: const <LogRecord>[],
      statuses: const <ProviderStatus>[],
      operations: const <RequestStatus>[],
      now: now,
    );

    // A silent gap reads as a broken report; "(none recorded)" is information.
    expect(report, contains('(none recorded)'));
    expect(report, contains('(none active)'));
    expect(report, contains('(empty)'));
  });

  test('keeps the newest records when the log is longer than the limit', () {
    final List<LogRecord> records = <LogRecord>[
      for (int index = 0; index < 10; index++)
        LogRecord(
          timestamp: now,
          level: LogLevel.info,
          component: 'refresh',
          message: 'entry $index',
        ),
    ];

    final String report = buildDiagnosticReport(
      records: records,
      statuses: const <ProviderStatus>[],
      operations: const <RequestStatus>[],
      now: now,
      recordLimit: 3,
    );

    // What went wrong is at the end of the log, not the start.
    expect(report, contains('entry 9'));
    expect(report, contains('entry 7'));
    expect(report, isNot(contains('entry 6')));
  });

  test('a value the redactor removed cannot reappear in the report', () {
    // The report adds nothing after redaction has run, so what makes it safe
    // to paste into a public issue is that the records arrive already clean.
    final Map<String, Object?> redacted = LogRedactor().redact(
      <String, Object?>{
        'apiKey': 'top-secret-value',
        'quantity': 42,
        'provider': 'alpha_vantage',
      },
    );
    final String report = buildDiagnosticReport(
      records: <LogRecord>[
        LogRecord(
          timestamp: now,
          level: LogLevel.warning,
          component: 'provider',
          message: 'request failed',
          fields: redacted,
        ),
      ],
      statuses: const <ProviderStatus>[],
      operations: const <RequestStatus>[],
      now: now,
    );

    expect(report, isNot(contains('top-secret-value')));
    expect(report, isNot(contains('42')));
    expect(report, contains(LogRedactor.placeholder));
    expect(report, contains('alpha_vantage'));
  });
}
