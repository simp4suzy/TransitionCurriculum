import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/models/lesson.dart';
import 'package:transition_curriculum/utils/constants.dart';
import 'package:transition_curriculum/widgets/lesson_card.dart';

class LessonPlannerScreen extends StatefulWidget {
  final Student student;
  
  const LessonPlannerScreen({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  _LessonPlannerScreenState createState() => _LessonPlannerScreenState();
}

class _LessonPlannerScreenState extends State<LessonPlannerScreen> {
  final List<Lesson> _lessons = [];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = skillCategories[0];
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lesson Planner for ${widget.student.name}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _lessons.length,
                itemBuilder: (ctx, index) => LessonCard(
                  lesson: _lessons[index],
                  student: widget.student, // Pass student to each lesson card
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddLessonDialog(context),
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Plan New Lesson for ${widget.student.name}"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ... (rest of your dialog code remains the same)
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newLesson = Lesson(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  studentId: widget.student.id, // Associate with student
                  title: _titleController.text,
                  description: _descController.text,
                  skillCategory: _selectedCategory,
                  objectives: [],
                  date: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  ),
                  duration: Duration(hours: 1),
                  materials: [],
                );
                setState(() => _lessons.add(newLesson));
                Navigator.pop(context);
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}