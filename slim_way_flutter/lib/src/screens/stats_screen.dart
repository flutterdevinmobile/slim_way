import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/i18n.dart';
import 'package:slim_way_client/slim_way_client.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = state.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(I18n.t('insights', locale), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        color: AppTheme.green,
        onRefresh: () async {
          await state.fetchDailySummary();
          await state.fetchHistory();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildChartCard(
                I18n.t('calories', locale),
                'Daily calorie intake (last 7 days)',
                _buildCalorieChart(state.weeklyStats, isDark),
                isDark,
              ),
              const SizedBox(height: 32),
              _buildChartCard(
                'Makronutriyentlar',
                'Bugungi oqsil, yog\' va uglevodlar balansi',
                _buildMacroPieChart(state.todayLog, isDark),
                isDark,
              ),
              const SizedBox(height: 32),
              _buildChartCard(
                'Suv isteʼmoli',
                'Oxirgi 7 kunlik suv isteʼmoli (ml)',
                _buildWaterChart(state.weeklyStats, isDark),
                isDark,
              ),
              const SizedBox(height: 32),
              _buildChartCard(
                I18n.t('weight', locale),
                'Weekly weight progression',
                _buildWeightChart(state.weightHistory, isDark),
                isDark,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
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
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 30, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: AppTheme.green.withOpacity(0.05)),
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

  Widget _buildCalorieChart(List<dynamic> stats, bool isDark) {
    if (stats.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, color: AppTheme.green.withOpacity(0.2), size: 48),
            const Text('No calorie data yet', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
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
                    child: Text(DateFormat('E').format(date)[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                toY: entry.value.foodCal > 0 ? entry.value.foodCal : 50,
                gradient: AppTheme.greenGradient,
                width: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMacroPieChart(DailyLog? log, bool isDark) {
    if (log == null || (log.protein == 0 && log.fat == 0 && log.carbs == 0)) {
      return const Center(child: Text('Bugun hali maʼlumot yoʻq', style: TextStyle(color: Colors.grey, fontSize: 12)));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(value: log.protein ?? 0, title: 'Prot', color: Colors.blue, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: log.fat ?? 0, title: 'Fat', color: Colors.red, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
          PieChartSectionData(value: log.carbs ?? 0, title: 'Carb', color: Colors.orange, radius: 50, titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildWaterChart(List<dynamic> stats, bool isDark) {
    if (stats.isEmpty) return const Center(child: Text('Maʼlumot yoʻq', style: TextStyle(color: Colors.grey, fontSize: 12)));

    return BarChart(
      BarChartData(
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
                    child: Text(DateFormat('E').format(date)[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                color: Colors.blueAccent,
                width: 12,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeightChart(List<dynamic> weights, bool isDark) {
    if (weights.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded, color: AppTheme.green.withOpacity(0.2), size: 48),
            const Text('Log your weight weekly', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: weights.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
            isCurved: true,
            curveSmoothness: 0.4,
            gradient: AppTheme.greenGradient,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppTheme.green.withOpacity(0.2), AppTheme.green.withOpacity(0)],
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
