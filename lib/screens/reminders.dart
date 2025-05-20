import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:transition_curriculum/models/lesson.dart';

class RemindersScreen extends StatefulWidget {
  final List<Lesson> lessons;

  const RemindersScreen({required this.lessons});

  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _scheduleReminder(Lesson lesson) async {
    await _notificationsPlugin.zonedSchedule(
      lesson.id.hashCode,
      'Upcoming Lesson: ${lesson.title}',
      'Skill: ${lesson.skillCategory}',
      tz.TZDateTime.from(lesson.date, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'lesson_reminders', 'Lesson Reminders',
          channelDescription: 'Notifications for upcoming lessons'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lesson Reminders")),
      body: ListView.builder(
        itemCount: widget.lessons.length,
        itemBuilder: (ctx, index) {
          final lesson = widget.lessons[index];
          return ListTile(
            title: Text(lesson.title),
            subtitle: Text(
                '${lesson.date.toString()} • ${lesson.skillCategory}'),
            trailing: Switch(
              value: true,
              onChanged: (value) => _scheduleReminder(lesson),
            ),
          );
        },
      ),
    );
  }
}