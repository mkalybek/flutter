import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../models/profile.dart';

/// Tab 3. The profile and the theme mode live above (shell and MyApp);
/// this tab shows them and sends changes up through callbacks (R10, R11).
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.nights,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<GameNight> nights;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  // R38: controllers start from the model, created once, disposed.
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);
  final _groupFocus = FocusNode();

  static final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{4}$');

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // "Reset data" in the drawer can clear the profile while this tab is
    // open — the fields must follow the model, not keep the old text.
    if (_name.text != widget.profile.name) _name.text = widget.profile.name;
    if (_group.text != widget.profile.group) _group.text = widget.profile.group;
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    final group = (value ?? '').trim();
    if (group.isEmpty) return null; // the group is optional
    return _groupPattern.hasMatch(group) ? null : 'Like IT-2302';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name;
    // R38: computed on every build — never stored, so it cannot go stale.
    final lists = widget.nights.fold(
      0,
      (sum, night) => name.isNotEmpty && night.contains(name) ? sum + 1 : sum,
    );
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Press Enter to save',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onFieldSubmitted: (value) {
            widget.onProfileChanged(
              widget.profile.copyWith(name: value.trim()),
            );
            _groupFocus.requestFocus();
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _group,
          focusNode: _groupFocus,
          decoration: const InputDecoration(
            labelText: 'Group',
            hintText: 'IT-2302',
            helperText: 'Press Enter to save',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateGroup,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onFieldSubmitted: (value) {
            if (_validateGroup(value) != null) return;
            widget.onProfileChanged(
              widget.profile.copyWith(group: value.trim()),
            );
          },
        ),
        const SizedBox(height: 24),
        Text('You are on $lists lists', style: text.titleMedium),
        const SizedBox(height: 24),
        Text('Theme', style: text.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(switch (mode) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                }),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
