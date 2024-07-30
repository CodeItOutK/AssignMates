import 'package:flutter/material.dart';

// For a particular student, maintain the record of completed tasks
// and the tasks that need to be completed with their timelines being shown
class StudentRecords extends StatefulWidget {
  final String name;
  final String enroll;
  final String branch;
  final String email;

  const StudentRecords({
    Key? key,
    required this.name,
    required this.enroll,
    required this.branch,
    required this.email,
  }) : super(key: key);

  @override
  State<StudentRecords> createState() => _StudentRecordsState();
}

class _StudentRecordsState extends State<StudentRecords> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${widget.name}'),
      ),
      body: Center(
        child: Text('Student history screen'),
      ),
    );
  }
}
