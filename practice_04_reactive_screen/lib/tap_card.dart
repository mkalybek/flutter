import 'package:flutter/material.dart';

class TapCard extends StatefulWidget {
  const TapCard({super.key});

  @override
  State<TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<TapCard> {
  int _taps = 0; // the only state in this file

  Future<void> _confirmReset() async {
    // The dialog only answers; this widget decides.
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset the count?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (reset != true || !mounted) return;
    setState(() => _taps = 0);
  }

  @override
  Widget build(BuildContext context) => Card(
    // InkWell turns the Card into a button, ripple included.
    child: InkWell(
      onTap: () => setState(() => _taps++),
      onLongPress: _confirmReset,
      child: ListTile(
        title: const Text('Tap this card'),
        trailing: Text('$_taps', style: Theme.of(context).textTheme.titleLarge),
      ),
    ),
  );
}
