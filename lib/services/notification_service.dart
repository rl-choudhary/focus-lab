import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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

  static Future<bool> isPermissionGranted() async {
    if (kIsWeb) return true;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  static Future<bool> requestPermissions() async {
    if (kIsWeb) {
      await requestWebNotificationPermission();
      return true;
    }

    await init();

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final notificationsGranted =
          await androidImplementation.requestNotificationsPermission() ?? false;
      await androidImplementation.requestExactAlarmsPermission();
      final areEnabled =
          await androidImplementation.areNotificationsEnabled() ?? false;
      return notificationsGranted || areEnabled;
    }
    return true;
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
        'Task Pending: $title ⏰',
        'This task is pending, so you need to work on it!',
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

  static Future<void> scheduleDailyEngagementNotifications() async {
    if (kIsWeb) return;
    await init();

    List<Map<String, String>> quotes = [];
    try {
      final jsonString = await rootBundle.loadString('assets/productivity_quotes.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      quotes = jsonList.map((item) => {
        'title': item['title']?.toString() ?? '',
        'subtitle': item['subtitle']?.toString() ?? '',
      }).toList();
    } catch (e) {
      debugPrint("Error loading productivity quotes: $e");
      quotes = [
        {'title': 'Consistency beats intensity.', 'subtitle': 'Take one small step forward.'},
        {'title': 'Action cures anxiety.', 'subtitle': 'Start doing today.'},
        {'title': 'Your future self will thank you.', 'subtitle': 'Spend five minutes right now.'},
      ];
    }

    final random = Random();
    final quote1 = quotes[random.nextInt(quotes.length)];
    final quote2 = quotes[random.nextInt(quotes.length)];
    final quote3 = quotes[random.nextInt(quotes.length)];

    const AndroidNotificationDetails engagementDetails = AndroidNotificationDetails(
      'engagement_channel_id',
      'Daily Motivation & Reminders',
      channelDescription: 'Calm daily reminders for morning goals, lunch check-in, and evening review',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'Focus Lab Motivation',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: engagementDetails,
      iOS: DarwinNotificationDetails(
        presentSound: true,
        presentBadge: true,
        presentAlert: true,
      ),
    );

    // 1. Morning Setup (8:00 AM)
    await _scheduleDailyTime(
      id: 8001,
      title: 'Morning Setup ☀️',
      body: '${quote1['title']} - Set your daily goals! Map out your top habits for today and kickstart your streak.',
      hour: 8,
      minute: 0,
      details: notificationDetails,
    );

    // 2. Lunch Check-in (2:00 PM / 14:00)
    await _scheduleDailyTime(
      id: 8002,
      title: 'Lunch Check-in 🥗',
      body: '${quote2['title']} - Time for a quick mid-day check-in! Keep your momentum going.',
      hour: 14,
      minute: 0,
      details: notificationDetails,
    );

    // 3. Evening Review (8:00 PM / 20:00)
    await _scheduleDailyTime(
      id: 8003,
      title: 'Evening Review 🌙',
      body: '${quote3['title']} - How did your day go? Log your completed habits now to protect your streak.',
      hour: 20,
      minute: 0,
      details: notificationDetails,
    );
  }

  static Future<void> _scheduleDailyTime({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationDetails details,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint("Error scheduling engagement notification ($id): $e");
    }
  }

  static Future<void> cancelNotification(int id) async {
    await init();
    await _notificationsPlugin.cancel(id);
  }
}
