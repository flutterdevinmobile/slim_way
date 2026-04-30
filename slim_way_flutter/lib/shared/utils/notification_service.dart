import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:easy_localization/easy_localization.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == 'drink_water') {
    await Hive.initFlutter();
    final box = await Hive.openBox('auth_box');
    int currentUnsynced = box.get('unsynced_water_ml', defaultValue: 0);
    await box.put('unsynced_water_ml', currentUnsynced + 250);

    final SendPort? sendPort = IsolateNameServer.lookupPortByName(NotificationService.portName);
    if (sendPort != null) {
      sendPort.send(250);
    }
  }
}

class NotificationService {
  static const String portName = 'water_notification_port';
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static final StreamController<int> _waterUpdateController = StreamController<int>.broadcast();
  static Stream<int> get waterUpdateStream => _waterUpdateController.stream;

  static void relayUpdate(int ml) {
    _waterUpdateController.add(ml);
  }

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'drink_water') {
          _waterUpdateController.add(250);
        }
      },
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ai_coaching_channel',
      'notification.ai_coaching'.tr(),
      channelDescription: 'notification.ai_coaching_desc'.tr(),
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> scheduleWaterReminders(int totalConsumedMl) async {
    await _notificationsPlugin.cancelAll();

    const int goalGlasses = 10;
    final now = DateTime.now();

    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final scheduleDate = now.add(Duration(days: dayOffset));
      final baseDate = DateTime(scheduleDate.year, scheduleDate.month, scheduleDate.day, 8, 0);
      
      // Only for today we use the actual consumption. For future days, we start from 0.
      final int glassesConsumed = dayOffset == 0 ? totalConsumedMl ~/ 250 : 0;
      if (glassesConsumed >= goalGlasses) continue;

      for (int i = glassesConsumed; i < goalGlasses; i++) {
        DateTime slotTime = baseDate.add(Duration(minutes: i * 80));
        if (slotTime.isAfter(now)) {
          // Unique ID: dayOffset * 1000 + i + channel_offset
          _scheduleNotificationForSlot(dayOffset * 1000 + i + 100, slotTime, isFollowUp: false);
          _scheduleNotificationForSlot(dayOffset * 1000 + i + 500, slotTime.add(const Duration(minutes: 10)), isFollowUp: true);
        }
      }
    }
  }

  static Future<void> _scheduleNotificationForSlot(int id, DateTime slotTime, {required bool isFollowUp}) async {
    final tzTime = tz.TZDateTime.from(slotTime, tz.local);

    final Int64List? vibrationPattern = isFollowUp
        ? Int64List.fromList([0, 1000, 500, 1000, 500, 1000])
        : null;

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      isFollowUp ? 'water_nagging_channel' : 'water_reminder_channel',
      isFollowUp ? 'notification.water_nag'.tr() : 'notification.water_reminder'.tr(),
      channelDescription: isFollowUp ? 'notification.water_nag_desc'.tr() : 'notification.water_reminder_desc'.tr(),
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern: vibrationPattern,
      enableVibration: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'drink_water',
          'notification.drink_action'.tr(),
          cancelNotification: true,
          showsUserInterface: false,
        ),
      ],
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      isFollowUp ? 'notification.water_nag_title'.tr() : 'notification.water_title'.tr(),
      isFollowUp ? 'notification.water_nag_body'.tr() : 'notification.water_body'.tr(),
      tzTime,
      NotificationDetails(android: androidDetails),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
