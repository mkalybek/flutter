import 'package:flutter/material.dart';

class TwoWayCounter extends StatefulWidget {
  const TwoWayCounter({super.key});

  @override
  State<TwoWayCounter> createState() => _TwoWayCounterState();
}

class _TwoWayCounterState extends State<TwoWayCounter> {
  int _count = 0;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(seconds: 2)); // not inside setState
    if (!mounted) return; // the widget may be gone after the await
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton(
            // null disables the button — no if inside the callback.
            onPressed: _count == 0 ? null : () => setState(() => _count--),
            child: const Text('−'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '$_count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          FilledButton(
            onPressed: () => setState(() => _count++),
            child: const Text('+'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      FilledButton(
        onPressed: _saving ? null : _save, // a double tap cannot save twice
        child: _saving
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
      ),
    ],
  );
}
