import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'web_notification_stub.dart' if (dart.library.html) 'web_notification_web.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    if (!kIsWeb) {
      tz.initializeTimeZones();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification clicked: ${response.payload}");
      },
    );

    _isInitialized = true;
  }

  static Future<bool> requestPermissions() async {
    if (kIsWeb) {
      await requestWebNotificationPermission();
      return true;
    }

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
      return granted ?? false;
    }
    return false;
  }

  static Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required DateTime scheduledDate,
    required TimeOfDay time,
  }) async {
    await init();

    final scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      time.hour,
      time.minute,
    );

    if (scheduledDateTime.isBefore(DateTime.now())) {
      return;
    }

    if (kIsWeb) {
      final duration = scheduledDateTime.difference(DateTime.now());
      Future.delayed(duration, () {
        debugPrint("Web Task Reminder: $title");
      });
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_channel_id',
      'Task Reminders',
      channelDescription: 'Notifications for scheduled tasks with sound and vibration',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'Task Reminder',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentBadge: true,
        presentAlert: true,
      ),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        'Task Reminder ⏰',
        title,
        tz.TZDateTime.from(scheduledDateTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  static Future<void> cancelNotification(int id) async {
    await init();
    await _notificationsPlugin.cancel(id);
  }
}
