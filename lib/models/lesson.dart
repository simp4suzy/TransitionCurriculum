import 'dart:convert';

class Lesson {
  final String id;
  final int studentId;
  final String title;
  final String description;
  final String skillCategory;
  final List<String> objectives;
  final DateTime date;
  final Duration duration;
  final List<String> materials;
  final bool completed;

  Lesson({
    required this.id,
    required this.studentId,
    required this.title,
    required this.description,
    required this.skillCategory,
    required this.objectives,
    required this.date,
    required this.duration,
    required this.materials,
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'title': title,
      'description': description,
      'skillCategory': skillCategory,
      'objectives': objectives,
      'date': date.toIso8601String(),
      'duration': duration.inMinutes,
      'materials': materials,
      'completed': completed,
    };
  }

  static Lesson fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'] as String,
      studentId: map['studentId'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      skillCategory: map['skillCategory'] as String,
      objectives: List<String>.from(map['objectives'] as List<dynamic>),
      date: DateTime.parse(map['date'] as String),
      duration: Duration(minutes: map['duration'] as int),
      materials: List<String>.from(map['materials'] as List<dynamic>),
      completed: map['completed'] as bool,
    );
  }

  // Convert lesson to JSON string for notification payload
  String toJson() {
    try {
      final Map<String, dynamic> lessonData = {
        'id': id,
        'studentId': studentId,
        'title': title,
        'description': description,
        'skillCategory': skillCategory,
        'objectives': objectives,
        'date': date.toIso8601String(),
        'duration': duration.inMinutes,
        'materials': materials,
        'completed': completed,
      };
      return jsonEncode(lessonData);
    } catch (e) {
      // Fallback to simple string if JSON encoding fails
      return 'lesson_${id}_${title}';
    }
  }

  // Create lesson from JSON string (for notification payload parsing)
  static Lesson? fromJson(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return fromMap(data);
    } catch (e) {
      print('Error parsing lesson from JSON: $e');
      return null;
    }
  }

  Lesson copyWith({
    String? id,
    int? studentId,
    String? title,
    String? description,
    String? skillCategory,
    List<String>? objectives,
    DateTime? date,
    Duration? duration,
    List<String>? materials,
    bool? completed,
  }) {
    return Lesson(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      description: description ?? this.description,
      skillCategory: skillCategory ?? this.skillCategory,
      objectives: objectives ?? this.objectives,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      materials: materials ?? this.materials,
      completed: completed ?? this.completed,
    );
  }

  // Helper method to check if lesson is starting soon (within next 5 minutes)
  bool get isStartingSoon {
    final now = DateTime.now();
    final timeDifference = date.difference(now);
    return timeDifference.inMinutes <= 5 && timeDifference.inMinutes >= 0;
  }

  // Helper method to check if lesson is starting now (within next 2 minutes)
  bool get isStartingNow {
    final now = DateTime.now();
    final timeDifference = date.difference(now);
    return timeDifference.inMinutes <= 2 && timeDifference.inMinutes >= 0;
  }

  // Helper method to check if lesson has already started
  bool get hasStarted {
    return DateTime.now().isAfter(date);
  }

  // Helper method to check if lesson is currently active
  bool get isActive {
    final now = DateTime.now();
    final endTime = date.add(duration);
    return now.isAfter(date) && now.isBefore(endTime);
  }

  // Helper method to check if lesson is in the future
  bool get isFuture {
    return date.isAfter(DateTime.now());
  }

  // Helper method to get formatted date and time string
  String get formattedDateTime {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to get formatted time string
  String get formattedTime {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to get formatted duration string
  String get formattedDuration {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  @override
  String toString() {
    return 'Lesson{id: $id, title: $title, date: $date, skillCategory: $skillCategory}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lesson && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}