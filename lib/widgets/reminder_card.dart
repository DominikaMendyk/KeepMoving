import 'package:flutter/material.dart';

import '../models/reminder.dart';

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onDone,
    required this.onSkip,
  });

  final Reminder reminder;
  final VoidCallback onDone;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isWater = reminder.type == ReminderType.water;
    final stretch = reminder.stretch;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isWater ? Icons.water_drop : Icons.accessibility_new,
                  color: scheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isWater ? 'Time for a glass of water' : stretch!.name,
                    style: text.titleLarge
                        ?.copyWith(color: scheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
            if (!isWater && stretch != null) ...[
              const SizedBox(height: 8),
              Text(
                stretch.instruction,
                style: text.bodyLarge?.copyWith(color: scheme.onPrimaryContainer),
              ),
              const SizedBox(height: 4),
              Text(
                'About ${stretch.seconds} seconds',
                style:
                    text.bodyMedium?.copyWith(color: scheme.onPrimaryContainer),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(
                  onPressed: onDone,
                  child: Text(isWater ? 'I drank water' : 'I stretched'),
                ),
                const SizedBox(width: 8),
                TextButton(onPressed: onSkip, child: const Text('Skip')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
