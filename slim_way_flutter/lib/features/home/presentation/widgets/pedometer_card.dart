import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PedometerCard extends StatelessWidget {
  final int steps;
  final int goal;
  final VoidCallback? onRefresh;

  const PedometerCard({
    super.key,
    required this.steps,
    required this.goal,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (steps / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 10.0,
            percent: progress,
            animation: true,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: AppTheme.green,
            backgroundColor: AppTheme.green.withValues(alpha: 0.1),
            center: const Icon(Icons.directions_walk_rounded, color: AppTheme.green),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'activity.steps'.tr().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  steps.toString(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                Text(
                  '${'profile.target'.tr()}: $goal ${'activity.steps'.tr().toLowerCase()}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.sync_rounded, color: AppTheme.green),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
