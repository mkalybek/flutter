import 'package:flutter/material.dart';

import 'data/seed.dart';
import 'models/game_night.dart';
import 'models/profile.dart';
import 'routes.dart';
import 'tabs/favourites_tab.dart';
import 'tabs/list_tab.dart';
import 'tabs/profile_tab.dart';
import 'widgets/confirm_dialog.dart';

/// The three-tab shell. R10: the list of nights and the profile live here —
/// the lowest State above every screen that reads or changes them.
class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  // R11: owned by MyApp, passed through to the profile tab.
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<GameNight> _nights = seedNights();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  // R12: every setState wraps only the assignment.
  void _selectTab(int tab) => setState(() => _tab = tab);

  void _replace(GameNight night) => setState(
    () => _nights = [for (final n in _nights) n.id == night.id ? night : n],
  );

  void _delete(GameNight night) =>
      setState(() => _nights = _nights.where((n) => n.id != night.id).toList());

  void _toggleFavourite(GameNight night) =>
      _replace(night.copyWith(favourite: !night.favourite));

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  // R28: one Navigator — the pushed detail covers the NavigationBar.
  void _open(GameNight night) => Navigator.of(context).pushNamed(
    Routes.detail,
    arguments: DetailArgs(
      night: night,
      you: _profile.name,
      onChanged: _replace,
      onDelete: _delete,
      onOpenProfile: () => _selectTab(2),
    ),
  );

  Future<void> _create() async {
    // R27: await the typed answer; null means the user backed out.
    final night = await Navigator.of(context)
        .pushNamed<GameNight>(Routes.form, arguments: const FormArgs());
    if (night == null || !mounted) return;
    setState(() => _nights = [..._nights, night]);
  }

  void _showAbout() {
    Navigator.of(context).pop(); // R32: the tile closes the drawer first
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Nights'),
        content: const Text(
          'Board game nights at the campus club. Lab 1 for Mobile '
          'Development — all data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    Navigator.of(context).pop(); // close the drawer
    final ok = await confirm(
      context,
      title: 'Reset data?',
      message: 'All nights go back to the seed and your profile is cleared.',
      confirmLabel: 'Reset',
    );
    if (ok != true || !mounted) return;
    setState(() {
      _nights = seedNights();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_tab) {
          0 => 'Game nights',
          1 => 'Favourites',
          _ => 'Profile',
        }),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Game Nights',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: _showAbout,
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset data'),
              onTap: _resetData,
            ),
          ],
        ),
      ),
      body: switch (_tab) {
        0 => ListTab(
          nights: _nights,
          onOpen: _open,
          onToggleFavourite: _toggleFavourite,
        ),
        1 => FavouritesTab(
          nights: _nights,
          onOpen: _open,
          onToggleFavourite: _toggleFavourite,
          onBrowse: () => _selectTab(0),
        ),
        _ => ProfileTab(
          profile: _profile,
          nights: _nights,
          themeMode: widget.themeMode,
          onProfileChanged: _setProfile,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      },
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('New night'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.casino_outlined),
            selectedIcon: Icon(Icons.casino),
            label: 'All',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
