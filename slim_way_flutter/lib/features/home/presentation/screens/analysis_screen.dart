import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AnalysisScreen extends StatelessWidget {
  final DailyLog? log;
  final double limit;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  const AnalysisScreen({
    super.key,
    required this.log,
    required this.limit,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foodCal = log?.foodCal ?? 0.0;
    final walkCal = log?.walkCal ?? 0.0;
    final netCal = log?.netCal ?? 0.0;
    final progress = (foodCal / limit).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard.analysis'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCalorieSection(foodCal, walkCal, netCal, progress, isDark),
            const SizedBox(height: 32),
            _buildMacroSection(isDark),
            const SizedBox(height: 32),
            _buildActivityInsights(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieSection(double food, double walk, double net, double progress, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 80,
            lineWidth: 16,
            percent: progress,
            animation: true,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: AppTheme.green,
            backgroundColor: AppTheme.green.withValues(alpha: 0.1),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${food.toInt()}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                Text(
                  'dashboard.consumed'.tr(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSimpleStat('🔥 ${walk.toInt()}', 'dashboard.burned'.tr()),
              _buildSimpleStat('🎯 ${limit.toInt()}', 'common.budget'.tr()),
              _buildSimpleStat('⚖️ ${net.toInt()}', 'common.net'.tr()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMacroSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'dashboard.macros_breakdown'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          _buildDetailedMacroBar('dashboard.protein'.tr(), '🍖', log?.protein ?? 0, proteinGoal, Colors.blue),
          const SizedBox(height: 16),
          _buildDetailedMacroBar('dashboard.carbs'.tr(), '🍞', log?.carbs ?? 0, carbsGoal, Colors.orange),
          const SizedBox(height: 16),
          _buildDetailedMacroBar('dashboard.fat'.tr(), '🥓', log?.fat ?? 0, fatGoal, Colors.red),
        ],
      ),
    );
  }

  Widget _buildDetailedMacroBar(String label, String icon, double value, double goal, Color color) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(icon),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Text(
              '${value.toInt()} / ${goal.toInt()} g',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 12,
          percent: progress,
          backgroundColor: color.withValues(alpha: 0.1),
          progressColor: color,
          barRadius: const Radius.circular(6),
          padding: EdgeInsets.zero,
          animation: true,
        ),
      ],
    );
  }

  Widget _buildActivityInsights(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'dashboard.activity_summary'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                '${'common.water'.tr()}: ${log?.waterMl ?? 0} ml',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.directions_run_rounded, color: Colors.orange),
              const SizedBox(width: 12),
              Text(
                '${'activity.steps'.tr()} ${'activity.calories'.tr()}: ${log?.walkCal.toInt() ?? 0} ${'food.unit_kcal'.tr()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
