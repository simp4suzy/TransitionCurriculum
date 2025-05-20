// lib/screens/reminders.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:transition_curriculum/models/lesson.dart';
import 'package:transition_curriculum/services/notification_service.dart';

class RemindersScreen extends StatefulWidget {
  final List<Lesson> lessons;

  const RemindersScreen({Key? key, required this.lessons}) : super(key: key);

  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final NotificationService _notifService = NotificationService();
  List<PendingNotificationRequest> _pending = [];

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final list = await _notifService.getScheduledNotifications();
    setState(() => _pending = list);
  }

  bool _isScheduled(Lesson lesson) {
    return _pending.any((n) => n.id == lesson.id.hashCode);
  }

  Future<void> _toggleReminder(Lesson lesson, bool turnOn) async {
    if (turnOn) {
      await _notifService.scheduleLessonReminder(lesson);
    } else {
      await _notifService.cancelReminder(lesson.id.hashCode);
    }
    await _loadPending();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lessons.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Lesson Reminders")),
        body: Center(child: Text("No lessons planned yet.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Lesson Reminders")),
      body: ListView.builder(
        itemCount: widget.lessons.length,
        itemBuilder: (ctx, i) {
          final lesson = widget.lessons[i];
          final scheduled = _isScheduled(lesson);

          return ListTile(
            title: Text(lesson.title),
            subtitle: Text(
              '${lesson.date.toLocal()} • ${lesson.skillCategory}',
            ),
            trailing: Switch(
              value: scheduled,
              onChanged: (on) => _toggleReminder(lesson, on),
            ),
          );
        },
      ),
    );
  }
}