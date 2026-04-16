import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slim_way_client/slim_way_client.dart';
import '../../main.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/i18n.dart';
import 'package:percent_indicator/percent_indicator.dart';

enum ActivityPeriod { day, week, month, year }

class WalkLogScreen extends StatefulWidget {
  const WalkLogScreen({super.key});

  @override
  State<WalkLogScreen> createState() => _WalkLogScreenState();
}

class _WalkLogScreenState extends State<WalkLogScreen> {
  ActivityPeriod _selectedPeriod = ActivityPeriod.day;
  List<Walk> _history = [];
  bool _isLoading = true;
  DateTime _referenceDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final appState = context.read<AppState>();
    if (appState.currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      DateTime start;
      DateTime end = DateTime(_referenceDate.year, _referenceDate.month, _referenceDate.day, 23, 59, 59);

      switch (_selectedPeriod) {
        case ActivityPeriod.day:
          start = DateTime(_referenceDate.year, _referenceDate.month, _referenceDate.day);
          break;
        case ActivityPeriod.week:
          start = _referenceDate.subtract(Duration(days: _referenceDate.weekday - 1));
          start = DateTime(start.year, start.month, start.day);
          break;
        case ActivityPeriod.month:
          start = DateTime(_referenceDate.year, _referenceDate.month, 1);
          break;
        case ActivityPeriod.year:
          start = DateTime(_referenceDate.year, 1, 1);
          break;
      }

      final logs = await client.walk.getWalkHistory(
        appState.currentUser!.id!,
        start.toUtc(),
        end.toUtc(),
      );
      
      setState(() {
        _history = logs;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locale = state.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(I18n.t('activity', locale), style: const TextStyle(fontWeight: FontWeight.bold)),
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
          await state.fetchDailySummary();
          await _fetchHistory();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildPeriodSelector(),
              const SizedBox(height: 32),
              _buildRealTimeProgress(state, isDark),
              const SizedBox(height: 32),
              const SizedBox(height: 32),
              _isLoading 
                ? const CircularProgressIndicator(color: AppTheme.green)
                : Column(
                    children: [
                      _buildStatsSummary(state, locale, isDark),
                      const SizedBox(height: 24),
                      _history.isEmpty
                          ? const Text('No recent activity records', style: TextStyle(color: Colors.grey))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _history.length,
                              itemBuilder: (context, index) {
                                final walk = _history[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.darkGray : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.green.withOpacity(0.05)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.directions_walk_rounded, color: AppTheme.green),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(walk.distanceKm == -1.0 ? 'Auto Steps' : 'Manual Entry', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Text('${walk.steps} steps', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                      Text('${walk.calories.toInt()} kcal', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.green)),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'walkLogFab',
        onPressed: () => _showManualEntry(context, state, locale),
        backgroundColor: AppTheme.green,
        icon: const Icon(Icons.sync_rounded, color: Colors.white),
        label: Text(I18n.t('sync_steps', locale), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<ActivityPeriod>(
      segments: const [
        ButtonSegment(value: ActivityPeriod.day, label: Text('Day', style: TextStyle(fontSize: 12))),
        ButtonSegment(value: ActivityPeriod.week, label: Text('Week', style: TextStyle(fontSize: 12))),
        ButtonSegment(value: ActivityPeriod.month, label: Text('Month', style: TextStyle(fontSize: 12))),
        ButtonSegment(value: ActivityPeriod.year, label: Text('Year', style: TextStyle(fontSize: 12))),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (value) {
        setState(() => _selectedPeriod = value.first);
        _fetchHistory();
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppTheme.green,
        selectedForegroundColor: Colors.white,
        side: BorderSide(color: AppTheme.green.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildRealTimeProgress(AppState state, bool isDark) {
    const goal = 10000;
    final progress = (state.totalTodaySteps / goal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.05), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: CircularPercentIndicator(
        radius: 100.0,
        lineWidth: 20.0,
        percent: progress,
        animation: true,
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: AppTheme.green,
        backgroundColor: AppTheme.green.withOpacity(0.1),
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.totalTodaySteps.toString(),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
            ),
            Text(
              I18n.t('steps', state.locale).toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary(AppState state, String locale, bool isDark) {
    int totalSteps = 0;
    double totalKcal = 0;

    if (_selectedPeriod == ActivityPeriod.day) {
      totalSteps = state.steps; // auto pedometer steps
      totalKcal = state.steps * 0.04;
      
      // Also add manually added entries for today
      for (var l in _history) {
        if (l.distanceKm != -1.0) { // -1.0 is the flag for auto steps, we only want to add manual ones
          totalSteps += l.steps;
          totalKcal += l.calories;
        }
      }
    } else {
      for (var l in _history) {
        totalKcal += l.calories;
        totalSteps += l.steps;
      }
    }
    
    double totalKm = totalSteps * 0.0008;

    return Column(
      children: [
        _buildStatCard(I18n.t('calories', locale), totalKcal.toInt().toString(), 'kcal', Icons.local_fire_department_rounded, isDark),
        const SizedBox(height: 16),
        _buildStatCard(I18n.t('distance', locale), totalKm.toStringAsFixed(1), 'km', Icons.map_rounded, isDark),
        const SizedBox(height: 16),
        _buildStatCard(I18n.t('steps', locale), totalSteps.toString(), 'steps', Icons.directions_walk_rounded, isDark),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.green.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: AppTheme.green),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 4),
                  Text(unit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showManualEntry(BuildContext context, AppState state, String locale) {
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
            Text(I18n.t('sync_steps', locale), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            TextField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.directions_walk_rounded, color: AppTheme.green),
                labelText: I18n.t('steps', locale),
                filled: true,
                fillColor: AppTheme.green.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final s = int.tryParse(stepsController.text) ?? 0;
                if (s > 0) {
                  try {
                    await state.addWalk(Walk(
                      userId: state.currentUser!.id!,
                      steps: s,
                      distanceKm: s * 0.0008,
                      calories: s * 0.04,
                      createdAt: DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute, DateTime.now().second),
                    ));
                    _fetchHistory();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Activity saved successfully!'), backgroundColor: AppTheme.green),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save activity'), backgroundColor: Colors.redAccent),
                      );
                    }
                  }
                }
              },
              child: const Text('SAVE RECORD'),
            ),
          ],
        ),
      ),
    );
  }
}
