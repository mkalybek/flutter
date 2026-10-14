import 'package:flutter/material.dart';

import 'routes.dart';
import 'shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // R11: above MaterialApp, because MaterialApp is what reads it.
  ThemeMode _themeMode = ThemeMode.system;

  // R22: the seed is the one colour in lib/ — every other colour is a role
  // derived from it. Change this word and the whole app recolours.
  static const _seed = Colors.teal;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Game Nights',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed)),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ),
    ),
    themeMode: _themeMode,
    // R25: routes: holds the shell; screens with arguments are generated.
    routes: {
      Routes.home: (_) =>
          Shell(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
    },
    onGenerateRoute: onGenerateRoute,
    onUnknownRoute: onUnknownRoute,
  );
}
