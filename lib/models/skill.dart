class Skill {
  final String name;
  final String category; // e.g., "Life Skills", "Career Skills"
  final int progress; // 0-100 percentage

  Skill({
    required this.name,
    required this.category,
    this.progress = 0,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'progress': progress,
    };
  }

  // Create from Map (for database retrieval)
  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      name: map['name'],
      category: map['category'],
      progress: map['progress'],
    );
  }
}