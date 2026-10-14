import 'package:flutter/material.dart';

import '../models/game_night.dart';
import 'night_card.dart';

/// A list on phones, a grid on wide screens — the same cards in both.
class NightCollection extends StatelessWidget {
  const NightCollection({
    super.key,
    required this.nights,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<GameNight> nights;
  final ValueChanged<GameNight> onOpen;
  final ValueChanged<GameNight> onToggleFavourite;

  Widget _card(GameNight night) => NightCard(
    night: night,
    onTap: () => onOpen(night),
    onToggleFavourite: () => onToggleFavourite(night),
  );

  @override
  Widget build(BuildContext context) {
    // R20: LayoutBuilder, not MediaQuery — the decision is about the space
    // this widget was given, not the size of the whole screen.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360, // cells are never wider than 360 px
              mainAxisExtent: 136, // a grid cell needs a height; fits 2 lines
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: nights.length,
            itemBuilder: (context, i) => _card(nights[i]),
          );
        }
        return ListView.separated(
          // Bottom padding keeps the last card clear of the FAB.
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
          itemCount: nights.length,
          separatorBuilder: (context, i) => const SizedBox(height: 4),
          itemBuilder: (context, i) => _card(nights[i]),
        );
      },
    );
  }
}
