// lib/main.dart
import 'package:flutter/material.dart';
import 'package:transition_curriculum/screens/dashboard.dart';
import 'package:transition_curriculum/screens/student_profile.dart';
import 'package:transition_curriculum/screens/progress_tracker.dart';
import 'package:transition_curriculum/screens/reports.dart';
import 'package:transition_curriculum/screens/lesson_planner.dart';
import 'package:transition_curriculum/screens/reminders.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/models/lesson.dart';
import 'package:transition_curriculum/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(TransitionCurriculumApp());
}

class TransitionCurriculumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transition Curriculum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (c) => DashboardScreen(),
        '/profile': (c) {
          final student = ModalRoute.of(c)!.settings.arguments as Student;
          return StudentProfileScreen(student: student);
        },
        '/progress': (c) {
          final student = ModalRoute.of(c)!.settings.arguments as Student;
          return ProgressTrackerScreen(student: student);
        },
        '/reports': (c) {
          final student = ModalRoute.of(c)!.settings.arguments as Student;
          return ReportsScreen(student: student);
        },
        '/lesson_planner': (c) {
          final student = ModalRoute.of(c)!.settings.arguments as Student;
          return LessonPlannerScreen(student: student);
        },
        '/reminders': (c) {
          final lessons = ModalRoute.of(c)!.settings.arguments as List<Lesson>;
          return RemindersScreen(lessons: lessons);
        },
      },
    );
  }
}