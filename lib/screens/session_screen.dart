import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../models/reminder.dart';
import '../state/progress_controller.dart';
import '../state/session_controller.dart';
import '../widgets/progress_panel.dart';
import '../widgets/reminder_card.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  Future<void> _confirmStop(BuildContext context) async {
    final session = context.read<SessionController>();

    if (session.status == SessionStatus.finished) {
      Navigator.of(context).pop();
      return;
    }

    final stop = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('End session'),
          ),
        ],
      ),
    );

    if (stop == true) {
      session.stop();
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  /// Rewards are only given here, when the user answers a reminder.
  void _confirmReminder(BuildContext context, Reminder reminder) {
    final progress = context.read<ProgressController>();
    switch (reminder.type) {
      case ReminderType.water:
        progress.drinkWater();
      case ReminderType.stretch:
        progress.completeStretch();
    }
    context.read<SessionController>().resolveReminder();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final text = Theme.of(context).textTheme;
    final finished = session.status == SessionStatus.finished;
    final paused = session.status == SessionStatus.paused;
    final pending = session.pending;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmStop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(finished ? 'Session complete' : 'Focus & Move Session'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Text(
                    finished ? 'Well done' : formatDuration(session.remaining),
                    style: text.displayLarge,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: session.progress),
                const SizedBox(height: 24),
                if (pending != null && !finished)
                  ReminderCard(
                    reminder: pending,
                    onDone: () => _confirmReminder(context, pending),
                    onSkip: () =>
                        context.read<SessionController>().resolveReminder(),
                  )
                else if (!finished)
                  Text(
                    paused
                        ? 'Paused'
                        : 'Focus. We will nudge you when it is time.',
                    style: text.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                const ProgressPanel(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!finished) ...[
                      OutlinedButton.icon(
                        onPressed: paused ? session.resume : session.pause,
                        icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                        label: Text(paused ? 'Resume' : 'Pause'),
                      ),
                      const SizedBox(width: 12),
                    ],
                    FilledButton(
                      onPressed: () => _confirmStop(context),
                      child: Text(finished ? 'Back to start' : 'End session'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
