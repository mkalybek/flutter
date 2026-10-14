import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../utils/format.dart';

/// R18: the one card used by the list, the grid and the favourites tab.
class NightCard extends StatelessWidget {
  const NightCard({
    super.key,
    required this.night,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final GameNight night;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final (taken: _, :free) = night.places; // R5: destructured where shown

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // R19: Stack avatar with a Positioned badge, built with a
              // collection if — no badge means no widget, not an empty one.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: night.genre.color(scheme),
                    foregroundColor: scheme.onSurface,
                    child: Icon(night.genre.icon),
                  ),
                  if (night.isFull)
                    const Positioned(
                      left: -6,
                      right: -6,
                      bottom: -6,
                      child: _Badge('FULL'),
                    )
                  else if (free <= 5)
                    Positioned(
                      left: -6,
                      right: -6,
                      bottom: -6,
                      child: _Badge('$free left'),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Expanded gives the text a tight width, so the 60-character
              // title wraps (2 lines, then ellipsis) instead of overflowing.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      night.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(formatDateTime(night.startsAt), style: text.bodySmall),
                    Text(
                      night.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavourite,
                isSelected: night.favourite,
                icon: const Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite, color: scheme.error),
                tooltip: night.favourite ? 'Unfavourite' : 'Favourite',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.surface, width: 1.5),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: scheme.onError),
        ),
      ),
    );
  }
}
