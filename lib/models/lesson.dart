class Lesson {
  final String id;
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
    required this.title,
    required this.description,
    required this.skillCategory,
    required this.objectives,
    required this.date,
    required this.duration,
    required this.materials,
    this.completed = false, int? studentId,
  });

  toMap() {}

  static fromMap(Map<String, dynamic> e) {}
}