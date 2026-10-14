import 'dart:collection';

import 'package:flutter/material.dart';

import 'countdown.dart';

/// The category: an enhanced enum carrying its own label and icon.
enum GameGenre {
  strategy('Strategy', Icons.psychology),
  party('Party', Icons.celebration),
  cooperative('Co-op', Icons.handshake),
  deckbuilding('Deck-building', Icons.style),
  roleplaying('Role-playing', Icons.auto_stories),
  wargame('Wargame', Icons.military_tech);

  const GameGenre(this.label, this.icon);

  final String label;
  final IconData icon;

  // R2: exhaustive switch expression, no default — a new value will not
  // compile until it gets a colour here. Roles, never literal colours.
  Color color(ColorScheme scheme) => switch (this) {
    GameGenre.strategy => scheme.primaryContainer,
    GameGenre.party => scheme.tertiaryContainer,
    GameGenre.cooperative => scheme.secondaryContainer,
    GameGenre.deckbuilding => scheme.inversePrimary,
    GameGenre.roleplaying => scheme.errorContainer,
    GameGenre.wargame => scheme.surfaceContainerHighest,
  };
}

/// One game night at the club. Immutable: every change is a new object (R1).
class GameNight {
  const GameNight({
    required this.id,
    required this.title,
    required this.genre,
    required this.startsAt,
    required this.venue,
    required this.seats,
    List<String> players = const [],
    this.online = false,
    this.notes,
    this.favourite = false,
  }) : _players = players;

  // R3: defaults for the "new night" form. Not const: DateTime.now() isn't.
  GameNight.empty()
    : this(
        id: '',
        title: '',
        genre: GameGenre.strategy,
        startsAt: DateTime.now(),
        venue: '',
        seats: 8,
      );

  /// How long a night lasts — decides Started vs Ended.
  static const length = Duration(hours: 3);

  final String id;
  final String title;
  final GameGenre genre;
  final DateTime startsAt;

  /// A room, or a link when [online] is true (the mode field).
  final String venue;

  /// The limit the players list counts against.
  final int seats;
  final List<String> _players;
  final bool online;
  final String? notes;
  final bool favourite;

  // R1: callers get a read-only view; the only way to change the list is
  // copyWith(players: ...), which builds a new night.
  List<String> get players => UnmodifiableListView(_players);

  // R4: derived values are getters, never stored fields.
  int get count => _players.length;
  int get freePlaces => seats - count;
  bool get isFull => count >= seats;
  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => _players.contains(name);

  // R5: two numbers at once as a record; callers destructure it.
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  // R9: which phase the night is in at [now].
  Countdown countdownAt(DateTime now) => now.isBefore(startsAt)
      ? Upcoming(startsAt.difference(now))
      : now.isBefore(startsAt.add(length))
      ? Started(now.difference(startsAt))
      : const Ended();

  GameNight copyWith({
    String? title,
    GameGenre? genre,
    DateTime? startsAt,
    String? venue,
    int? seats,
    List<String>? players,
    bool? online,
    bool? favourite,
  }) => GameNight(
    id: id,
    title: title ?? this.title,
    genre: genre ?? this.genre,
    startsAt: startsAt ?? this.startsAt,
    venue: venue ?? this.venue,
    seats: seats ?? this.seats,
    players: players ?? _players,
    online: online ?? this.online,
    notes: notes, // the form builds a fresh GameNight when notes change
    favourite: favourite ?? this.favourite,
  );
}

/// R7: upcoming nights first by date, past nights last. Used on a copy:
/// `[...nights]..sort(compareByDate)` — state is never sorted in place.
int compareByDate(GameNight a, GameNight b) => a.isPast != b.isPast
    ? (a.isPast ? 1 : -1)
    : a.startsAt.compareTo(b.startsAt);
