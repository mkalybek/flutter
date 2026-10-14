import 'package:flutter/material.dart';

import '../models/game_night.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';

/// New and edit, one screen (R26): takes a GameNight? and answers with a
/// GameNight through pop — or with nothing when the user backs out.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, this.night});

  /// null means "create a new night".
  final GameNight? night;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  // R3: a new night starts from GameNight.empty().
  late final GameNight _initial = widget.night ?? GameNight.empty();
  bool get _isNew => widget.night == null;

  // R35: controllers and focus nodes are State fields, created once and
  // disposed in dispose().
  late final _title = TextEditingController(text: _initial.title);
  late final _venue = TextEditingController(text: _initial.venue);
  late final _seats = TextEditingController(text: '${_initial.seats}');
  late final _notes = TextEditingController(text: _initial.notes ?? '');
  late final _dateText = TextEditingController(
    text: _isNew ? '' : formatDate(_initial.startsAt),
  );
  late final _timeText = TextEditingController(
    text: _isNew ? '' : formatTime(_initial.startsAt),
  );
  final _titleFocus = FocusNode();
  final _venueFocus = FocusNode();
  final _seatsFocus = FocusNode();
  final _notesFocus = FocusNode();

  // A new night has no genre, date or time yet, so the validators make the
  // user choose them instead of silently accepting a default.
  late GameGenre? _genre = widget.night?.genre;
  late bool _online = _initial.online;
  late DateTime? _date = _isNew ? null : DateUtils.dateOnly(_initial.startsAt);
  late TimeOfDay? _time = _isNew
      ? null
      : TimeOfDay.fromDateTime(_initial.startsAt);
  bool _saving = false;

  /// R36: date and time are combined into one DateTime.
  DateTime? get _startsAt => switch ((_date, _time)) {
    (final d?, final t?) => DateTime(d.year, d.month, d.day, t.hour, t.minute),
    _ => null,
  };

  /// R30: current values vs the ones the form opened with.
  bool get _dirty =>
      _title.text != _initial.title ||
      _venue.text != _initial.venue ||
      _seats.text != '${_initial.seats}' ||
      _notes.text != (_initial.notes ?? '') ||
      _genre != widget.night?.genre ||
      _online != _initial.online ||
      _startsAt != widget.night?.startsAt;

  @override
  void dispose() {
    for (final c in [_title, _venue, _seats, _notes, _dateText, _timeText]) {
      c.dispose();
    }
    for (final f in [_titleFocus, _venueFocus, _seatsFocus, _notesFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  // R34: validators return null (valid) or a message.
  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();
    if (title.length < 3) return 'At least 3 characters';
    if (title.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validateGenre(GameGenre? genre) =>
      genre == null ? 'Choose a genre' : null;

  String? _validateVenue(String? value) {
    final venue = (value ?? '').trim();
    if (venue.isEmpty) return _online ? 'A link is required' : 'Required';
    if (_online && !venue.contains('://')) return 'A link contains ://';
    return null;
  }

  String? _validateSeats(String? value) {
    final seats = int.tryParse((value ?? '').trim());
    if (seats == null) return 'A whole number';
    if (seats < 1 || seats > 500) return 'From 1 to 500';
    final taken = widget.night?.count ?? 0;
    if (seats < taken) return '$taken players have already joined';
    return null;
  }

  String? _validateDate(String? _) => _date == null ? 'Pick a date' : null;

  String? _validateTime(String? _) {
    if (_time == null) return 'Pick a time';
    if (_startsAt case final startsAt?
        when _isNew && !startsAt.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  String? _validateNotes(String? value) =>
      (value ?? '').length > 300 ? 'At most 300 characters' : null;

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: _isNew ? today : DateTime(today.year - 1),
      lastDate: DateTime(today.year + 2),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() {
      _date = picked;
      _dateText.text = formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 18, minute: 0),
    );
    if (picked == null || !mounted) return; // Cancel keeps the old value
    setState(() {
      _time = picked;
      _timeText.text = formatTime(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    });
  }

  // R33: one validate() — the validators decide, not an if-chain here.
  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    // R17: a pretend one-second save.
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return; // R14: the user may have left meanwhile
    final notes = _notes.text.trim();
    Navigator.of(context).pop(
      GameNight(
        id: _isNew ? '${DateTime.now().microsecondsSinceEpoch}' : _initial.id,
        title: _title.text.trim(),
        // validate() passed, so genre and startsAt are set; the fallbacks
        // only satisfy the type system without a `!`.
        genre: _genre ?? _initial.genre,
        startsAt: _startsAt ?? _initial.startsAt,
        venue: _venue.text.trim(),
        seats: int.parse(_seats.text.trim()),
        players: _initial.players,
        online: _online,
        notes: notes.isEmpty ? null : notes,
        favourite: _initial.favourite,
      ),
    );
  }

  Future<void> _confirmDiscard() async {
    final discard = await confirm(
      context,
      title: 'Discard changes?',
      message: 'Your edits to this night will be lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
    );
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  void _unfocus(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    // R30: a clean form pops freely; a dirty one is blocked and asks.
    // Save calls pop(night) itself, which PopScope does not block.
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New game night' : 'Edit night')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          // Any field changed → rebuild so canPop sees the new _dirty.
          onChanged: () => setState(() {}),
          // R37: the form scrolls, so the keyboard never causes stripes.
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                decoration: const InputDecoration(labelText: 'Title'),
                maxLength: 60, // shows the 0/60 counter
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onEditingComplete: _venueFocus.requestFocus,
                onTapOutside: _unfocus,
                validator: _validateTitle,
              ),
              DropdownButtonFormField<GameGenre>(
                initialValue: _genre,
                decoration: const InputDecoration(labelText: 'Genre'),
                items: [
                  for (final genre in GameGenre.values)
                    DropdownMenuItem(
                      value: genre,
                      child: Row(
                        spacing: 8,
                        children: [Icon(genre.icon), Text(genre.label)],
                      ),
                    ),
                ],
                onChanged: (genre) => setState(() => _genre = genre),
                validator: _validateGenre,
              ),
              CheckboxListTile(
                value: _online,
                onChanged: (value) => setState(() => _online = value ?? false),
                title: const Text('Online'),
                subtitle: const Text('The venue becomes a link'),
                contentPadding: EdgeInsets.zero,
              ),
              TextFormField(
                controller: _venue,
                focusNode: _venueFocus,
                // The mode changes the meaning, keyboard and validation.
                decoration: InputDecoration(
                  labelText: _online ? 'Link' : 'Venue',
                  hintText: _online ? 'https://…' : 'Student Center, Room 204',
                ),
                keyboardType: _online ? TextInputType.url : TextInputType.text,
                textInputAction: TextInputAction.next,
                onEditingComplete: _seatsFocus.requestFocus,
                onTapOutside: _unfocus,
                validator: _validateVenue,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _seats,
                focusNode: _seatsFocus,
                decoration: const InputDecoration(labelText: 'Seats'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onEditingComplete: _notesFocus.requestFocus,
                onTapOutside: _unfocus,
                validator: _validateSeats,
              ),
              const SizedBox(height: 12),
              Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateText,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: _validateDate,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _timeText,
                      readOnly: true,
                      onTap: _pickTime,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        suffixIcon: Icon(Icons.schedule),
                      ),
                      validator: _validateTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                focusNode: _notesFocus,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onTapOutside: _unfocus,
                validator: _validateNotes,
              ),
              const SizedBox(height: 24),
              // R17: disabled while saving, so a double tap cannot save twice.
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
