import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/shared/presentation/theme/theme.dart';
import 'package:slim_way_flutter/shared/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:slim_way_flutter/features/home/presentation/blocs/summary_bloc/summary_bloc.dart';
import 'package:slim_way_flutter/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:slim_way_flutter/features/food/presentation/blocs/food_bloc/food_bloc.dart';

enum HistoryPeriod { day, week, month, year }

class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  HistoryPeriod _selectedPeriod = HistoryPeriod.day;
  DateTime _referenceDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.whenOrNull(authenticated: (u) => u.id);
    if (userId == null) return;

    DateTime start;
    DateTime end = DateTime(_referenceDate.year, _referenceDate.month, _referenceDate.day, 23, 59, 59);

    switch (_selectedPeriod) {
      case HistoryPeriod.day:
        start = DateTime(_referenceDate.year, _referenceDate.month, _referenceDate.day);
        break;
      case HistoryPeriod.week:
        start = _referenceDate.subtract(Duration(days: _referenceDate.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case HistoryPeriod.month:
        start = DateTime(_referenceDate.year, _referenceDate.month, 1);
        break;
      case HistoryPeriod.year:
        start = DateTime(_referenceDate.year, 1, 1);
        break;
    }

    context.read<FoodBloc>().add(FoodHistoryRequested(
          userId: userId,
          start: start.toUtc(),
          end: end.toUtc(),
        ));
  }

  Future<void> _deleteEntry(int foodId) async {
    context.read<SummaryBloc>().add(FoodDeleted(foodId));
    // refresh after delete
    _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return BlocBuilder<FoodBloc, FoodState>(
          builder: (context, foodState) {
            final history = foodState.maybeWhen(
              success: (foods, _) => foods,
              orElse: () => <Food>[],
            );
            final isLoading = foodState is FoodPrepare;

            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text('common.history'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
              body: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildPeriodSelector(),
                  const SizedBox(height: 24),
                  _buildSummaryStats(history),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppTheme.green,
                      onRefresh: () async => _fetchHistory(),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.green))
                          : history.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  itemCount: history.length,
                                  itemBuilder: (context, index) => _buildFoodItem(history[index], isDark),
                                ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SegmentedButton<HistoryPeriod>(
        segments: [
          ButtonSegment(value: HistoryPeriod.day, label: Text('common.day'.tr(), style: const TextStyle(fontSize: 12))),
          ButtonSegment(value: HistoryPeriod.week, label: Text('common.week'.tr(), style: const TextStyle(fontSize: 12))),
          ButtonSegment(value: HistoryPeriod.month, label: Text('common.month'.tr(), style: const TextStyle(fontSize: 12))),
          ButtonSegment(value: HistoryPeriod.year, label: Text('common.year'.tr(), style: const TextStyle(fontSize: 12))),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (value) {
          setState(() => _selectedPeriod = value.first);
          _fetchHistory();
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppTheme.green,
          selectedForegroundColor: Colors.white,
          side: BorderSide(color: AppTheme.green.withValues(alpha: 0.1)),
        ),
      ),
    );
  }

  Widget _buildSummaryStats(List<Food> history) {
    double total = history.fold(0, (sum, item) => sum + item.calories);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            'food.total'.tr(namedArgs: {'amount': total.toInt().toString(), 'unit': 'food.unit_kcal'.tr()}),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const Spacer(),
          Text(
            'food.items'.tr(namedArgs: {'count': history.length.toString()}),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Food food, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkGray : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildFoodImage(food.photoUrl),
        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('MMM d, HH:mm').format(food.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${food.calories.toInt()} ${'food.unit_kcal'.tr()}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.green)),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteEntry(food.id!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImage(String? photoUrl) {
    if (photoUrl == null) {
      return Container(
        width: 50, height: 50,
        decoration: BoxDecoration(color: AppTheme.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.restaurant, color: AppTheme.green, size: 20),
      );
    }
    return Container(
      width: 50, height: 50,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('food.no_logs'.tr(), style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
