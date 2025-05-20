import 'package:flutter/material.dart';
import 'package:transition_curriculum/screens/dashboard.dart';
import 'package:transition_curriculum/screens/progress_tracker.dart';
import 'package:transition_curriculum/screens/reports.dart';
import 'package:transition_curriculum/screens/student_profile.dart';
import 'package:transition_curriculum/models/student.dart';

void main() {
  runApp(TransitionCurriculumApp());
}

class TransitionCurriculumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transition Curriculum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => DashboardScreen(),
        '/profile': (context) {
          final student = ModalRoute.of(context)!.settings.arguments as Student;
          return StudentProfileScreen(student: student);
        },
        '/progress': (context) {
          final student = ModalRoute.of(context)!.settings.arguments as Student;
          return ProgressTrackerScreen(student: student);
        },
        '/reports': (context) {
          final student = ModalRoute.of(context)!.settings.arguments as Student;
          return ReportsScreen(student: student);
        },
      },
    );
  }
}