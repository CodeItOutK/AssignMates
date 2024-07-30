import 'package:assignmates/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to get all teachers
    // _stream = AuthMethods().getTeachersStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello ${widget.name}'),
      ),
      body: Column(
        children: [
          // Classes in which the student is enrolled
          // The particular teacher the particular student is subscribed to
          // StreamBuilder<QuerySnapshot>(
          //   stream: _stream,
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       // Show a loading indicator while waiting for data
          //       return Center(child: CircularProgressIndicator());
          //     } else if (snapshot.hasError) {
          //       // Show an error message if something goes wrong
          //       return Center(child: Text('Error: ${snapshot.error}'));
          //     } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          //       // Show a message if there is no data available
          //       return Center(child: Text('No teachers available'));
          //     } else {
          //       final messages = snapshot.data!.docs;
          //       List<TeacherBubble> teacherList = [];
          //       for (var msg in messages) {
          //         final dynamic name = msg['name'];
          //         final dynamic branch = widget.branch;
          //         final dynamic subject = 'anonymous';
          //         TeacherBubble _bubble = TeacherBubble(name: name, subject: subject, class1: branch);
          //         if (name.toString().isNotEmpty) teacherList.add(_bubble); // Exclude empty names
          //       }
          //       return Expanded(
          //         child: ListView(
          //           children: teacherList,
          //         ),
          //       );
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}

// A frontend tile for showing info about the class-room
class TeacherBubble extends StatelessWidget {
  final dynamic name;
  final String subject;
  final dynamic class1;

  const TeacherBubble({
    Key? key,
    required this.name,
    required this.subject,
    required this.class1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Name: ',
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.brown),
              ),
              Text(
                name,
                style: TextStyle(color: Color(0xFF679289), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Subject: ',
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.brown),
              ),
              Text(
                subject,
                style: TextStyle(color: Color(0xFF679289), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class: ',
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.brown),
              ),
              Flexible(
                child: Text(
                  class1,
                  style: TextStyle(color: Color(0xFF679289), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
