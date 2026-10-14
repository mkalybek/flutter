import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../widgets/empty_state.dart';
import '../widgets/night_collection.dart';

/// Tab 1. The nights come from the shell (R10); only the filters live here —
/// they are this tab's view of the data, not the data itself.
class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.nights,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<GameNight> nights;
  final ValueChanged<GameNight> onOpen;
  final ValueChanged<GameNight> onToggleFavourite;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final _search = TextEditingController();
  String _query = '';
  GameGenre? _genre; // null means "All"
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    // R7: where on the shell's list, then sort a copy — never state in place.
    final visible = [
      ...widget.nights.where(
        (n) =>
            (_genre == null || n.genre == _genre) &&
            (_showPast || !n.isPast) &&
            n.title.toLowerCase().contains(query),
      ),
    ]..sort(compareByDate);

    // R21: one Column, the list in Expanded. No shrinkWrap, no fixed heights.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search by title',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear',
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _genre == null,
                onSelected: (_) => setState(() => _genre = null),
              ),
              for (final genre in GameGenre.values)
                ChoiceChip(
                  avatar: Icon(genre.icon),
                  label: Text(genre.label),
                  selected: _genre == genre,
                  onSelected: (_) => setState(() => _genre = genre),
                ),
              FilterChip(
                label: const Text('Show past'),
                selected: _showPast,
                onSelected: (value) => setState(() => _showPast = value),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No game nights match',
                  actionLabel: 'Clear search',
                  onAction: _clearSearch,
                )
              : NightCollection(
                  nights: visible,
                  onOpen: widget.onOpen,
                  onToggleFavourite: widget.onToggleFavourite,
                ),
        ),
      ],
    );
  }
}
