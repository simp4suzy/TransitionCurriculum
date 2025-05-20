import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';

class ProgressChart extends StatelessWidget {
  final Student student;

  const ProgressChart({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overall Progress",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ...student.skills.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Container(
                          height: 20,
                          width: (MediaQuery.of(context).size.width * 0.5) * (entry.value / 100),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Text("${entry.value}%"),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}