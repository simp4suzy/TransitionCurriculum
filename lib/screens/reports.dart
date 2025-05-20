import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:transition_curriculum/models/student.dart';

class ReportsScreen extends StatelessWidget {
  final Student student;

  const ReportsScreen({Key? key, required this.student}) : super(key: key);

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'Student Progress Report'),
              pw.Text('Name: ${student.name}'),
              pw.Text('Disability: ${student.disability}'),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, text: 'Skills Progress'),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Skill', 'Progress'],
                  ...student.skills.entries.map((e) => [e.key, '${e.value}%']),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Generated on: ${DateTime.now().toLocal().toString()}'),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${student.name}'s Reports"),
      ),
      body: PdfPreview(
        useActions: true,
        canChangeOrientation: false,
        build: (PdfPageFormat format) async {
          final doc = await _generatePdf();
          return doc.save();
        },
      ),
    );
  }
}