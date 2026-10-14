import '../models/game_night.dart';

/// Twelve nights with dates relative to today, so the app never goes stale.
/// A function, not a const: DateTime.now() is not a constant, and Reset data
/// needs a fresh copy.
List<GameNight> seedNights() {
  final now = DateTime.now();
  // Whole minutes only, so an untouched edit form is not "dirty" (R30).
  DateTime day(int offset, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + offset, hour, minute);

  return [
    // Mandatory: a 60-character title.
    GameNight(
      id: 'twilight',
      title: 'Twilight Imperium Marathon: Full Galaxy Conquest Until Dawn!',
      genre: GameGenre.strategy,
      startsAt: day(2, 18),
      venue: 'Student Center, Room 204',
      seats: 6,
      players: const ['Aida', 'Dias', 'Madina'],
      notes: 'Bring snacks — a full game takes about eight hours.',
      favourite: true,
    ),
    // Mandatory: an item at its limit.
    GameNight(
      id: 'codenames',
      title: 'Codenames Party',
      genre: GameGenre.party,
      startsAt: day(1, 19),
      venue: 'Main Hall Lobby',
      seats: 4,
      players: const ['Arman', 'Zhanel', 'Kamila', 'Yerlan'],
    ),
    // Mandatory: a past item.
    GameNight(
      id: 'pandemic',
      title: 'Pandemic Legacy: Season 1',
      genre: GameGenre.cooperative,
      startsAt: day(-3, 18),
      venue: 'Library, Group Room 3',
      seats: 4,
      players: const ['Aida', 'Timur'],
      notes: 'Chapter March — we saved Istanbul.',
    ),
    // Mandatory: an item with the mode on (online, the venue is a link).
    GameNight(
      id: 'dominion',
      title: 'Online Dominion League',
      genre: GameGenre.deckbuilding,
      startsAt: day(3, 20),
      venue: 'https://dominion.games/club',
      seats: 8,
      players: const ['Sanzhar', 'Dana'],
      online: true,
    ),
    // Mandatory: an item without the optional text (notes is null).
    GameNight(
      id: 'dnd',
      title: 'Dungeons & Dragons One-Shot',
      genre: GameGenre.roleplaying,
      startsAt: day(5, 17, 30),
      venue: 'Dorm 2, Common Room',
      seats: 5,
      players: const ['Inkar'],
    ),
    GameNight(
      id: 'memoir',
      title: 'Memoir \'44: Beach Landing',
      genre: GameGenre.wargame,
      startsAt: day(7, 16),
      venue: 'Student Center, Room 110',
      seats: 2,
      players: const ['Bekzat'],
      notes: 'One-on-one, the loser sets up the next scenario.',
    ),
    GameNight(
      id: 'catan',
      title: 'Catan for Beginners',
      genre: GameGenre.strategy,
      startsAt: day(4, 18, 30),
      venue: 'Main Building, Room 301',
      seats: 12,
      players: const ['Ayan', 'Tomiris', 'Daniyar'],
      notes: 'Rules explained in the first 20 minutes.',
    ),
    GameNight(
      id: 'wavelength',
      title: 'Wavelength & Snacks',
      genre: GameGenre.party,
      startsAt: day(6, 19),
      venue: 'Cafeteria, Back Corner',
      seats: 16,
      favourite: true,
    ),
    GameNight(
      id: 'spirit',
      title: 'Spirit Island Co-op',
      genre: GameGenre.cooperative,
      startsAt: day(8, 18),
      venue: 'Library, Group Room 1',
      seats: 4,
      players: const ['Madina', 'Alikhan'],
    ),
    GameNight(
      id: 'star-realms',
      title: 'Star Realms Tournament',
      genre: GameGenre.deckbuilding,
      startsAt: day(10, 15),
      venue: 'Student Center, Room 204',
      seats: 32,
      players: const ['Dias', 'Nurlan', 'Amina', 'Aruzhan'],
      notes: 'Swiss rounds, best of three.',
    ),
    GameNight(
      id: 'blades',
      title: 'Blades in the Dark Campaign',
      genre: GameGenre.roleplaying,
      startsAt: day(12, 20),
      venue: 'https://discord.gg/campus-games',
      seats: 5,
      players: const ['Timur', 'Dana', 'Kamila'],
      online: true,
    ),
    GameNight(
      id: 'twilight-struggle',
      title: 'Twilight Struggle Duel',
      genre: GameGenre.wargame,
      startsAt: day(-1, 19),
      venue: 'Student Center, Room 110',
      seats: 2,
      players: const ['Arman', 'Bekzat'],
    ),
  ];
}
