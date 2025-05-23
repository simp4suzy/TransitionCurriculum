import 'dart:async';
import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/models/lesson.dart';
import 'package:transition_curriculum/services/database_helper.dart';
import 'package:transition_curriculum/services/simple_notification_service.dart';
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

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = skillCategories.first;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  Duration _selectedDuration = lessonDurations[1];

  Timer? _countdownTimer;
  Timer? _lessonChecker;

  @override
  void initState() {
    super.initState();
    _loadLessons();
    _startCountdownTimer();
    _initializeNotifications();
    _startLessonChecker();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _countdownTimer?.cancel();
    _lessonChecker?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      await SimpleNotificationService().initialize();
      print('✅ Notification service initialized');
    } catch (e) {
      print('❌ Failed to initialize notifications: $e');
    }
  }

  void _startLessonChecker() {
    _lessonChecker = Timer.periodic(Duration(minutes: 1), (_) {
      _checkForUpcomingLessons();
    });
  }

  void _checkForUpcomingLessons() {
    final now = DateTime.now();
    
    for (final lesson in _lessons) {
      final minutesUntil = lesson.date.difference(now).inMinutes;
      
      if (minutesUntil == 5) {
        _showLessonNotification(lesson, '5 minutes');
      }
      
      if (minutesUntil == 0) {
        _showLessonNotification(lesson, 'now');
      }
    }
  }

  Future<void> _showLessonNotification(Lesson lesson, String timing) async {
    await SimpleNotificationService().showLessonStartingNotification(lesson, timing);

    if (mounted) {
      _showInAppLessonAlert(lesson, timing);
    }
  }

  void _showInAppLessonAlert(Lesson lesson, String timing) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: timing == 'now' ? Colors.red[50] : Colors.orange[50],
        title: Row(
          children: [
            Icon(
              timing == 'now' ? Icons.alarm : Icons.access_time,
              color: timing == 'now' ? Colors.red : Colors.orange,
              size: 30,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                timing == 'now' ? 'LESSON STARTING NOW!' : 'LESSON STARTING SOON!',
                style: TextStyle(
                  color: timing == 'now' ? Colors.red : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Category: ${lesson.skillCategory}'),
            Text('Time: ${lesson.formattedTime}'),
            Text('Duration: ${lesson.formattedDuration}'),
            if (timing != 'now') 
              Text(
                'Starting in $timing',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          if (timing != 'now')
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('REMIND LATER'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: timing == 'now' ? Colors.red : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('GOT IT!'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return "$h:${twoDigits(m)}:${twoDigits(s)}";
    return "${twoDigits(m)}:${twoDigits(s)}";
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadLessons() async {
    print('Loading lessons for student: ${widget.student.name} (ID: ${widget.student.id})');
    setState(() => _loading = true);

    final sid = widget.student.id;
    if (sid != null) {
      try {
        final existing = await DatabaseHelper.instance.getLessonsForStudent(sid);
        print('Successfully loaded ${existing.length} lessons from database');

        if (mounted) {
          setState(() {
            _lessons = existing;
            _loading = false;
          });
        }

        for (var lesson in existing) {
          print('Lesson: ${lesson.title} - ${lesson.date} - ${lesson.skillCategory}');
        }

      } catch (e) {
        print('Error loading lessons: $e');
        if (mounted) {
          setState(() {
            _lessons = [];
            _loading = false;
          });
        }
      }
    } else {
      print('Student ID is null, cannot load lessons');
      if (mounted) {
        setState(() {
          _lessons = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _showAddLessonDialog() async {
    _titleController.clear();
    _descController.clear();
    _selectedCategory = skillCategories.first;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedDuration = lessonDurations[1];

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDState) {
        return AlertDialog(
          title: Text("Plan New Lesson for ${widget.student.name}"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Lesson Title",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? "Title is required" : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: "Description (Optional)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: "Skill Category",
                    border: OutlineInputBorder(),
                  ),
                  items: skillCategories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (v) => setDState(() => _selectedCategory = v!),
                ),
                SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text("Date"),
                    subtitle: Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text("Time"),
                    subtitle: Text(_selectedTime.format(ctx)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: _selectedTime,
                      );
                      if (picked != null) {
                        setDState(() => _selectedTime = picked);
                      }
                    },
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<Duration>(
                  value: _selectedDuration,
                  decoration: InputDecoration(
                    labelText: "Duration",
                    border: OutlineInputBorder(),
                  ),
                  items: lessonDurations
                      .map((dur) => DropdownMenuItem(
                          value: dur, child: Text(dur.toFormattedString())))
                      .toList(),
                  onChanged: (v) => setDState(() => _selectedDuration = v!),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  print('Form validation failed');
                  return;
                }

                final sid = widget.student.id;
                if (sid == null) {
                  print('Student ID is null, cannot save lesson');
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: Student ID is missing'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final lessonDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );

                final lessonId = 'lesson_${DateTime.now().millisecondsSinceEpoch}_${sid}';
                final newLesson = Lesson(
                  id: lessonId,
                  studentId: sid,
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  skillCategory: _selectedCategory,
                  objectives: [],
                  date: lessonDateTime,
                  duration: _selectedDuration,
                  materials: [],
                  completed: false,
                );

                print('Creating lesson: ${newLesson.title} for student $sid at ${newLesson.date}');

                try {
                  showDialog(
                    context: ctx,
                    barrierDismissible: false,
                    builder: (c) => Center(child: CircularProgressIndicator()),
                  );

                  final success = await DatabaseHelper.instance.insertLesson(sid, newLesson);
                  print('Lesson insertion result: $success');

                  if (success) {
                    try {
                      await SimpleNotificationService().scheduleLessonReminder(newLesson);
                      print('✅ Notification scheduled successfully for lesson: ${newLesson.title}');
                    } catch (notificationError) {
                      print('Warning: Could not schedule notification: $notificationError');
                    }

                    Navigator.pop(ctx);
                    Navigator.pop(ctx);
                    await _loadLessons();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Lesson "${newLesson.title}" has been scheduled!\nYou\'ll be notified when it\'s time to start.'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  } else {
                    Navigator.pop(ctx);
                    throw Exception('Database insertion returned false');
                  }

                } catch (e) {
                  print('Error saving lesson: $e');

                  if (Navigator.canPop(ctx)) {
                    Navigator.pop(ctx);
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save lesson: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: Text("Save Lesson"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text("Lesson Planner for ${widget.student.name}"),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active),
            onPressed: () async {
              await SimpleNotificationService().testNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🧪 Test notification sent! Check your notification panel.'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            tooltip: "Test Notifications",
          ),
          IconButton(
            icon: Icon(Icons.alarm),
            onPressed: () {
              _showAlarmInfo();
            },
            tooltip: "Notification Info",
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              print('Manual refresh triggered');
              _loadLessons();
            },
            tooltip: "Refresh lessons",
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading lessons...'),
                ],
              ),
            )
          : _lessons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No lessons planned yet for ${widget.student.name}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text("Plan First Lesson"),
                        onPressed: _showAddLessonDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLessons,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _lessons.length,
                    itemBuilder: (ctx, i) {
                      final lesson = _lessons[i];
                      final now = DateTime.now();
                      final lessonStart = lesson.date;
                      final lessonEnd = lesson.date.add(lesson.duration);

                      String countdownText;
                      Color countdownColor = Colors.deepPurple;
                      
                      if (now.isBefore(lessonStart)) {
                        final diff = lessonStart.difference(now);
                        countdownText = "Starts in ${_formatDuration(diff)}";
                        
                        if (diff.inMinutes <= 5) {
                          countdownColor = Colors.red;
                          countdownText = "⚠️ STARTING SOON! " + countdownText;
                        } else if (diff.inMinutes <= 30) {
                          countdownColor = Colors.orange;
                        }
                      } else if (now.isAfter(lessonEnd)) {
                        countdownText = "✅ Completed";
                        countdownColor = Colors.green;
                      } else {
                        final diff = lessonEnd.difference(now);
                        countdownText = "🔴 ACTIVE - Ends in ${_formatDuration(diff)}";
                        countdownColor = Colors.red;
                      }

                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LessonCard(
                              lesson: lesson,
                              student: widget.student,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text(
                                countdownText,
                                style: TextStyle(
                                  color: countdownColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddLessonDialog,
        tooltip: "Plan new lesson",
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAlarmInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: Colors.blue),
            SizedBox(width: 8),
            Text("Lesson Notifications"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How notifications work:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text("• 📱 You'll get a notification when you schedule a lesson"),
            Text("• ⏰ Reminder 5 minutes before lesson starts"),
            Text("• 🔔 Alert when lesson starts"),
            Text("• 💡 Works even when app is closed"),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.science), // Changed from test_tube to science
              label: Text("Test Notification"),
              onPressed: () async {
                Navigator.pop(ctx);
                await SimpleNotificationService().testNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🧪 Test notification sent!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Got it!"),
          ),
        ],
      ),
    );
  }
}