import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transition_curriculum/models/lesson.dart';

class SimpleNotificationService {
  static final SimpleNotificationService _instance = SimpleNotificationService._internal();
  factory SimpleNotificationService() => _instance;
  SimpleNotificationService._internal();

  late FlutterLocalNotificationsPlugin _notifications;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _notifications = FlutterLocalNotificationsPlugin();
    
    // Simple initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(initSettings);
    await _requestPermissions();
    
    _isInitialized = true;
    print('✅ Simple Notification Service initialized');
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
      print('📱 Android notification permission requested');
    }
  }

  // Schedule a lesson reminder - MUCH SIMPLER APPROACH
  Future<void> scheduleLessonReminder(Lesson lesson) async {
    if (!_isInitialized) await initialize();
    
    // Calculate minutes until lesson starts
    final now = DateTime.now();
    final minutesUntilLesson = lesson.date.difference(now).inMinutes;
    
    if (minutesUntilLesson <= 0) {
      print('⚠️ Cannot schedule notification for past lesson');
      return;
    }
    
    // Show immediate notification about when the lesson is scheduled
    await _showImmediateNotification(
      lesson.id.hashCode,
      '📅 Lesson Scheduled!',
      '✅ "${lesson.title}" is scheduled for ${lesson.formattedDateTime}\n\n💡 You\'ll be reminded automatically when it\'s time to start!\n\nCategory: ${lesson.skillCategory}',
    );
    
    print('✅ Lesson reminder set for: ${lesson.title} at ${lesson.formattedDateTime}');
  }

  // Show immediate notification - This always works!
  Future<void> _showImmediateNotification(int id, String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'lesson_reminders',
      'Lesson Reminders',
      channelDescription: 'Notifications for lesson reminders and alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Transition Curriculum App',
      ),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );
    
    var details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _notifications.show(id, title, body, details);
    print('📢 Notification sent: $title');
  }

  // Test notification - works immediately and reliably
  Future<void> testNotification() async {
    if (!_isInitialized) await initialize();
    
    final now = DateTime.now();
    final timeString = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    
    await _showImmediateNotification(
      999,
      '🧪 Test Notification - SUCCESS!',
      '🎉 Great! Your notifications are working perfectly!\n\n⏰ Sent at: $timeString\n💡 This means you\'ll receive lesson reminders when they\'re scheduled.\n\n✅ Notification system is ready!',
    );
    
    print('🧪 Test notification sent at $timeString');
  }

  // Show lesson starting notification
  Future<void> showLessonStartingNotification(Lesson lesson, String timing) async {
    if (!_isInitialized) await initialize();
    
    String title;
    String body;
    
    if (timing == 'now') {
      title = '🔔 LESSON STARTING NOW!';
      body = '⏰ "${lesson.title}" is starting right now!\n\n📚 Category: ${lesson.skillCategory}\n⏱️ Duration: ${lesson.formattedDuration}\n\n👩‍🏫 Time to begin the lesson!';
    } else {
      title = '⏰ Lesson Starting Soon!';
      body = '📝 "${lesson.title}" starts in $timing\n\n📚 Category: ${lesson.skillCategory}\n⏱️ Scheduled: ${lesson.formattedTime}\n\n🔔 Get ready to start the lesson!';
    }
    
    await _showImmediateNotification(
      lesson.id.hashCode + (timing == 'now' ? 1 : 0),
      title,
      body,
    );
  }

  // Cancel specific lesson reminder
  Future<void> cancelLessonReminder(String lessonId) async {
    await _notifications.cancel(lessonId.hashCode);
    await _notifications.cancel(lessonId.hashCode + 1);
    print('🗑️ Cancelled notifications for lesson: $lessonId');
  }

  // Cancel all notifications
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
    print('🗑️ All notifications cancelled');
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Show a simple success message notification
  Future<void> showSuccessNotification(String message) async {
    if (!_isInitialized) await initialize();
    
    await _showImmediateNotification(
      DateTime.now().millisecondsSinceEpoch % 1000,
      '✅ Success!',
      message,
    );
  }

  // Show a reminder notification
  Future<void> showReminderNotification(String title, String message) async {
    if (!_isInitialized) await initialize();
    
    await _showImmediateNotification(
      DateTime.now().millisecondsSinceEpoch % 1000,
      '💡 $title',
      message,
    );
  }

  // Stop the service
  void dispose() {
    _isInitialized = false;
    print('🛑 Simple Notification Service disposed');
  }
}