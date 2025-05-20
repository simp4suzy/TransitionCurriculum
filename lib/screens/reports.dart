import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';

class ReportsScreen extends StatelessWidget {
  final Student student;

  const ReportsScreen({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${student.name}'s Reports"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Progress Summary",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 20),
            ...student.skills.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(entry.key),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: entry.value / 100,
                        backgroundColor: Colors.grey[200],
                        color: Colors.blue,
                        minHeight: 10,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text("${entry.value}%"),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement PDF generation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Generating PDF report...")),
                );
              },
              child: Text("Generate PDF Report"),
            ),
          ],
        ),
      ),
    );
  }
}