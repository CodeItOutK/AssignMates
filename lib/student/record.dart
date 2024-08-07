import 'dart:async';
import 'package:assignmates/chat/chat.dart';
import 'package:assignmates/database/database.dart';
import 'package:assignmates/models/teacher.dart';
import 'package:assignmates/utilities/showSnackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:assignmates/utilities/timeLeft.dart';
import 'package:file_picker/file_picker.dart';
import 'package:assignmates/theme.dart';

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

  Future<List<ChatToTeacherBubble>> getChatBubbles() async {
    List<String> allTeacherIds = await AuthMethods().getAllTeachersForAStudent(
        widget.branch, widget.section, widget.year);
    List<ChatToTeacherBubble> allTeachersChatBubble = [];

    for (var v in allTeacherIds) {
      allTeachersChatBubble.add(ChatToTeacherBubble(teacherId: v));
    }
    return allTeachersChatBubble;
  }

  Future<List<AssignmentBubble>> getAssignments() async {
    QuerySnapshot snapshot = await AuthMethods().getAssignmentStream().first;
    List<AssignmentBubble> myAllAssignments = [];
    final assignmentList = snapshot.docs;

    for (var msg in assignmentList) {
      final dynamic assId = msg['id'];
      final String title = msg['title'];
      final dynamic deadline = msg['deadline'];
      final String instructions = msg['instructions'];
      final String teacherId = msg['teacherId'];
      final List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(msg['classes']);
      final List<String> fileUrls = List<String>.from(msg['fileUrls']);

      AssignmentBubble bubble = AssignmentBubble(
        assId: assId,
        classes: classes,
        fileUrls: fileUrls,
        title: title,
        deadline: deadline,
        instructions: instructions,
        teacherId: teacherId,
      );

      for (var v in classes) {
        if (v['branch'] == widget.branch && v['section'] == widget.section && v['year'] == widget.year) {
          myAllAssignments.add(bubble);
        }
      }
    }
    return myAllAssignments;
  }

  @override
  void initState() {
    super.initState();
    _stream = AuthMethods().getAssignmentStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: pblue,
        leading: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(5),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFFACA),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.arrow_back_ios, color: Colors.brown, size: 20),
              ),
            ),
          ),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${widget.enroll} :',
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 6),
            Text(
              '${widget.name}',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6FD6FF),
              Color(0xFF84DDE2),
              Color(0xFF9DE5C3),
              Color(0xFFAEEAAF),
              Color(0xFFBFEF98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            //enhancement
            Row(
              children: [
                Icon(Icons.help_outline_rounded,color: pblue,),
                Text('Doubt Support',style: TextStyle(color: pblue,fontWeight: FontWeight.bold,decorationColor: Colors.brown,decoration: TextDecoration.underline),),
              ],
            ),
            SizedBox(height: 10,),
            FutureBuilder<List<ChatToTeacherBubble>>(
              future: getChatBubbles(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Color(0xFF679289),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading chat bubbles'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No teachers found.'));
                } else {
                  return SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapshot.data!,
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 15),
            Row(
              children: [
                SizedBox(width: 25),
                Icon(Icons.task, color: pblue),
                Text(
                  'Scheduled Tasks',
                  style: TextStyle(
                    color: pblue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.brown,
                  ),
                ),
              ],
            ),
            FutureBuilder<List<AssignmentBubble>>(
              future: getAssignments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Color(0xFF679289),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading assignments'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No Assignments have been scheduled till date !!'),
                  );
                } else {
                  return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    children: snapshot.data!,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

//.............................................CCCHHAAATTT-BUBBLEEE................................................
class ChatToTeacherBubble extends StatefulWidget {
  final String teacherId;

  const ChatToTeacherBubble({super.key, required this.teacherId});

  @override
  State<ChatToTeacherBubble> createState() => _ChatToTeacherBubbleState();
}

class _ChatToTeacherBubbleState extends State<ChatToTeacherBubble> {

  dynamic teacherName="";
  dynamic studentId="";
  dynamic isPink=false;

  initMethods() async {
    // Fetch teacher information from AuthMethods
    Teacher _teacherModel = await AuthMethods().getTeacherInfo(widget.teacherId);

    // Format teacher's name by replacing spaces with newlines
    String formattedName = _teacherModel.name?.replaceAll(' ', '\n') ?? '';

    studentId=await AuthMethods().getCurrentUser();
    // Update state with formatted teacher's name
    setState(() {
      teacherName = formattedName;
    });
    //call after we have both teacherId and studentId accessed !!!
    isPink=await AuthMethods().getExistingValueOfTeacherSideNewMessage(widget.teacherId, studentId);
    setState(() {

    });
  }


  @override
  void initState() {
    if(teacherName=="")initMethods();// bug-fixed !!!
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle tap event here
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(teacherId: widget.teacherId,studentId: studentId,isTeacher:false)),
        );
        setState(() {
          isPink=false;
        });

        print("CircleAvatar tapped!");
      },
      child: SizedBox(
        width: 50,height: 50,
        child: Container(
          // width: 100,height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: isPink?Colors.pink:Colors.grey, // Transparent color to allow gradient border
            ),
            // gradient: isPink?LinearGradient(
            //   colors: [
            //     Colors.red,
            //     Colors.orange,
            //     // Colors.yellow,
            //     // Colors.green,
            //     // Colors.blue,
            //     Colors.indigo,
            //     Colors.purple,
            //   ],
            //   stops: [0.1, 0.5, 0.9,  1.3],
            // ),
          ),
          child: CircleAvatar(
            radius: 30, // Adjust the size to fit the text
            backgroundColor:pblue,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  teacherName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30, // Adjust font size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}


///////////......................................................ASSSIGNNMETTT---BUUBBLEEE............................
class AssignmentBubble extends StatefulWidget {

  final dynamic assId;
  final List<Map<String, dynamic>> classes;
  final List<String> fileUrls;
  final String title;
  final dynamic deadline;
  final String instructions;
  final String teacherId;

  AssignmentBubble({
    Key? key,
    required this.assId,
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
  List<File> files = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        files.addAll(result.paths.map((path) => File(path!)).toList());
      });
    }
  }

  void _startTimer(var timeStamp) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Convert timeStamp to Indian Standard Time (IST)
      DateTime istTimeStamp = timeStamp.toDate().toUtc();

      _timeUntil = OurTimeLeft().timeLeft(istTimeStamp);
      setState(() {
        if (_timeUntil[0] == "Blocked Assignment") {
          // Deadline exceeded
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
  String? _teacherName;
  Future<void> _loadTeacherName() async {
    _teacherName = await AuthMethods().getTeacherNameFromId(widget.teacherId);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadTeacherName();
    _startTimer(widget.deadline);
    super.initState();
  }

  doTask(){
    //update the color of tile
    setState(() {

    });
    //fix time standards issue
    //remove this tile from list of widgets->todo
    //snackbar on pressing Submit for blocked assignment now !!
    // showCustomSnackbar(context, 'Dedline exceeded !');
  }
  bool isAssignmentSubmitted=false;
  @override
  Widget build(BuildContext context) {
    //added visibility to a tile
    return Visibility(
      visible: !isAssignmentSubmitted,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: _timeUntil[0] == 'Blocked Assignment'
              ? Color(0xFFFFCDD2)
              : peach,
          borderRadius: BorderRadius.circular(30),
          border: _timeUntil[0] == 'Blocked Assignment'
              ? Border.all(
            color: Colors.red,
            width: 2,
          )
              : Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _timeUntil[0] == 'Blocked Assignment'
                  ? Colors.red.withOpacity(0.5) // Shadow color with some opacity
                  : Theme.of(context).colorScheme.primary.withOpacity(0.5),
              spreadRadius: 2, // How much the shadow spreads
              blurRadius: 5, // Softness of the shadow
              offset: Offset(0, 3), // Position of the shadow
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5,),
            Row(
              children: [
                Icon(Icons.tag_sharp,color: Colors.black,),
                Text(
                  'Title:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.brown,
                  ),
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${widget.title}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF679289),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.create,color: Colors.red,),
                Text(
                  'Deadline :',
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Flexible(
                  child: Text(
                    '${_timeUntil[0]}',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person,color: Colors.blueGrey,),
                Text(
                  'Assigned By:',
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Flexible(
                  child: Text(
                    '${_teacherName}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.app_registration,color: Colors.blueGrey,),
                Text(
                  'Instructions:',
                  style: TextStyle(
                    color: Colors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Flexible(
                  child: Text(
                    '${widget.instructions}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
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
                      Flexible(
                        child: Text(
                          '${widget.title}.asset',
                          style: TextStyle(
                            color: Color(0xFF679289),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_timeUntil[0] == 'Blocked Assignment') {
                    showCustomSnackbar(context, 'Deadline exceeded !');
                  } else {
                    await _pickFile();
                    if (files.isEmpty) {
                      showCustomSnackbar(context, 'Please Upload the file to proceed !');
                    } else {
                      await AuthMethods().doneWithAnAssignment(widget.assId,widget.teacherId,files);
                      setState(() {
                        isAssignmentSubmitted = true;
                      });
                    }
                  }
                },
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_box_outlined,color: Colors.white,),
                      Text(
                        '     Submit \nAssignment',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary:pblue.withOpacity(0.6),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}


