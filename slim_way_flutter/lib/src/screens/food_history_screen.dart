import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:slim_way_client/slim_way_client.dart';
import '../../main.dart';
import '../providers/app_state.dart';
import '../theme.dart';
import '../utils/i18n.dart';

enum HistoryPeriod { day, week, month, year }

class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  HistoryPeriod _selectedPeriod = HistoryPeriod.day;
  DateTime _referenceDate = DateTime.now();
  List<Food> _history = [];
  bool _isLoading = true;

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

      final logs = await client.food.getFoodHistory(
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

  Future<void> _deleteEntry(int foodId) async {
    final state = context.read<AppState>();
    await state.deleteFood(foodId);
    _fetchHistory(); 
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locale = state.locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(I18n.t('nutrition', locale), style: const TextStyle(fontWeight: FontWeight.bold)),
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
          _buildPeriodSelector(locale),
          const SizedBox(height: 24),
          _buildSummaryStats(isDark),
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.green,
              onRefresh: _fetchHistory,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.green))
                  : _history.isEmpty
                      ? _buildEmptyState(locale)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: _history.length,
                          itemBuilder: (context, index) => _buildFoodItem(_history[index], isDark),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(String locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SegmentedButton<HistoryPeriod>(
        segments: const [
          ButtonSegment(value: HistoryPeriod.day, label: Text('Day', style: TextStyle(fontSize: 12))),
          ButtonSegment(value: HistoryPeriod.week, label: Text('Week', style: TextStyle(fontSize: 12))),
          ButtonSegment(value: HistoryPeriod.month, label: Text('Month', style: TextStyle(fontSize: 12))),
          ButtonSegment(value: HistoryPeriod.year, label: Text('Year', style: TextStyle(fontSize: 12))),
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
      ),
    );
  }

  Widget _buildSummaryStats(bool isDark) {
    double total = _history.fold(0, (sum, item) => sum + item.calories);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            'Total: ${total.toInt()} kcal',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const Spacer(),
          Text(
            '${_history.length} items',
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildFoodImage(food.photoUrl),
        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(DateFormat('MMM d, HH:mm').format(food.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${food.calories.toInt()} kcal', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.green)),
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
        decoration: BoxDecoration(color: AppTheme.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
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

  Widget _buildEmptyState(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(I18n.t('no_logs', locale), style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
