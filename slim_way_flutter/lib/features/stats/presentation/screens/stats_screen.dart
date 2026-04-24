import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/features/home/presentation/blocs/summary_bloc/summary_bloc.dart';
import 'package:slim_way_flutter/features/stats/presentation/blocs/stats_bloc/stats_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.whenOrNull(authenticated: (user) => user.id);
    if (userId != null) {
      context.read<StatsBloc>().add(StatsRequested());
      context.read<SummaryBloc>().add(SummaryRefreshRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return Scaffold(
          appBar: AppBar(
            title: Text('common.insights'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: RefreshIndicator(
            color: AppTheme.green,
            onRefresh: () async => _fetchData(),
            child: BlocBuilder<StatsBloc, StatsState>(
              builder: (context, statsState) {
                return BlocBuilder<SummaryBloc, SummaryState>(
                  builder: (context, summaryState) {
                    final weeklyStats = statsState.maybeWhen(
                      success: (ws, _) => ws,
                      orElse: () => <DailyLog>[],
                    );
                    final weightHistory = statsState.maybeWhen(
                      success: (_, wh) => wh,
                      orElse: () => <WeeklyWeight>[],
                    );
                    final summaryLog = summaryState.maybeWhen(
                      success: (summary, _) => summary,
                      orElse: () => null,
                    );

                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          _buildChartCard(
                            'activity.calories'.tr(),
                            'stats.calorie_subtitle'.tr(),
                            _buildCalorieChart(weeklyStats, isDark),
                            isDark,
                          ),
                          const SizedBox(height: 32),
                          _buildChartCard(
                            'dashboard.macros_breakdown'.tr(),
                            'stats.macros_subtitle'.tr(),
                            _buildMacroPieChart(summaryLog, isDark),
                            isDark,
                          ),
                          const SizedBox(height: 32),
                          _buildChartCard(
                            'common.water'.tr(),
                            'stats.water_subtitle'.tr(),
                            _buildWaterChart(weeklyStats, isDark),
                            isDark,
                          ),
                          const SizedBox(height: 32),
                          _buildChartCard(
                            'profile.weight'.tr(),
                            'stats.weight_subtitle'.tr(),
                            _buildWeightChart(weightHistory, isDark),
                            isDark,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartCard(String title, String subtitle, Widget chart, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 30, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 32),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  Widget _buildCalorieChart(List<DailyLog> stats, bool isDark) {
    if (stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, color: AppTheme.green.withValues(alpha: 0.2), size: 48),
            Text('stats.no_calories'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: isDark ? AppTheme.darkGray : Colors.white,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {

              return BarTooltipItem(
                '${rod.toY.toInt()} ${'food.unit_kcal'.tr()}',
                TextStyle(color: AppTheme.green, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < stats.length) {
                  final date = stats[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(DateFormat('E').format(date)[0], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.grey)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: stats.asMap().entries.map((entry) {
          final isToday = DateUtils.isSameDay(entry.value.date, DateTime.now());
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.foodCal > 0 ? entry.value.foodCal : (isToday ? 0 : 50),
                gradient: isToday ? AppTheme.greenGradient : LinearGradient(colors: [AppTheme.green.withValues(alpha: 0.3), AppTheme.green.withValues(alpha: 0.1)]),
                width: 14,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 2500, // Goal
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );

  }

  Widget _buildMacroPieChart(DailyLog? log, bool isDark) {
    if (log == null || (log.protein == 0 && log.fat == 0 && log.carbs == 0)) {
      return Center(child: Text('stats.no_data'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(value: log.protein ?? 0, title: 'food.protein_short'.tr(), color: Colors.blue, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: log.fat ?? 0, title: 'food.fat_short'.tr(), color: Colors.red, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: log.carbs ?? 0, title: 'food.carbs_short'.tr(), color: Colors.orange, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildWaterChart(List<DailyLog> stats, bool isDark) {
    if (stats.isEmpty) return Center(child: Text('stats.no_data'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)));

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: isDark ? AppTheme.darkGray : Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {

              return BarTooltipItem(
                '${rod.toY.toInt()} ml',
                const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12),
              );
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < stats.length) {
                  final date = stats[value.toInt()].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(DateFormat('E').format(date)[0], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.grey)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: stats.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (entry.value.waterMl ?? 0).toDouble(),
                gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                width: 14,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 2500,
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );

  }

  Widget _buildWeightChart(List<WeeklyWeight> weights, bool isDark) {
    if (weights.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded, color: AppTheme.green.withValues(alpha: 0.2), size: 48),
            Text('stats.weight_tip'.tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: isDark ? AppTheme.darkGray : Colors.white,
            getTooltipItems: (touchedSpots) {

              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y} kg',
                  TextStyle(color: AppTheme.green, fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white10 : Colors.black12, strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: weights.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            gradient: AppTheme.greenGradient,
            barWidth: 5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppTheme.green,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppTheme.green.withValues(alpha: 0.3), AppTheme.green.withValues(alpha: 0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );

  }
}
