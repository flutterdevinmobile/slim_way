import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slim_way_client/slim_way_client.dart';
import '../theme.dart';
import '../providers/app_state.dart';
import '../utils/i18n.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
      context.read<AppState>().fetchDailySummary();
      context.read<AppState>().initPedometer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final log = state.todayLog;
    final user = state.currentUser;
    final locale = state.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.green)));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, ${user.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text(I18n.t('dashboard', locale), style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38)),
          ],
        ),
        actions: [
          _buildSyncIndicator(state.isSyncing),
          const SizedBox(width: 8),
          _buildProfileAvatar(user, state),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.green,
        onRefresh: () => state.fetchDailySummary(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildModernSummary(context, log, state.dailyCalorieLimit, locale),
              const SizedBox(height: 32),
              _buildSectionHeader(I18n.t('recent_meals', locale), () => state.selectedTabIndex = 1),
              const SizedBox(height: 16),
              _buildTodayFoodsList(state),
              const SizedBox(height: 32),
              _buildWaterTracker(context, state, locale),
              const SizedBox(height: 32),
              _buildPedometerCard(state, locale),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
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
          color: AppTheme.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.green.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.green),
            ),
            SizedBox(width: 8),
            Text('Syncing', style: TextStyle(fontSize: 10, color: AppTheme.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(User user, AppState state) {
    return GestureDetector(
      onTap: () => state.selectedTabIndex = 4,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppTheme.green.withOpacity(0.1),
        backgroundImage: user.photoUrl != null && user.photoUrl!.startsWith('data:image')
            ? MemoryImage(base64Decode(user.photoUrl!.split(',')[1])) as ImageProvider
            : (user.photoUrl != null ? NetworkImage(user.photoUrl!) : null),
        child: user.photoUrl == null ? const Icon(Icons.person_rounded, color: AppTheme.green) : null,
      ),
    );
  }

  Widget _buildModernSummary(BuildContext context, DailyLog? log, double limit, String locale) {
    final net = math.max(0.0, log?.foodCal ?? 0.0);
    final progress = (net / limit).clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 12.0,
                percent: progress,
                animation: true,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: AppTheme.green,
                backgroundColor: AppTheme.green.withOpacity(0.1),
                center: Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(I18n.t('left', locale).toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    Text('${(limit - net).toInt()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                    Text('of ${limit.toInt()} kcal goal', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Colors.grey, thickness: 0.1),
          const SizedBox(height: 16),
          _buildMacroRow(context, log),
        ],
      ),
    );
  }

  Widget _buildMacroRow(BuildContext context, DailyLog? log) {
    final state = context.read<AppState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMacroItem('Prot', (log?.protein ?? 0).toInt(), state.dailyProteinGoal.toInt(), Colors.blue),
        _buildMacroItem('Carb', (log?.carbs ?? 0).toInt(), state.dailyCarbsGoal.toInt(), Colors.orange),
        _buildMacroItem('Fat', (log?.fat ?? 0).toInt(), state.dailyFatGoal.toInt(), Colors.red),
      ],
    );
  }

  Widget _buildMacroItem(String label, int value, int goal, Color color) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          children: [
            SizedBox(
              width: 50,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                color: color,
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('$value/$goal g', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildWaterTracker(BuildContext context, AppState state, String locale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final waterMl = state.todayLog?.waterMl ?? 0;
    final goal = 2500; // Hardcoded goal for now
    final glassSize = state.waterGlassSize;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Suv isteʼmoli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text('$waterMl / $goal ml', style: const TextStyle(color: AppTheme.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (waterMl / goal).clamp(0.0, 1.0),
                  backgroundColor: AppTheme.green.withOpacity(0.1),
                  color: AppTheme.green,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Tasdiqlash'),
                        content: Text('Haqiqatan ham $glassSize ml suv qo\'shmoqchimisiz?'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Bekor qilish', style: TextStyle(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              state.addWater(glassSize);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Qo\'shish', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.green.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.add_rounded, color: AppTheme.green, size: 28),
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) {
                  if (value == 'subtract') {
                    state.addWater(-glassSize);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'subtract',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                        SizedBox(width: 8),
                        Text('Orqaga qaytarish', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Stakan hajmi: $glassSize ml', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        TextButton(onPressed: onTap, child: const Text('See all', style: TextStyle(color: AppTheme.green))),
      ],
    );
  }

  Widget _buildTodayFoodsList(AppState state) {
    if (state.todayFoods.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text('No meals logged today', style: TextStyle(color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.todayFoods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final food = state.todayFoods[index];
          return Container(
            width: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkGray : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.green.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                _buildFoodImage(food.photoUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${food.calories.toInt()} kcal', style: const TextStyle(color: AppTheme.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodImage(String? photoUrl) {
    if (photoUrl == null) return Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.restaurant, color: AppTheme.green, size: 20));
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: photoUrl.startsWith('data:image')
              ? MemoryImage(base64Decode(photoUrl.split(',')[1])) as ImageProvider
              : NetworkImage(photoUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPedometerCard(AppState state, String locale) {
    final goal = 8000;
    final progress = (state.totalTodaySteps / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.greenGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: AppTheme.green.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 36.0,
            lineWidth: 8.0,
            percent: progress,
            animation: true,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.white,
            backgroundColor: Colors.white.withOpacity(0.2),
            center: const Icon(Icons.directions_walk_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.totalTodaySteps.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                Text(I18n.t('activity', locale), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Goal', style: TextStyle(color: Colors.white70, fontSize: 10)),
              Text('8,000', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
