import 'package:hive_flutter/hive_flutter.dart';
import 'package:slim_way_client/slim_way_client.dart';

abstract class SummaryLocalDataSource {
  Future<void> cacheDailySummary(DailyLog? log);
  DailyLog? getDailySummary(int userId, DateTime date);
  
  Future<void> cacheFoodLogs(List<Food> foods, int userId, DateTime date);
  List<Food> getFoodLogs(int userId, DateTime date);

  Future<void> addToSyncQueue(Map<String, dynamic> data);
  List<Map<String, dynamic>> getSyncQueue();
  Future<void> removeFromSyncQueue(int index);
}

class SummaryLocalDataSourceImpl implements SummaryLocalDataSource {
  static const String _summaryBoxName = 'summary_box';
  static const String _foodBoxName = 'food_box';
  static const String _syncQueueBoxName = 'sync_queue_box';

  static Future<void> init() async {
    await Hive.openBox(_summaryBoxName);
    await Hive.openBox(_foodBoxName);
    await Hive.openBox(_syncQueueBoxName);
  }

  Box get _summaryBox => Hive.box(_summaryBoxName);
  Box get _foodBox => Hive.box(_foodBoxName);
  Box get _syncQueueBox => Hive.box(_syncQueueBoxName);

  @override
  Future<void> cacheDailySummary(DailyLog? log) async {
    if (log == null) return;
    final key = _getSummaryKey(log.userId, log.date);
    await _summaryBox.put(key, log.toJson());
  }

  @override
  DailyLog? getDailySummary(int userId, DateTime date) {
    final key = _getSummaryKey(userId, date);
    final data = _summaryBox.get(key);
    if (data == null) return null;
    return DailyLog.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<void> cacheFoodLogs(List<Food> foods, int userId, DateTime date) async {
    final key = _getFoodKey(userId, date);
    final List<Map<String, dynamic>> data = foods.map((e) => e.toJson()).toList();
    await _foodBox.put(key, data);
  }

  @override
  List<Food> getFoodLogs(int userId, DateTime date) {
    final key = _getFoodKey(userId, date);
    final List? data = _foodBox.get(key);
    if (data == null) return [];
    return data.map((e) => Food.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> addToSyncQueue(Map<String, dynamic> data) async {
    await _syncQueueBox.add(data);
  }

  @override
  List<Map<String, dynamic>> getSyncQueue() {
    return _syncQueueBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  Future<void> removeFromSyncQueue(int index) async {
    await _syncQueueBox.deleteAt(index);
  }

  String _getSummaryKey(int userId, DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);
    return 'summary_${userId}_${d.toIso8601String()}';
  }

  String _getFoodKey(int userId, DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);
    return 'food_${userId}_${d.toIso8601String()}';
  }
}
