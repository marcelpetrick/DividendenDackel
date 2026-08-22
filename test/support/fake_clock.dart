import 'package:dividend_tracker/core/utils/clock.dart';

/// A [Clock] whose time only moves when a test moves it.
final class FakeClock implements Clock {
  /// Creates a clock starting at [initial].
  FakeClock([DateTime? initial])
    : _now = initial ?? DateTime.utc(2026, 1, 1, 12);

  DateTime _now;

  @override
  DateTime now() => _now;

  /// Moves the clock forward by [amount].
  void advance(Duration amount) => _now = _now.add(amount);

  /// Jumps the clock to [moment].
  void setTo(DateTime moment) => _now = moment;
}
