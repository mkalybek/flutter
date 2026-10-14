import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  final String name;
  final String university;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ClipOval(
          child: Image.asset('assets/images/me.png', width: 120, height: 120),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Pacifico',
            color: theme.colorScheme.primary,
          ),
        ),
        Text(university, style: theme.textTheme.titleMedium),
      ],
    );
  }
}
