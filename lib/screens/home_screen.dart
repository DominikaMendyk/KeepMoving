import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/session_config.dart';
import '../state/progress_controller.dart';
import '../state/session_controller.dart';
import '../widgets/progress_panel.dart';
import 'session_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _lengths = [25, 45, 60, 90, 120];
  int _minutes = 45;

  void _start() {
    context.read<ProgressController>().refreshDay();
    context.read<SessionController>().start(SessionConfig.forMinutes(_minutes));
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SessionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final config = SessionConfig.forMinutes(_minutes);

    return Scaffold(
      appBar: AppBar(
      title: const Text('KeepMoving Dashboard'),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Sign out',
          icon: const Icon(Icons.logout),
          onPressed: () => context.read<AuthService>().signOut(),
        ),
      ],
    ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const ProgressPanel(),
              const SizedBox(height: 32),
              Text('How long will you focus?', style: text.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in _lengths)
                    ChoiceChip(
                      label: Text(
                        m >= 60 && m % 60 == 0 ? '${m ~/ 60} h' : '$m min',
                      ),
                      selected: _minutes == m,
                      onSelected: (_) => setState(() => _minutes = m),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Water every ${config.waterEveryMinutes} min, '
                'stretch every ${config.stretchEveryMinutes} min.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Focus Mode'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
