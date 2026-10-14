import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../widgets/empty_state.dart';
import '../widgets/night_collection.dart';

/// Tab 2. Stateless: everything it shows is derived from the shell's list.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.nights,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onBrowse,
  });

  final List<GameNight> nights;
  final ValueChanged<GameNight> onOpen;
  final ValueChanged<GameNight> onToggleFavourite;

  /// Asks the shell to switch to the list tab (R28).
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final favourites = [...nights.where((n) => n.favourite)]
      ..sort(compareByDate);
    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        actionLabel: 'Browse game nights',
        onAction: onBrowse,
      );
    }
    return NightCollection(
      nights: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
