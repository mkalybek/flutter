// R9: a sealed family — a switch over Countdown must handle all three,
// and adding a fourth makes the compiler list every place to fix.
sealed class Countdown {
  const Countdown();
}

/// The night has not started yet; [left] is the time until it does.
final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

/// The night is in progress; [ago] is the time since it started.
final class Started extends Countdown {
  const Started(this.ago);
  final Duration ago;
}

final class Ended extends Countdown {
  const Ended();
}
