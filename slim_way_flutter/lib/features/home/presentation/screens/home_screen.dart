import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/features/home/presentation/blocs/summary_bloc/summary_bloc.dart';
import 'package:slim_way_flutter/features/activity/presentation/blocs/activity_bloc/activity_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/navigation_bloc/navigation_bloc.dart';

import 'package:slim_way_flutter/shared/utils/image_utils.dart';
import 'package:slim_way_flutter/shared/utils/date_time_utils.dart';
import 'package:slim_way_flutter/shared/utils/user_utils.dart';
import '../widgets/modern_summary_card.dart';
import '../widgets/water_tracker_card.dart';
import '../widgets/pedometer_card.dart';
import 'package:slim_way_flutter/features/social/presentation/screens/leaderboard_screen.dart';
import 'analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SummaryBloc>().add(SummaryRefreshRequested());
      context.read<ActivityBloc>().add(const ActivityHistoryRefreshRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            return authState.maybeWhen(
              authenticated: (user) {
                return BlocBuilder<SummaryBloc, SummaryState>(
                  builder: (context, summaryState) {
                    return BlocBuilder<ActivityBloc, ActivityState>(
                      builder: (context, activityState) {
                        final log = summaryState.maybeWhen(
                          success: (summary, _) => summary,
                          orElse: () => null,
                        );
                        final foods = summaryState.maybeWhen(
                          success: (_, foods) => foods,
                          orElse: () => <Food>[],
                        );

                        final totalSteps = activityState.maybeWhen(
                          success: (history) => DateTimeUtils.filterToday(
                            history,
                          ).fold<int>(0, (sum, walk) => sum + walk.steps),
                          orElse: () => 0,
                        );

                        final calorieLimit = user.dailyCalorieGoal?.toDouble() ?? 
                            UserUtils.calculateCalorieLimit(user);
                        final waterGoal = user.dailyWaterGoal ?? 2000;
                        
                        final proteinGoal = user.currentWeight * 1.5;
                        final fatGoal = calorieLimit * 0.25 / 9;
                        final carbsGoal = (calorieLimit - (proteinGoal * 4) - (fatGoal * 9)) / 4;

                        return Scaffold(
                          backgroundColor: Colors.transparent,
                          appBar: AppBar(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'home.greeting'.tr(
                                    namedArgs: {'name': user.name},
                                  ),
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'dashboard.title'.tr(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                            centerTitle: false,

                            actions: [
                              _buildSyncIndicator(
                                summaryState is SummaryPrepare,
                              ),
                              SizedBox(width: 8.w),
                              _buildProfileAvatar(user),
                              SizedBox(width: 16.w),
                            ],
                          ),
                          body: RefreshIndicator(
                            color: AppTheme.green,
                            onRefresh: () async {
                              context.read<SummaryBloc>().add(
                                SummaryRefreshRequested(),
                              );
                              context.read<ActivityBloc>().add(
                                const ActivityHistoryRefreshRequested(),
                              );
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16.h),
                                  ModernSummaryCard(
                                    log: log,
                                    limit: calorieLimit,
                                    proteinGoal: proteinGoal,
                                    carbsGoal: carbsGoal,
                                    fatGoal: fatGoal,
                                    streakCount: user.streakCount,
                                    onLeaderboardTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LeaderboardScreen(),
                                      ),
                                    ),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AnalysisScreen(
                                          log: log,
                                          limit: calorieLimit,
                                          proteinGoal: proteinGoal,
                                          carbsGoal: carbsGoal,
                                          fatGoal: fatGoal,
                                        ),
                                      ),
                                    ),
                                  ),
                                  _buildDailyChallenge(log, isDark, waterGoal),
                                  SizedBox(height: 32.h),

                                  _buildSectionHeader(
                                    'dashboard.recent_meals'.tr(),
                                    () {
                                      context.read<NavigationBloc>().add(
                                        const TabChanged(1),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 16.h),
                                  _buildTodayFoodsList(foods),
                                  SizedBox(height: 32.h),
                                  WaterTrackerCard(
                                    log: log,
                                    glassSize: user.waterGlassSize ?? 250,
                                    onAdd: () => _confirmWaterAdd(
                                      context,
                                      user.waterGlassSize ?? 250,
                                    ),
                                    onUpdate: (val) => context
                                        .read<SummaryBloc>()
                                        .add(WaterAdded(val)),
                                  ),
                                  SizedBox(height: 32.h),
                                  PedometerCard(
                                    steps: totalSteps,
                                    goal: 8000,
                                    onRefresh: () => context.read<ActivityBloc>().add(const ActivityHistoryRefreshRequested()),
                                  ),
                                  SizedBox(height: 100.h),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              orElse: () => const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppTheme.green),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDailyChallenge(DailyLog? log, bool isDark, int waterGoal) {
    final waterMl = log?.waterMl ?? 0;
    final progress = (waterMl / waterGoal).clamp(0.0, 1.0);
    final isDone = progress >= 1.0;

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDone
              ? [AppTheme.green, AppTheme.green.withValues(alpha: 0.8)]
              : [Colors.orange.shade400, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: (isDone ? AppTheme.green : Colors.orange).withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.emoji_events_rounded : Icons.star_rounded,
              color: Colors.white,
              size: 32.r,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDone ? 'dashboard.task_done'.tr() : 'dashboard.daily_task'.tr(),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isDone ? 'dashboard.super_active'.tr() : 'dashboard.water_task'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 6.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncIndicator(bool isSyncing) {
    return AnimatedOpacity(
      opacity: isSyncing ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.green.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.green,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'dashboard.syncing'.tr(),
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(User user) {
    final imageProvider = ImageUtils.getSafeImageProvider(user.photoUrl);
    return GestureDetector(
      onTap: () => context.read<NavigationBloc>().add(const TabChanged(4)),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.green.withValues(alpha: 0.1),
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? const Icon(Icons.person_rounded, color: AppTheme.green)
            : null,
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            'dashboard.see_all'.tr(),
            style: TextStyle(color: AppTheme.green, fontSize: 13.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayFoodsList(List<Food> foods) {
    if (foods.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32.r),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(32.r),
        ),
        child: Column(
          children: [
            Icon(Icons.restaurant_rounded, color: Colors.grey, size: 40.r),
            SizedBox(height: 16.h),
            Text(
              'food.no_foods'.tr(),
              style: TextStyle(color: Colors.grey, fontSize: 13.sp),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 160.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          final food = foods[index];
          final img = ImageUtils.getSafeImageProvider(food.photoUrl);
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            width: 140.w,
            margin: EdgeInsets.only(right: 16.w, bottom: 8.h),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkGray : Colors.white,
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 15.r,
                  offset: Offset(0, 8.h),
                ),
              ],
              border: Border.all(color: AppTheme.green.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      image: img != null
                          ? DecorationImage(image: img, fit: BoxFit.cover)
                          : null,
                      color: AppTheme.green.withValues(alpha: 0.05),
                    ),
                    child: img == null
                        ? Icon(
                            Icons.restaurant_rounded,
                            color: AppTheme.green,
                            size: 30.r,
                          )
                        : null,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          food.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '${food.calories.toInt()} ${'food.unit_kcal'.tr()}',
                            style: TextStyle(
                              color: AppTheme.green,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmWaterAdd(BuildContext context, int glassSize) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('common.confirm'.tr()),
        content: Text('food.confirm_water'.tr(namedArgs: {'amount': glassSize.toString()})),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('common.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SummaryBloc>().add(WaterAdded(glassSize));
            },
            child: Text('common.add'.tr()),
          ),
        ],
      ),
    );
  }
}
