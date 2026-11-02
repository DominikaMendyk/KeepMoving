import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_stats.dart';
import '../state/progress_controller.dart';
import 'stick_man.dart';
import 'water_bottle.dart';

/// The bottle and the stick man. Shown on the home and session screens.
class ProgressPanel extends StatelessWidget {
  const ProgressPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<ProgressController>().stats;
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                WaterBottleWidget(fillLevel: stats.waterLevel),
                const SizedBox(height: 8),
                Text(
                  '${stats.glassesToday} of ${UserStats.dailyWaterGoal} glasses',
                  style: text.titleSmall,
                ),
                Text('today', style: text.bodySmall),
              ],
            ),
            Column(
              children: [
                StickManWidget(progress: stats.muscleProgress),
                const SizedBox(height: 8),
                Text('Muscle tier ${stats.muscleLevel}', style: text.titleSmall),
                Text('${stats.totalStretches} stretches', style: text.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
