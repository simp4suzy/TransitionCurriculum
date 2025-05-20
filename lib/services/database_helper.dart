// lib/services/database_helper.dart

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';

import '../models/student.dart';
import '../models/lesson.dart';

/// Defines common database operations for Student & Lesson entities
abstract class BaseDatabaseHelper {
  // Student CRUD
  Future<int> insertStudent(Student student);
  Future<List<Student>> getStudents();
  Future<int> updateStudent(Student student);

  // Lesson CRUD
  Future<int> insertLesson(int studentId, Lesson lesson);
  Future<List<Lesson>> getLessonsForStudent(int studentId);
}

////////////////////////////////////////////////////////////////////////////////
// MOBILE (SQLite) IMPLEMENTATION
////////////////////////////////////////////////////////////////////////////////

class MobileDatabaseHelper implements BaseDatabaseHelper {
  static sql.Database? _database;

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sql.Database> _initDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final fullPath = path.join(dbPath, 'transition_curriculum.db');

    return await sql.openDatabase(
      fullPath,
      version: 2, // bump for schema upgrade
      onCreate: (db, version) async {
        // Students table
        await db.execute('''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            disability TEXT NOT NULL,
            skills TEXT NOT NULL
          )
        ''');

        // Lessons table
        await db.execute('''
          CREATE TABLE lessons(
            id TEXT PRIMARY KEY,
            studentId INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            skillCategory TEXT NOT NULL,
            objectives TEXT,
            date TEXT NOT NULL,
            duration INTEGER,
            materials TEXT,
            completed INTEGER DEFAULT 0,
            FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          await db.execute('''
            CREATE TABLE lessons(
              id TEXT PRIMARY KEY,
              studentId INTEGER NOT NULL,
              title TEXT NOT NULL,
              description TEXT,
              skillCategory TEXT NOT NULL,
              objectives TEXT,
              date TEXT NOT NULL,
              duration INTEGER,
              materials TEXT,
              completed INTEGER DEFAULT 0,
              FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE
            )
          ''');
        }
      },
    );
  }

  // --- Student methods ---

  @override
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  @override
  Future<List<Student>> getStudents() async {
    try {
      final db = await database;
      final maps = await db.query('students');
      return maps.map((m) => Student.fromMap(m)).toList();
    } catch (e) {
      debugPrint("Error loading students: $e");
      return [];
    }
  }

  @override
  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // --- Lesson methods ---

  @override
  Future<int> insertLesson(int studentId, Lesson lesson) async {
    final db = await database;
    return await db.insert('lessons', {
      'id': lesson.id,
      'studentId': studentId,
      'title': lesson.title,
      'description': lesson.description,
      'skillCategory': lesson.skillCategory,
      'objectives': jsonEncode(lesson.objectives),
      'date': lesson.date.toIso8601String(),
      'duration': lesson.duration.inMinutes,
      'materials': jsonEncode(lesson.materials),
      'completed': lesson.completed ? 1 : 0,
    });
  }

  @override
  Future<List<Lesson>> getLessonsForStudent(int studentId) async {
    final db = await database;
    final rows = await db.query(
      'lessons',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'date ASC',
    );
    return rows.map((m) {
      return Lesson(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String? ?? '',
        skillCategory: m['skillCategory'] as String,
        objectives: List<String>.from(jsonDecode(m['objectives'] as String? ?? '[]')),
        date: DateTime.parse(m['date'] as String),
        duration: Duration(minutes: (m['duration'] as int?) ?? 0),
        materials: List<String>.from(jsonDecode(m['materials'] as String? ?? '[]')),
        completed: (m['completed'] as int? ?? 0) == 1,
      );
    }).toList();
  }
}

////////////////////////////////////////////////////////////////////////////////
// WEB (SharedPreferences) IMPLEMENTATION
////////////////////////////////////////////////////////////////////////////////

class WebDatabaseHelper implements BaseDatabaseHelper {
  static const _studentsKey = 'students_data';
  static const _lessonsKey = 'lessons_data';

  // --- Student methods ---

  @override
  Future<int> insertStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    final students = await getStudents();
    students.add(student);
    await prefs.setString(
        _studentsKey, jsonEncode(students.map((s) => s.toMap()).toList()));
    return students.length;
  }

  @override
  Future<List<Student>> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_studentsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((j) => Student.fromMap(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<int> updateStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    final students = await getStudents();
    final idx = students.indexWhere((s) => s.id == student.id);
    if (idx != -1) {
      students[idx] = student;
      await prefs.setString(
          _studentsKey, jsonEncode(students.map((s) => s.toMap()).toList()));
      return 1;
    }
    return 0;
  }

  // --- Lesson methods ---

  @override
  Future<int> insertLesson(int studentId, Lesson lesson) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lessonsKey);
    final list = raw == null ? <dynamic>[] : jsonDecode(raw) as List<dynamic>;
    list.add({
      'studentId': studentId,
      'lesson': lesson.toMap(),
    });
    await prefs.setString(_lessonsKey, jsonEncode(list));
    return list.length;
  }

  @override
  Future<List<Lesson>> getLessonsForStudent(int studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lessonsKey);
    // return a typed empty list if no lessons
    if (raw == null) return <Lesson>[];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .where((e) => e['studentId'] == studentId)
        .map<Lesson>((e) => Lesson.fromMap(e['lesson'] as Map<String, dynamic>))
        .toList();
  }
}

////////////////////////////////////////////////////////////////////////////////
// FACTORY
////////////////////////////////////////////////////////////////////////////////

class DatabaseHelper {
  static BaseDatabaseHelper get instance {
    if (kIsWeb ||
        Platform.isWindows ||
        Platform.isLinux ||
        Platform.isMacOS) {
      return WebDatabaseHelper();
    } else {
      return MobileDatabaseHelper();
    }
  }
}