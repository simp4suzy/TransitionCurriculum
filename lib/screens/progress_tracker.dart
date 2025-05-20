import 'package:flutter/material.dart';
import 'package:transition_curriculum/models/student.dart';
import 'package:transition_curriculum/models/skill.dart';
import 'package:transition_curriculum/widgets/skill_card.dart';

class ProgressTrackerScreen extends StatefulWidget {
  final Student student;

  const ProgressTrackerScreen({Key? key, required this.student}) : super(key: key);

  @override
  _ProgressTrackerScreenState createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  final List<Skill> _skills = [
    Skill(name: "Personal Hygiene", category: "Care Skills"),
    Skill(name: "Money Management", category: "Functional Academic Skills"),
    Skill(name: "Cooking", category: "Life Skills"),
    Skill(name: "Time Management", category: "Pre-Vocational Skills"),
    Skill(name: "Basic Computer Skills", category: "Livelihood Skills"),
    Skill(name: "Arts and Crafts", category: "Enrichment Skills"),
    Skill(name: "Job Interview Prep", category: "Career Skills"),
  ];

  void _updateSkillProgress(int index, int newProgress) {
    setState(() {
      _skills[index] = Skill(
        name: _skills[index].name,
        category: _skills[index].category,
        progress: newProgress,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.student.name}'s Progress"),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _skills.length,
        itemBuilder: (context, index) {
          return SkillCard(
            skill: _skills[index],
            onProgressChanged: (newProgress) {
              _updateSkillProgress(index, newProgress);
            },
          );
        },
      ),
    );
  }
}