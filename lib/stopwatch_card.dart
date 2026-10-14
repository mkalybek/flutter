import 'dart:async';

import 'package:flutter/material.dart';

class StopwatchCard extends StatefulWidget {
  const StopwatchCard({super.key});

  @override
  State<StopwatchCard> createState() => _StopwatchCardState();
}

class _StopwatchCardState extends State<StopwatchCard> {
  int _seconds = 0;
  Timer? _timer;

  // Computed from _seconds — a value you can compute is not state.
  String get _formatted {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _start() {
    if (_timer != null) return; // already running: no second timer
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _seconds++),
    );
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _reset() {
    _stop();
    setState(() => _seconds = 0);
  }

  @override
  void dispose() {
    _timer?.cancel(); // without this: "setState() called after dispose()"
    super.dispose(); // last — the mirror image of super.initState() first
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(_formatted, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton(onPressed: _start, child: const Text('Start')),
              OutlinedButton(onPressed: _stop, child: const Text('Stop')),
              TextButton(onPressed: _reset, child: const Text('Reset')),
            ],
          ),
        ],
      ),
    ),
  );
}
