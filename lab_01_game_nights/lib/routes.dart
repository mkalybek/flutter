import 'package:flutter/material.dart';

import 'models/game_night.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

/// R25: the only place route strings are written. A typo in a constant is a
/// compile error; a typo in a string is a crash when the user taps.
abstract final class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

/// R26: what the detail screen needs — the night, who "you" are, and the
/// callbacks that send changes back up to the shell, which owns the list.
class DetailArgs {
  const DetailArgs({
    required this.night,
    required this.you,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final GameNight night;
  final String you;
  final ValueChanged<GameNight> onChanged;
  final ValueChanged<GameNight> onDelete;

  /// Asks the shell to switch to the profile tab (R15, R28).
  final VoidCallback onOpenProfile;
}

/// R26: the form takes a GameNight? (null = new) and answers through pop.
class FormArgs {
  const FormArgs({this.night});

  final GameNight? night;
}

/// Screens that take an argument are built here, from typed argument
/// classes. Anything else returns null and falls through to onUnknownRoute.
Route<Object?>? onGenerateRoute(RouteSettings settings) => switch (settings) {
  RouteSettings(name: Routes.detail, arguments: final DetailArgs args) =>
    MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    ),
  // The route's type must match pushNamed<GameNight> at the call site.
  RouteSettings(name: Routes.form, arguments: final FormArgs args) =>
    MaterialPageRoute<GameNight>(
      settings: settings,
      builder: (_) => FormScreen(night: args.night),
    ),
  _ => null,
};

Route<void> onUnknownRoute(RouteSettings settings) => MaterialPageRoute<void>(
  settings: settings,
  builder: (_) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: Center(child: Text('Not found: ${settings.name}')),
  ),
);
