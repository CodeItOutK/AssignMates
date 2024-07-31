import 'dart:async';
import 'package:assignmates/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:assignmates/timeLeft.dart';

// For a particular student, maintain the record of completed tasks
// and the tasks that need to be completed with their timelines being shown
class StudentRecords extends StatefulWidget {
  final String name;
  final String enroll;
  final String branch;
  final String email;
  final String year;
  final String section;

  const StudentRecords({
    Key? key,
    required this.name,
    required this.enroll,
    required this.branch,
    required this.email,
    required this.year,
    required this.section,
  }) : super(key: key);

  @override
  State<StudentRecords> createState() => _StudentRecordsState();
}

class _StudentRecordsState extends State<StudentRecords> {
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to get all assignments
    _stream = AuthMethods().getAssignmentStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading:
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(5),
            child: GestureDetector(
              onTap: (){
                //cant use pop-context bcox u came from push and removed until
                Navigator.pop(context);
              },
              child: Container(decoration:BoxDecoration(color: Color(0xFFFFFACA),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),child: Padding(
                  padding: EdgeInsets.all(3),
                  child: Icon(Icons.arrow_back_ios,color: Colors.brown,size: 20,)),),
            ),
          ),

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, // Add this line
          children: [
            Text(
              '${widget.enroll} :',
              style: TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 6),
            Text(
              '${widget.name}',
              style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )

      ,
      body: ListView(
        children:[ Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _stream, // Stream of all the assignments
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Color(0xFF679289),
                    ),
                  );
                }
                // All the assignment list
                final assignmentList = snapshot.data!.docs;
                List<AssignmentBubble> myAllAssignments = []; // Assignments (student's view)

                for (var msg in assignmentList) {
                  final String title = msg['title'];
                  final dynamic deadline = msg['deadline'];
                  final String instructions = msg['instructions'];
                  final String teacherId = msg['teacherId'];
                  final List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(msg['classes']);
                  final List<String> fileUrls = List<String>.from(msg['fileUrls']);

                  AssignmentBubble _bubble = AssignmentBubble(
                    classes: classes,
                    fileUrls: fileUrls,
                    title: title,
                    deadline: deadline,
                    instructions: instructions,
                    teacherId: teacherId,
                  );

                  for (var v in classes) {
                    if (v['branch'] == widget.branch && v['section'] == widget.section && v['year'] == widget.year) {
                      myAllAssignments.add(_bubble);
                    }
                  }
                }

                if (myAllAssignments.isEmpty) {
                  return Text('Assignments DNE');
                }

                return ListView(
                  shrinkWrap: true,
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  children: myAllAssignments,
                );
              },
            ),
          ],
        ),]
      ),
    );
  }
}

class AssignmentBubble extends StatefulWidget {

  final List<Map<String, dynamic>> classes;
  final List<String> fileUrls;
  final String title;
  final dynamic deadline;
  final String instructions;
  final String teacherId;

  AssignmentBubble({
    Key? key,
    required this.classes,
    required this.fileUrls,
    required this.title,
    required this.deadline,
    required this.instructions,
    required this.teacherId,
  }) : super(key: key);

  @override
  State<AssignmentBubble> createState() => _AssignmentBubbleState();
}

class _AssignmentBubbleState extends State<AssignmentBubble> {
  List<String> _timeUntil=['loading..','loading..'];
  late Timer _timer;

  void _startTimer(var timeStamp){
    _timer=Timer.periodic(Duration(seconds: 1), (timer) {
      //called after every 1 sec take diffrence from the current-time every one second
      _timeUntil=OurTimeLeft().timeLeft(timeStamp.toDate());
      setState(() {
        //alert box is being shown just once after timer[0]'s value becomes {}
        if (_timeUntil[0] == "REPLACE CURRENT BOOK from below ↓↓↓↓") {
          //daedline exceeded
        }

      });
    });
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
  void initState() {
    // TODO: implement initState
    _startTimer(widget.deadline);
    super.initState();
  }

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
                'Title:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.brown,
                ),
              ),
              Text(
                '${widget.title}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF679289),
                ),
              ),
            ],
          ),

          SizedBox(height: 6),
          Row(
            children: [
              Text(
                // 'Deadline: $deadline',
                'Deadline :',
                style: TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                // 'Deadline: $deadline',
                '${_timeUntil[0]}',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Instructions:',
                style: TextStyle(
                  color: Colors.brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${widget.instructions}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'Files -> ',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.brown,
            ),
          ),
          Column(
            children: widget.fileUrls.map((fileUrl) {
              return InkWell(
                onTap: () => _openFile(fileUrl),
                child: Row(
                  children: [
                    Icon(Icons.book_outlined),
                    Text(
                      '${widget.title}.asset',
                      // fileUrl.split('/').last,
                      style: TextStyle(
                        color: Color(0xFF679289),
                        decoration: TextDecoration.underline,
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
