import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class SceneNotificationService {
  SceneNotificationService._();

  static final SceneNotificationService instance = SceneNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> scheduleSceneReminder({
    required int secondsFromNow,
  }) async {
    if (secondsFromNow <= 0) return;

    await _plugin.zonedSchedule(
      id: 1001,
      title: 'Scene completed',
      body: 'Return to Vocabify to continue your quiz.',
      scheduledDate:
          tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsFromNow)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'scene_reminder_channel',
          'Scene Reminders',
          channelDescription: 'Reminds users to return after watching a scene.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelSceneReminder() async {
    await _plugin.cancel(id: 1001);
  }
}