import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/services/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Student>> _studentsFuture;
  final List<Color> _cardColors = [
    Colors.greenAccent,
    Colors.amberAccent,
    Colors.orangeAccent,
    Colors.lightBlueAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    setState(() {
      _studentsFuture = DatabaseHelper.instance.getStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          "Transition Curriculum",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 60),
                  SizedBox(height: 20),
                  Text(
                    "Error loading students",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadStudents,
                    child: Text("Try Again"),
                  ),
                ],
              ),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
            return Center(
              child: Text(
                "No students found",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final color = _cardColors[index % _cardColors.length];

              // Debug print to check student ID
              print('Dashboard: Student ${student.name} has ID: ${student.id}');

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                height: 70,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.white),
                  title: Text(
                    student.name,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    student.disability,
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.white),
                  onTap: () {
                    // Validate student has an ID before navigation
                    if (student.id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: Student data is incomplete. Please try refreshing.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pushNamed(
                      context,
                      '/profile',
                      arguments: student,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(50.10),
        child: SizedBox(
          width: double.infinity, // or a fixed width like 200
          height: 60, // set your desired height
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text("Add Student"),
            onPressed: () => _showAddStudentDialog(context),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddStudentDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final disabilityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: disabilityController,
              decoration: InputDecoration(
                labelText: "Disability",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final disability = disabilityController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter a name")),
                );
                return;
              }

              final newStudent = Student(
                name: name,
                disability: disability,
                skills: Student.defaultSkills(),
              );

              try {
                // Get the assigned ID from the database
                final assignedId = await DatabaseHelper.instance.insertStudent(newStudent);
                print('Student inserted with ID: $assignedId');
                
                _loadStudents(); // Refresh the list
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Student "$name" added successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('Error adding student: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to add student: $e")),
                );
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }
}