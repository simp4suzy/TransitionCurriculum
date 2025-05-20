import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';
import '../models/student.dart';

abstract class BaseDatabaseHelper {
  Future<int> insertStudent(Student student);
  Future<List<Student>> getStudents();
}

// Mobile implementation (SQLite)
class MobileDatabaseHelper implements BaseDatabaseHelper {
  static sql.Database? _database;

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sql.Database> _initDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    final fullPath = path.join(dbPath, 'students.db');
    
    return await sql.openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            disability TEXT NOT NULL,
            skills TEXT NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  @override
  Future<List<Student>> getStudents() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('students');
      return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
    } catch (e) {
      debugPrint("Error loading students: $e");
      return [];
    }
  }
}

// Web implementation (SharedPreferences)
class WebDatabaseHelper implements BaseDatabaseHelper {
  static const _studentsKey = 'students_data';

  @override
  Future<int> insertStudent(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    final students = await getStudents();
    students.add(student);
    await prefs.setString(_studentsKey, jsonEncode(students.map((s) => s.toMap()).toList()));
    return students.length;
  }

  @override
  Future<List<Student>> getStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_studentsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Student.fromMap(json)).toList();
  }
}

// Factory to choose the right implementation
class DatabaseHelper {
  static BaseDatabaseHelper get instance {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return WebDatabaseHelper();
    } else {
      return MobileDatabaseHelper();
    }
  }
}