import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/game_night.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

/// Pushed from a card. Gets the night and the callbacks through its route
/// arguments (R26) and keeps a local copy so it can redraw after a change.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late GameNight _night = widget.args.night;
  DateTime _now = DateTime.now();
  late final Timer _timer;

  String get _you => widget.args.you;

  @override
  void initState() {
    super.initState();
    // R13: once a minute is enough for a minutes-precision countdown.
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() => _now = DateTime.now()),
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // leaving the screen prints nothing
    super.dispose();
  }

  /// Send the change up to the shell, and redraw this screen's copy.
  void _update(GameNight night) {
    widget.args.onChanged(night);
    setState(() => _night = night);
  }

  Future<void> _join() async {
    if (_you.isEmpty) {
      // Captured now: the SnackBar can outlive this screen.
      final navigator = Navigator.of(context);
      final openProfile = widget.args.onOpenProfile;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Set your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              navigator.popUntil((route) => route.isFirst);
              openProfile();
            },
          ),
        ),
      );
      return;
    }
    final ok = await confirm(
      context,
      title: 'Join "${_night.title}"?',
      message: 'You take one of ${_night.freePlaces} free seats.',
      confirmLabel: 'Join',
    );
    if (ok != true || !mounted) return;
    _update(_night.copyWith(players: [..._night.players, _you]));
  }

  void _leave() => _update(
    _night.copyWith(players: _night.players.where((p) => p != _you).toList()),
  );

  Future<void> _edit() async {
    // R27: await the answer, check null and mounted, then setState.
    final edited = await Navigator.of(context)
        .pushNamed<GameNight>(Routes.form, arguments: FormArgs(night: _night));
    if (edited == null || !mounted) return;
    _update(edited);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete "${_night.title}"?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
    );
    if (ok != true || !mounted) return;
    widget.args.onDelete(_night);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final joined = _night.contains(_you);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // R31: no leading — AppBar draws the back arrow itself.
        appBar: AppBar(
          title: Text(_night.title, overflow: TextOverflow.ellipsis),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (action) => switch (action) {
                _MenuAction.edit => _edit(),
                _MenuAction.delete => _delete(),
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(night: _night, countdown: _night.countdownAt(_now)),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                // R29: the count in the label is live — it reads _night.
                Tab(text: 'Players (${_night.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(night: _night),
                  _PlayersTab(night: _night, you: _you),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            // R16: a button that cannot act gets onPressed: null; once you
            // are on the list it becomes its opposite.
            child: FilledButton.icon(
              onPressed: joined
                  ? _leave
                  : (_night.isFull || _night.isPast ? null : _join),
              icon: Icon(joined ? Icons.logout : Icons.login),
              label: Text(joined ? 'Leave' : 'Join'),
            ),
          ),
        ),
      ),
    );
  }
}

/// R24: an asset image with the genre icon, the genre in one corner and the
/// countdown in the other.
class _Header extends StatelessWidget {
  const _Header({required this.night, required this.countdown});

  final GameNight night;
  final Countdown countdown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // R9: exhaustive switch over the sealed class — no default.
    final label = switch (countdown) {
      Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
      Started() => 'In progress',
      Ended() => 'Ended',
    };
    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: night.genre.color(scheme),
              foregroundColor: scheme.onSurface,
              child: Icon(night.genre.icon, size: 36),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Chip(
              avatar: Icon(night.genre.icon),
              label: Text(night.genre.label),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Chip(
              avatar: const Icon(Icons.timer_outlined),
              label: Text(label),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.night});

  final GameNight night;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = night.places; // R5
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.event),
          title: Text(formatDateTime(night.startsAt)),
          subtitle: Text(night.isPast ? 'Already started' : 'Upcoming'),
        ),
        ListTile(
          leading: Icon(night.online ? Icons.link : Icons.place),
          title: Text(night.venue),
          subtitle: Text(night.online ? 'Online' : 'On campus'),
        ),
        ListTile(
          leading: const Icon(Icons.event_seat),
          title: Text('$taken of ${night.seats} seats taken'),
          subtitle: Text(night.isFull ? 'Full' : '$free free'),
        ),
        // R6: the optional text appears only when present — no `!` needed,
        // the pattern binds a non-null local.
        if (night.notes case final notes?)
          ListTile(leading: const Icon(Icons.notes), title: Text(notes)),
      ],
    );
  }
}

class _PlayersTab extends StatelessWidget {
  const _PlayersTab({required this.night, required this.you});

  final GameNight night;
  final String you;

  @override
  Widget build(BuildContext context) {
    final players = night.players;
    if (players.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody on the list yet',
      );
    }
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, i) {
        final isYou = players[i] == you;
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(players[i]),
          selected: isYou, // "You" highlighted in the theme's primary role
          trailing: isYou ? const Text('You') : null,
        );
      },
    );
  }
}
