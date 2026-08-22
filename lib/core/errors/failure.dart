/// Typed, actionable error model (Vision.md §55).
///
/// Every failure that can surface from a provider, the cache or the database is
/// represented by one of the [Failure] subtypes below. Each carries a
/// user-facing [Failure.message] that is safe to render in the UI, plus
/// optional diagnostics that are only meant for the Data Status screen and the
/// developer logs — raw stack traces are never shown to normal users.
library;

/// Coarse classification of a [Failure].
///
/// Used for logging, provider health reporting and for deciding whether a
/// request may be retried.
enum FailureCategory {
  /// No usable network connection.
  network,

  /// The request exceeded its deadline.
  timeout,

  /// A provider quota or rate limit was reached.
  rateLimited,

  /// The provider rejected the credentials.
  authentication,

  /// The provider answered with an error or is otherwise unreachable.
  providerUnavailable,

  /// A response could not be normalized into a domain model.
  parsing,

  /// The requested instrument is unknown or ambiguous.
  invalidInstrument,

  /// The request succeeded but the provider has no data for it.
  noData,

  /// Only outdated cached data is available.
  stale,

  /// An error that does not fit any known category.
  unexpected,
}

/// Base type of every recoverable error in the application.
///
/// Implements [Exception] so a failure may be thrown across a boundary that
/// cannot return a `Result` (a parser, a stream transformer) and be caught
/// again by `Result.guard` without losing its type.
sealed class Failure implements Exception {
  const Failure(this.message, {this.technicalDetail, this.cause});

  /// Short, user-facing explanation. Must not contain technical jargon,
  /// identifiers or stack traces.
  final String message;

  /// Optional diagnostic text for the Data Status screen and logs.
  final String? technicalDetail;

  /// The originating error, if any. Never rendered to normal users.
  final Object? cause;

  /// Classification used by logging and provider-health reporting.
  FailureCategory get category;

  /// Whether repeating the same request could plausibly succeed later.
  bool get isRetryable;

  @override
  String toString() {
    final detail = technicalDetail;
    return detail == null
        ? '${category.name}: $message'
        : '${category.name}: $message ($detail)';
  }

  @override
  bool operator ==(Object other) =>
      other is Failure &&
      other.runtimeType == runtimeType &&
      other.message == message &&
      other.technicalDetail == technicalDetail &&
      other.cause == cause;

  @override
  int get hashCode => Object.hash(runtimeType, message, technicalDetail, cause);
}

/// No usable network connection (Vision.md §44).
final class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection.',
    super.technicalDetail,
    super.cause,
  }) : super(message);

  @override
  FailureCategory get category => FailureCategory.network;

  @override
  bool get isRetryable => true;
}

/// A request did not complete within its deadline (Vision.md §30).
final class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'The data source took too long to answer.',
    this.timeout,
    super.technicalDetail,
    super.cause,
  }) : super(message);

  /// The deadline that elapsed, when known.
  final Duration? timeout;

  @override
  FailureCategory get category => FailureCategory.timeout;

  @override
  bool get isRetryable => true;
}

/// A provider quota was exhausted (Vision.md §79).
final class RateLimitFailure extends Failure {
  const RateLimitFailure({
    String message = 'Data source limit reached. Next refresh available later.',
    this.retryAt,
    super.technicalDetail,
    super.cause,
  }) : super(message);

  /// Wall-clock time at which the provider accepts requests again, when the
  /// provider reports it. Rendered by the Data Status screen (Vision.md §41).
  final DateTime? retryAt;

  @override
  FailureCategory get category => FailureCategory.rateLimited;

  @override
  bool get isRetryable => true;

  @override
  bool operator ==(Object other) =>
      other is RateLimitFailure && super == other && other.retryAt == retryAt;

  @override
  int get hashCode => Object.hash(super.hashCode, retryAt);
}

/// The provider rejected or is missing the credentials (Vision.md §34).
final class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    String message = 'This data source needs a valid API key.',
    super.technicalDetail,
    super.cause,
  }) : super(message);

  @override
  FailureCategory get category => FailureCategory.authentication;

  /// Retrying with the same credentials cannot succeed.
  @override
  bool get isRetryable => false;
}

/// The provider is unreachable or answered with a server error (Vision.md §79).
final class ProviderUnavailableFailure extends Failure {
  const ProviderUnavailableFailure({
    String message = 'Provider temporarily unavailable.',
    this.statusCode,
    super.technicalDetail,
    super.cause,
  }) : super(message);

  /// HTTP status code, when the failure came from an HTTP response.
  final int? statusCode;

  @override
  FailureCategory get category => FailureCategory.providerUnavailable;

  @override
  bool get isRetryable => true;

  @override
  bool operator ==(Object other) =>
      other is ProviderUnavailableFailure &&
      super == other &&
      other.statusCode == statusCode;

  @override
  int get hashCode => Object.hash(super.hashCode, statusCode);
}

/// A response could not be normalized into a domain model (Vision.md §77).
final class ParsingFailure extends Failure {
  const ParsingFailure({
    String message = 'The data source returned an unexpected format.',
    super.technicalDetail,
    super.cause,
  }) : super(message);

  @override
  FailureCategory get category => FailureCategory.parsing;

  /// The same malformed response would fail again.
  @override
  bool get isRetryable => false;
}

/// The requested instrument is unknown or ambiguous (Vision.md §36).
final class InvalidInstrumentFailure extends Failure {
  const InvalidInstrumentFailure({
    String message = 'This instrument could not be identified.',
    this.symbol,
    super.technicalDetail,
    super.cause,
  }) : super(message);

  /// The symbol that could not be resolved, for diagnostics.
  final String? symbol;

  @override
  FailureCategory get category => FailureCategory.invalidInstrument;

  @override
  bool get isRetryable => false;

  @override
  bool operator ==(Object other) =>
      other is InvalidInstrumentFailure &&
      super == other &&
      other.symbol == symbol;

  @override
  int get hashCode => Object.hash(super.hashCode, symbol);
}

/// The request succeeded but the provider has nothing to return.
///
/// This is an ordinary outcome, not a defect: the UI shows an empty state
/// rather than an error (Vision.md §79 — never fabricate missing values).
final class NoDataFailure extends Failure {
  const NoDataFailure({
    String message = 'No data available for this request.',
    super.technicalDetail,
    super.cause,
  }) : super(message);

  @override
  FailureCategory get category => FailureCategory.noData;

  @override
  bool get isRetryable => false;
}

/// Only outdated cached data could be provided (Vision.md §38).
///
/// The cached payload stays usable; this failure exists so the UI can label it
/// as stale while a background refresh runs.
final class StaleDataFailure extends Failure {
  const StaleDataFailure({
    String message = 'Showing saved data — refreshing…',
    this.lastUpdatedAt,
    super.technicalDetail,
    super.cause,
  }) : super(message);

  /// When the cached data was last written, when known.
  final DateTime? lastUpdatedAt;

  @override
  FailureCategory get category => FailureCategory.stale;

  @override
  bool get isRetryable => true;

  @override
  bool operator ==(Object other) =>
      other is StaleDataFailure &&
      super == other &&
      other.lastUpdatedAt == lastUpdatedAt;

  @override
  int get hashCode => Object.hash(super.hashCode, lastUpdatedAt);
}

/// An error that could not be classified.
///
/// Exists so that no error escapes the typed model; anything landing here is
/// worth investigating in the logs.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    String message = 'Something went wrong.',
    super.technicalDetail,
    super.cause,
  }) : super(message);

  @override
  FailureCategory get category => FailureCategory.unexpected;

  @override
  bool get isRetryable => false;
}
