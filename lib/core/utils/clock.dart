/// Injectable time source.
///
/// Everything that timestamps or ages data — logging, cache expiry, the request
/// coordinator, dividend forecasts — reads the current time through a [Clock]
/// rather than calling [DateTime.now] directly, so those behaviours can be
/// tested deterministically.
abstract interface class Clock {
  /// The current wall-clock time.
  DateTime now();
}

/// The real system clock, used everywhere outside tests.
final class SystemClock implements Clock {
  /// Creates a clock backed by [DateTime.now].
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
