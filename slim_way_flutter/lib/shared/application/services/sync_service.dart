import 'dart:async';
import 'package:slim_way_client/slim_way_client.dart';
import 'package:slim_way_flutter/features/home/data/datasources/summary_local_data_source.dart';
import 'package:slim_way_flutter/shared/application/utils/safe_call.dart';
import 'package:slim_way_flutter/shared/utils/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';


class SyncService {
  final Client client;
  final SummaryLocalDataSource localDataSource;
  Timer? _timer;
  bool _isSyncing = false;

  SyncService({
    required this.client,
    required this.localDataSource,
  });

  void startAutoSync() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (_) => syncPendingData());
  }

  void stopAutoSync() {
    _timer?.cancel();
  }

  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final queue = localDataSource.getSyncQueue();
      if (queue.isEmpty) return;

      for (int i = 0; i < queue.length; i++) {
        final item = queue[i];
        final type = item['type'];

        bool success = false;
        if (type == 'water') {
          success = await _syncWater(item);
        } else if (type == 'food') {
          success = await _syncFood(item);
        }

        if (success) {
          await localDataSource.removeFromSyncQueue(i);
        }
      }
      
      // AI Pro-active coaching: Get insight if we just synced
      if (queue.isNotEmpty) {
        _getAiProactiveAdvice();
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _getAiProactiveAdvice() async {
    // 1. Get current stats
    final now = DateTime.now();
    final logRes = await safeCall(() => client.stats.getDailySummary(0, now)); 
    
    logRes.when(
      success: (log) async {
        if (log == null) return;
        
        // 2. Ask AI for a quick motivational tip based on this log using localized prompt
        final prompt = 'ai.prompt_advice'.tr(namedArgs: {
          'cal': log.foodCal.toStringAsFixed(0),
          'water': log.waterMl.toString(),
        });
        
        final advice = await safeCall(() => client.ai.chatWithAi([], prompt, dailyLog: log));
        
        advice.when(
          success: (text) {
             NotificationService.showNotification(
                id: 999,
                title: 'ai.coach_title'.tr(),
                body: text,
             );
          },
          failure: (_) {},
        );

      },
      failure: (_) {},
    );
  }

  Future<bool> _syncWater(Map<String, dynamic> item) async {

    final res = await safeCall(() => client.water.addWater(
      item['userId'],
      item['amount'],
      DateTime.parse(item['date']),
    ));
    return res.isSuccess;
  }

  Future<bool> _syncFood(Map<String, dynamic> item) async {
    // Implement food sync if needed
    return false;
  }
}
