# Practice 4 — A Screen That Reacts

`flutter run` · `flutter analyze` → No issues found!

- `TapCard` (`lib/tap_card.dart`): tap counts, long-press asks via `showDialog<bool>`
- `TwoWayCounter` (`lib/two_way_counter.dart`): `onPressed: null` at zero, 2-second Save with `mounted` check + SnackBar
- `StopwatchCard` (`lib/stopwatch_card.dart`): `Timer.periodic`, guarded Start, cancelled in `dispose()`

![screenshot](screenshot.png)
