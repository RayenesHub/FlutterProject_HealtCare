import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

Future<void> init() async {
  if (_initialized) return;

  // Timezone setup
  tzdata.initializeTimeZones();

  // Handle both return types: String or TimezoneInfo
  final dynamic tzResult = await FlutterTimezone.getLocalTimezone();
  String tzName;
  if (tzResult is String) {
    tzName = tzResult;
  } else {
    // Some versions return a TimezoneInfo with a `.name` field
    try {
      tzName = (tzResult as dynamic).name as String;
    } catch (_) {
      // Safe fallback (pick what fits your app best)
      tzName = 'UTC'; // or 'Africa/Tunis'
    }
  }

  tz.setLocalLocation(tz.getLocation(tzName));

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const darwinInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );

  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: darwinInit,
  );

  await _fln.initialize(initSettings);
  _initialized = true;
}

  Future<void> requestPermissions({bool requestExactAlarm = false}) async {
    if (Platform.isIOS) {
      await _fln
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await _fln
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      if (requestExactAlarm) {
        await _fln
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestExactAlarmsPermission();
      }
    }
  }

  Future<void> scheduleInactivityReminder(Duration delay) async {
    const id = 1001;
    final when = tz.TZDateTime.now(tz.local).add(delay);

    const android = AndroidNotificationDetails(
      'engagement_channel',
      'Engagement',
      channelDescription: 'Reminders to re-open the app',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();

    await _fln.zonedSchedule(
      id,
      'We miss you 👋',
      'Open WellCare to continue where you left off.',
      when,
      const NotificationDetails(android: android, iOS: ios),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // NOTE: No uiLocalNotificationDateInterpretation in v19+
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelReminder() => _fln.cancel(1001);
  Future<void> cancelAll() => _fln.cancelAll();
}
