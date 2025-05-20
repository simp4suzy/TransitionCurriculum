import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:transition_curriculum/models/lesson.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tzData.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<void> scheduleLessonReminder(Lesson lesson) async {
    await _notificationsPlugin.zonedSchedule(
      lesson.id.hashCode,
      'Upcoming Lesson: ${lesson.title}',
      'Starts at ${lesson.date.hour}:${lesson.date.minute.toString().padLeft(2, '0')}',
      tz.TZDateTime.from(lesson.date.subtract(Duration(minutes: 15)), tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lesson_reminders',
          'Lesson Reminders',
          channelDescription: 'Notifications for upcoming lessons',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getScheduledNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}