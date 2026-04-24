import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/features/home/presentation/blocs/summary_bloc/summary_bloc.dart';
import 'package:slim_way_flutter/features/activity/presentation/blocs/activity_bloc/activity_bloc.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:slim_way_flutter/shared/utils/date_time_utils.dart';
import 'package:slim_way_flutter/shared/presentation/widgets/stat_card.dart';

enum ActivityPeriod { day, week, month, year }

class WalkLogScreen extends StatefulWidget {
  const WalkLogScreen({super.key});

  @override
  State<WalkLogScreen> createState() => _WalkLogScreenState();
}

class _WalkLogScreenState extends State<WalkLogScreen> {
  ActivityPeriod _selectedPeriod = ActivityPeriod.day;
  DateTime _referenceDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    DateTime start;
    DateTime end = DateTimeUtils.endOfDay(_referenceDate);

    switch (_selectedPeriod) {
      case ActivityPeriod.day:
        start = DateTimeUtils.startOfDay(_referenceDate);
        break;
      case ActivityPeriod.week:
        start = _referenceDate.subtract(Duration(days: _referenceDate.weekday - 1));
        start = DateTimeUtils.startOfDay(start);
        break;
      case ActivityPeriod.month:
        start = DateTime(_referenceDate.year, _referenceDate.month, 1);
        break;
      case ActivityPeriod.year:
        start = DateTime(_referenceDate.year, 1, 1);
        break;
    }

    context.read<ActivityBloc>().add(ActivityHistoryRefreshRequested(
      start: start.toUtc(),
      end: end.toUtc(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return BlocBuilder<ActivityBloc, ActivityState>(
          builder: (context, activityState) {
            final history = activityState.maybeWhen(
              success: (history) => _filterByPeriod(history),
              orElse: () => <Walk>[],
            );
            final totalSteps = history.fold<int>(0, (sum, walk) => sum + walk.steps);

            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('activity.title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.green),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _referenceDate,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _referenceDate = picked);
                        _fetchHistory();
                      }
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                color: AppTheme.green,
                onRefresh: () async {
                  context.read<SummaryBloc>().add(SummaryRefreshRequested());
                  _fetchHistory();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildPeriodSelector(),
                      const SizedBox(height: 32),
                      _buildRealTimeProgress(totalSteps, isDark),
                      const SizedBox(height: 32),
                      _buildStatsSummary(totalSteps, history, isDark),
                      const SizedBox(height: 24),
                      history.isEmpty
                          ? Text('activity.no_activity'.tr(), style: const TextStyle(color: Colors.grey))
                          : _buildHistoryList(history, isDark),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                heroTag: 'walkLogFab',
                onPressed: () => _showManualEntry(context),
                backgroundColor: AppTheme.green,
                icon: const Icon(Icons.sync_rounded, color: Colors.white),
                label: Text('activity.sync_steps'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<ActivityPeriod>(
      segments: [
        ButtonSegment(value: ActivityPeriod.day, label: Text('common.day'.tr(), style: const TextStyle(fontSize: 12))),
        ButtonSegment(value: ActivityPeriod.week, label: Text('common.week'.tr(), style: const TextStyle(fontSize: 12))),
        ButtonSegment(value: ActivityPeriod.month, label: Text('common.month'.tr(), style: const TextStyle(fontSize: 12))),
        ButtonSegment(value: ActivityPeriod.year, label: Text('common.year'.tr(), style: const TextStyle(fontSize: 12))),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (value) {
        setState(() => _selectedPeriod = value.first);
        _fetchHistory();
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppTheme.green,
        selectedForegroundColor: Colors.white,
      ),
    );
  }

  Widget _buildRealTimeProgress(int totalSteps, bool isDark) {
    const goal = 10000;
    final progress = (totalSteps / goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: CircularPercentIndicator(
        radius: 100.0,
        lineWidth: 20.0,
        percent: progress,
        animation: true,
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: AppTheme.green,
        backgroundColor: AppTheme.green.withValues(alpha: 0.1),
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(totalSteps.toString(), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
            Text('activity.steps'.tr().toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(int totalSteps, List<Walk> history, bool isDark) {
    double totalKcal = history.fold<double>(0, (sum, walk) => sum + walk.calories);
    double totalKm = totalSteps * 0.0008;

    return Column(
      children: [
        StatCard(label: 'activity.calories'.tr(), value: totalKcal.toInt().toString(), unit: 'food.unit_kcal'.tr(), icon: Icons.local_fire_department_rounded, isDark: isDark),
        const SizedBox(height: 16),
        StatCard(label: 'activity.distance'.tr(), value: totalKm.toStringAsFixed(1), unit: 'km', icon: Icons.map_rounded, isDark: isDark),
        const SizedBox(height: 16),
        StatCard(label: 'activity.steps'.tr(), value: totalSteps.toString(), unit: 'activity.steps'.tr().toLowerCase(), icon: Icons.directions_walk_rounded, isDark: isDark),
      ],
    );
  }

  Widget _buildHistoryList(List<Walk> history, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final walk = history[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkGray : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.green.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_walk_rounded, color: AppTheme.green),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(walk.distanceKm == -1.0 ? 'activity.auto_steps'.tr() : 'activity.manual_entry'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('activity.steps_count'.tr(namedArgs: {'count': walk.steps.toString()}), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Text('${walk.calories.toInt()} ${'food.unit_kcal'.tr()}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.green)),
            ],
          ),
        );
      },
    );
  }

  List<Walk> _filterByPeriod(List<Walk> history) {
    DateTime start;
    DateTime end = DateTimeUtils.endOfDay(_referenceDate);

    switch (_selectedPeriod) {
      case ActivityPeriod.day:
        start = DateTimeUtils.startOfDay(_referenceDate);
        break;
      case ActivityPeriod.week:
        start = _referenceDate.subtract(Duration(days: _referenceDate.weekday - 1));
        start = DateTimeUtils.startOfDay(start);
        break;
      case ActivityPeriod.month:
        start = DateTime(_referenceDate.year, _referenceDate.month, 1);
        break;
      case ActivityPeriod.year:
        start = DateTime(_referenceDate.year, 1, 1);
        break;
    }

    return history.where((walk) {
      final walkDate = walk.createdAt.toLocal();
      return walkDate.isAfter(start.subtract(const Duration(seconds: 1))) && 
             walkDate.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  void _showManualEntry(BuildContext context) {
    final stepsController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 32, top: 32, left: 32, right: 32),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('activity.sync_steps'.tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            TextField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.directions_walk_rounded, color: AppTheme.green),
                labelText: 'activity.steps'.tr(),
                filled: true,
                fillColor: AppTheme.green.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final s = int.tryParse(stepsController.text) ?? 0;
                if (s > 0) {
                  final authState = context.read<AuthBloc>().state;
                  final userId = authState.whenOrNull(authenticated: (user) => user.id);
                  if (userId == null) return;

                  context.read<ActivityBloc>().add(ActivityWalkAdded(Walk(
                    userId: userId,
                    steps: s,
                    distanceKm: s * 0.0008,
                    calories: s * 0.04,
                    createdAt: DateTime.now().toUtc(),
                  )));
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('activity.save_success'.tr()), backgroundColor: AppTheme.green),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              child: Text('common.save'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
