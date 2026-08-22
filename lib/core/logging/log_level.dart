/// Severity of a log record, ordered from most to least verbose.
enum LogLevel {
  /// Fine-grained tracing, e.g. individual cache lookups.
  trace('TRACE', 0),

  /// Development detail that is useful while debugging a feature.
  debug('DEBUG', 1),

  /// Notable but expected events, e.g. a completed provider request.
  info('INFO', 2),

  /// Something went wrong but the app recovered, e.g. a provider fallback.
  warning('WARN', 3),

  /// An operation failed in a way the user may notice.
  error('ERROR', 4);

  const LogLevel(this.label, this.severity);

  /// Fixed-width-ish label used when formatting a record.
  final String label;

  /// Numeric ordering; higher is more severe.
  final int severity;

  /// Whether a record at this level passes a [threshold].
  bool operator >=(LogLevel threshold) => severity >= threshold.severity;
}
