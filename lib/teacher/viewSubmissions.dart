//dedline->
import 'dart:io';
import 'package:assignmates/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:assignmates/models/student.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class ViewSubmissions extends StatefulWidget {
  final dynamic assignId;
  final dynamic title;

  const ViewSubmissions({
    Key? key,
    required this.assignId,
    required this.title,
  }) : super(key: key);

  const ViewSubmissions.defaultConstructor({Key? key})
      : assignId = null,
        title = null,
        super(key: key);

  @override
  State<ViewSubmissions> createState() => _ViewSubmissionsState();
}

class _ViewSubmissionsState extends State<ViewSubmissions> {
  late Stream<QuerySnapshot> stream;

  @override
  void initState() {
    super.initState();
    stream = AuthMethods().getDoneAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(13),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color:  Color(0xFFB182ED).withOpacity(0.7),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.arrow_back_ios, color: Color(0xFF7EDCBE), size: 18),
              ),
            ),
          ),
        ),
        title: Text(
          "${widget.title}",
          style: TextStyle(color:Color(0xFFB182ED).withOpacity(0.9), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF7EDCBE),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Color(0xFF7EDCBE),
              ),
            );
          }

          final messages = snapshot.data!.docs;
          List<SubmissionsBubble> allMessages = [];
          final String currentTeacher = AuthMethods().getCurrentUser();

          for (var msg in messages) {
            final String assId1 = msg.id;
            final List<dynamic> submissions = msg['submissions'];
            for (var submission in submissions) {
              final dynamic teacherId = submission['teacherId'];
              final dynamic timeOfSubmit = submission['timeOfSubmit'];
              final dynamic studentId = submission['studentId'];
              final String assId = assId1;
              final List<String> fileUrls = submission['files'] != null
                  ? List<String>.from(submission['files'])
                  : [];

              if (currentTeacher == teacherId && widget.assignId == assId) {
                allMessages.add(SubmissionsBubble(
                  teacherId: teacherId,
                  timeOfSubmit: timeOfSubmit,
                  studentId: studentId,
                  files: fileUrls,
                  assId: assId,
                ));
              }
            }
          }

          return ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: allMessages,
          );
        },
      ),
    );
  }
}

class SubmissionsBubble extends StatefulWidget {
  final dynamic teacherId;
  final dynamic timeOfSubmit;
  final dynamic studentId;
  final String assId;
  final List<String>? files;

  SubmissionsBubble({
    required this.teacherId,
    required this.timeOfSubmit,
    required this.studentId,
    this.files,
    required this.assId,
  });

  @override
  State<SubmissionsBubble> createState() => _SubmissionsBubbleState();
}

class _SubmissionsBubbleState extends State<SubmissionsBubble> {
  late Future<Student> _studentFuture;

  @override
  void initState() {
    super.initState();
    _studentFuture = AuthMethods().getStudentInfo(widget.studentId);
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<File> _downloadFile(String url) async {
    final Reference ref = FirebaseStorage.instance.refFromURL(url);
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath = '${tempDir.path}/${ref.name}';
    final File tempFile = File(tempPath);

    try {
      await ref.writeToFile(tempFile);
      return tempFile;
    } catch (e) {
      throw Exception('Error downloading file: $e');
    }
  }

  void _openFile(String fileUrl) async {
    try {
      final file = await _downloadFile(fileUrl);
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Student>(
      future: _studentFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.all(10.0),
            child: Card(
              color: Color(0xFF7EDCBE),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person, color: Colors.black),
                    Text('Teacher ID: ${widget.teacherId}', style: TextStyle(fontWeight: FontWeight.bold)),
                    Icon(Icons.person_outline, color: Colors.black),
                    Text('Student ID: ${widget.studentId}'),
                    Icon(Icons.access_time, color: Colors.black),
                    Text('Time of Submission: ${widget.timeOfSubmit.toDate()}'),
                    SizedBox(height: 10),
                    if (widget.files != null && widget.files!.isNotEmpty)
                      Text('Files:', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (widget.files != null)
                      ...widget.files!.map((fileUrl) => GestureDetector(
                        onTap: () => _launchURL(fileUrl),
                        child: Padding(
                          padding: EdgeInsets.only(top: 5.0),
                          child: Row(
                            children: [
                              Icon(Icons.attach_file, color: Colors.black),
                              SizedBox(width: 5),
                              Expanded(child: Text(fileUrl)),
                            ],
                          ),
                        ),
                      )).toList(),
                    Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          );
        }

        final student = snapshot.data!;
        final classInfo = '${student.branch} ${student.section} ${student.year}';
        dynamic idx=1;
        return Padding(
          padding: EdgeInsets.all(10.0),
          child: Card(
            color: Color(0xFFB182ED).withOpacity(0.4),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Color(0xFF7EDCBE)),
                      SizedBox(width: 5,),
                      Row(
                        children: [
                          Text('Student Name: ',style: TextStyle(color: Colors.brown,fontWeight: FontWeight.bold),),
                          Text('${student.name}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.vpn_key,  color: Color(0xFF7EDCBE)),
                      SizedBox(width: 5,),
                      Row(
                        children: [
                          Text('Enroll: ',style: TextStyle(color: Colors.brown,fontWeight: FontWeight.bold)),
                          Text('${student.enroll}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.school, color: Color(0xFF7EDCBE)),
                      SizedBox(width: 5,),
                      Text('Class: ',style: TextStyle(color: Colors.brown,fontWeight: FontWeight.bold),),
                      Text('$classInfo',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Color(0xFF7EDCBE)),
                      Text('Time of Submission: ',style: TextStyle(color: Colors.brown,fontWeight: FontWeight.bold),),
                      SizedBox(width: 5,),
                      Text('${DateFormat('yyyy-MM-dd,kk:mm').format(widget.timeOfSubmit.toDate())}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ],
                  ),
                  Text(' Submissions :',style: TextStyle(color: Color(0xFF7EDCBE),fontWeight: FontWeight.bold),),
                  Column(
                    children: widget.files!.map((fileUrl) {
                      return InkWell(
                        onTap: () => _openFile(fileUrl),
                        child: Row(
                          children: [
                            Icon(Icons.book_outlined,color: Color(0xFF7EDCBE),),
                            Text(
                              'file${idx++}.asset',
                              style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


// import 'package:assignmates/database/database.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:assignmates/models/student.dart';
//
// class ViewSubmissions extends StatefulWidget {
//   final dynamic assignId;
//   final dynamic title;
//
//   // Constructor with parameters
//   const ViewSubmissions({
//     Key? key,
//     required this.assignId,
//     required this.title,
//   }) : super(key: key);
//
//   // Constructor without parameters
//   const ViewSubmissions.defaultConstructor({Key? key})
//       : assignId = null,
//         title = null,
//         super(key: key);
//
//   @override
//   State<ViewSubmissions> createState() => _ViewSubmissionsState();
// }
//
// class _ViewSubmissionsState extends State<ViewSubmissions> {
//   late Stream<QuerySnapshot> stream;
//
//   @override
//   void initState() {
//     super.initState();
//     stream = AuthMethods().getDoneAssignments();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color(0xFF1CCE9C),
//         title: Row(
//           children: [
//             Text('${widget.title} ',style: TextStyle(decoration: TextDecoration.underline),),
//             Text('Submissions'),
//           ],
//         )
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: stream,
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(
//               child: CircularProgressIndicator(
//                 backgroundColor: Color(0xFF679289),
//               ),
//             );
//           }
//
//           final messages = snapshot.data!.docs;
//           List<SubmissionsBubble> allMessages = [];
//           final String currentTeacher = AuthMethods().getCurrentUser();
//
//           for (var msg in messages) {
//             final String assId1=msg.id;
//             final List<dynamic> submissions = msg['submissions'];
//             for (var submission in submissions) {
//               final dynamic teacherId = submission['teacherId'];
//               final dynamic timeOfSubmit = submission['timeOfSubmit'];
//               final dynamic studentId = submission['studentId'];
//               final String assId=assId1;
//               final List<String> fileUrls = submission['files'] != null
//                   ? List<String>.from(submission['files'])
//                   : [];
//
//               if (currentTeacher == teacherId && widget.assignId==assId) {
//                 allMessages.add(SubmissionsBubble(
//                   teacherId: teacherId,
//                   timeOfSubmit: timeOfSubmit,
//                   studentId: studentId,
//                   files: fileUrls,
//                   assId: assId,
//                 ));
//               }
//             }
//           }
//
//           return ListView(
//             reverse: true,
//             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//             children: allMessages,
//           );
//         },
//       ),
//     );
//   }
// }
//
// class SubmissionsBubble extends StatefulWidget {
//   final dynamic teacherId;
//   final dynamic timeOfSubmit;
//   final dynamic studentId;
//   final String assId;
//   final List<String>? files;
//
//   SubmissionsBubble({
//     required this.teacherId,
//     required this.timeOfSubmit,
//     required this.studentId,
//     this.files,
//     required this.assId,
//   });
//
//   @override
//   State<SubmissionsBubble> createState() => _SubmissionsBubbleState();
// }
//
// class _SubmissionsBubbleState extends State<SubmissionsBubble> {
//   late Future<Student> _studentFuture;
//   // late String assTitle;
//
//   @override
//   void initState() {
//     super.initState();
//     // assTitle=AuthMethods().getAssignmentName(widget.assId) as String;
//     _studentFuture = AuthMethods().getStudentInfo(widget.studentId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Student>(
//       future: _studentFuture,
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Padding(
//             padding: EdgeInsets.all(10.0),
//             child: Card(
//               color: Color(0xFF9CDCFD),
//               elevation: 5,
//               child: Padding(
//                 padding: EdgeInsets.all(10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Text('Assignment Title ${assTitle}'),
//                     Text('Teacher ID: ${widget.teacherId}', style: TextStyle(fontWeight: FontWeight.bold)),
//                     Text('Student ID: ${widget.studentId}'),
//                     Text('Time of Submission: ${widget.timeOfSubmit.toDate()}'),
//                     SizedBox(height: 10),
//                     if (widget.files != null && widget.files!.isNotEmpty)
//                       Text('Files:', style: TextStyle(fontWeight: FontWeight.bold)),
//                     if (widget.files != null)
//                       ...widget.files!.map((fileUrl) => Text(fileUrl)).toList(),
//                     Center(child: CircularProgressIndicator()), // Show loading spinner
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }
//
//         final student = snapshot.data!;
//         final classInfo = '${student.branch} ${student.section} ${student.year}';
//
//         return Padding(
//           padding: EdgeInsets.all(10.0),
//           child: Card(
//             color: Color(0xFF9CDCFD),
//             elevation: 5,
//             child: Padding(
//               padding: EdgeInsets.all(10.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Student Name: ${student.name}'),
//                   Text('Enroll: ${student.enroll}'),
//                   Text('Class: $classInfo'),
//                   Text('Time of Submission: ${widget.timeOfSubmit.toDate()}'),
//                   SizedBox(height: 10),
//                   if (widget.files != null && widget.files!.isNotEmpty)
//                     Text('Files:', style: TextStyle(fontWeight: FontWeight.bold)),
//                   if (widget.files != null)
//                     ...widget.files!.map((fileUrl) => Text(fileUrl)).toList(),
//                   SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
