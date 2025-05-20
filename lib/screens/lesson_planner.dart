// lib/screens/lesson_planner.dart

import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/models/lesson.dart';
import 'package:transition_curriculum/services/database_helper.dart';
import 'package:transition_curriculum/services/notification_service.dart';
import 'package:transition_curriculum/utils/constants.dart';
import 'package:transition_curriculum/widgets/lesson_card.dart';

class LessonPlannerScreen extends StatefulWidget {
  final Student student;
  const LessonPlannerScreen({Key? key, required this.student}) : super(key: key);

  @override
  _LessonPlannerScreenState createState() => _LessonPlannerScreenState();
}

class _LessonPlannerScreenState extends State<LessonPlannerScreen> {
  List<Lesson> _lessons = [];
  bool _loading = true;

  // Form state
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = skillCategories.first;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Duration _selectedDuration = lessonDurations[1];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    // Load existing lessons from DB (if any)
    final sid = widget.student.id;
    if (sid != null) {
      final existing = await DatabaseHelper.instance.getLessonsForStudent(sid);
      setState(() {
        _lessons = existing;
        _loading = false;
      });
    } else {
      setState(() {
        _lessons = [];
        _loading = false;
      });
    }
  }

  Future<void> _showAddLessonDialog() async {
    // Reset form fields
    _titleController.clear();
    _descController.clear();
    _selectedCategory = skillCategories.first;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedDuration = lessonDurations[1];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDState) {
        return AlertDialog(
          title: Text("Plan New Lesson for ${widget.student.name}"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Lesson Title"),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Required" : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(labelText: "Description"),
                  maxLines: 2,
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: skillCategories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (v) => setDState(() => _selectedCategory = v!),
                  decoration: InputDecoration(labelText: "Skill Category"),
                ),
                SizedBox(height: 12),
                ListTile(
                  title: Text(
                    "Date: ${_selectedDate.toLocal().toIso8601String().split('T').first}",
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) setDState(() => _selectedDate = picked);
                  },
                ),
                ListTile(
                  title: Text("Time: ${_selectedTime.format(ctx)}"),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: _selectedTime,
                    );
                    if (picked != null) setDState(() => _selectedTime = picked);
                  },
                ),
                DropdownButtonFormField<Duration>(
                  value: _selectedDuration,
                  items: lessonDurations
                      .map((dur) => DropdownMenuItem(
                          value: dur, child: Text(dur.toFormattedString())))
                      .toList(),
                  onChanged: (v) => setDState(() => _selectedDuration = v!),
                  decoration: InputDecoration(labelText: "Duration"),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;

                final sid = widget.student.id;
                if (sid == null) {
                  Navigator.pop(ctx);
                  return;
                }

                final lessonDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );

                final newLesson = Lesson(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  studentId: sid,
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  skillCategory: _selectedCategory,
                  objectives: [],
                  date: lessonDateTime,
                  duration: _selectedDuration,
                  materials: [],
                );

                // Immediately show in UI
                setState(() => _lessons.add(newLesson));

                // Persist & schedule in background
                DatabaseHelper.instance.insertLesson(sid, newLesson);
                NotificationService().scheduleLessonReminder(newLesson);

                Navigator.pop(ctx);
              },
              child: Text("Save"),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lesson Planner for ${widget.student.name}"),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? Center(child: Text("No lessons planned yet."))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _lessons.length,
                  itemBuilder: (ctx, i) => LessonCard(
                    lesson: _lessons[i],
                    student: widget.student,
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddLessonDialog,
      ),
    );
  }
}