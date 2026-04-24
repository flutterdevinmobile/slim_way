import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ModernSummaryCard extends StatelessWidget {
  final DailyLog? log;
  final double limit;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final int streakCount;
  final VoidCallback? onLeaderboardTap;
  final VoidCallback? onTap;

  const ModernSummaryCard({
    super.key,
    required this.log,
    required this.limit,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    this.streakCount = 0,
    this.onLeaderboardTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final net = math.max(0.0, log?.foodCal ?? 0.0);
    final progress = (net / limit).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkGray : Colors.white,
              borderRadius: BorderRadius.circular(32.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 30.r,
                  offset: Offset(0, 10.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 60.0.r,
                      lineWidth: 12.0.w,
                      percent: progress,
                      animation: true,
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: AppTheme.green,
                      backgroundColor: AppTheme.green.withValues(alpha: 0.1),
                      center: Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'dashboard.left'.tr().toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '${(limit - net).toInt()}',
                            style: TextStyle(
                                fontSize: 32.sp, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'dashboard.of_goal'.tr(namedArgs: {'limit': limit.toInt().toString()}),
                            style:
                                TextStyle(fontSize: 12.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                const Divider(height: 1, color: Colors.grey, thickness: 0.1),
                SizedBox(height: 16.h),
                _buildMacroRow(context),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Row(
            children: [
              if (streakCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '$streakCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              if (streakCount > 0) const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onLeaderboardTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMacroItem('dashboard.protein'.tr(), '🍖', (log?.protein ?? 0).toInt(), proteinGoal.toInt(), Colors.blue),
        _buildMacroItem('dashboard.carbs'.tr(), '🍞', (log?.carbs ?? 0).toInt(), carbsGoal.toInt(), Colors.orange),
        _buildMacroItem('dashboard.fat'.tr(), '🥓', (log?.fat ?? 0).toInt(), fatGoal.toInt(), Colors.red),
      ],
    );
  }

  Widget _buildMacroItem(String label, String icon, int value, int goal, Color color) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(icon, style: TextStyle(fontSize: 10.sp)),
            SizedBox(width: 4.w),
            Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            SizedBox(
              width: 50.w,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                minHeight: 4.h,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '$value g',
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
