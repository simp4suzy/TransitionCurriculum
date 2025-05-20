import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/screens/progress_tracker.dart';

class StudentProfileScreen extends StatelessWidget {
  final Student student;

  const StudentProfileScreen({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(student.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProgressTrackerScreen(student: student),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Disability: ${student.disability}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("Skills Progress:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ...student.skills.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${entry.key} (${entry.value}%)"),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / 100,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}