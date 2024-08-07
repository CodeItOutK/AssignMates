import 'package:assignmates/database/database.dart';
import 'package:assignmates/models/student.dart';
import 'package:assignmates/teacher/teacheruploadpage.dart';
import 'package:assignmates/teacher/viewSubmissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:assignmates/utilities/timeLeft.dart';
import '../chat/chat.dart';
import 'viewSubmissions.dart';
import '../models/teacher.dart';
import '../theme.dart';
import 'defaulterStudents.dart';

class History extends StatefulWidget {
  final String? name; //name of the teacher
  final String? id; //id of teacher

  const History({
    Key? key,
    required this.name,
    required this.id,
  }) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}
//use FutureBuilder insted of ListView
class _HistoryState extends State<History> {
  late Stream<QuerySnapshot> _stream;

  List<String> chatIds = []; // doc inside chat-collection
  List<Student> newMessageStudentModels = [];
  List<ChatToStudentBubble> allChatBubbles = []; // Contains that circle-widget on the top
  List<String> newMessageStudentIds = [];

  Future<void> initMethods() async {
    // Fetch chatIds associated with the widget's id
    chatIds = await AuthMethods().getChatModel(widget.id!);

    // Fetch the corresponding student models and ids from the chatIds
    newMessageStudentModels = await AuthMethods().getStudentsModelsFromChatIds(chatIds);
    newMessageStudentIds = await AuthMethods().getStudentIdsFromChatIds(chatIds);

    // Ensure the lengths of newMessageStudentModels and newMessageStudentIds are the same
    int n = newMessageStudentModels.length;
    if (newMessageStudentModels.isNotEmpty) {
      for (int i = 0; i < n; i++) {
        // Create and add ChatToStudentBubble with both studentId and studentModel
        allChatBubbles.add(
          ChatToStudentBubble(
            studentId: newMessageStudentIds[i],
            studentModel: newMessageStudentModels[i],
            teacherId: widget.id!,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _stream = AuthMethods().getAssignmentStream();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: Container(
            margin: EdgeInsets.all(13),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 2), // Changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.arrow_back_ios, color: Colors.brown, size: 18),
                ),
              ),
            ),
          ),
          title: Text(
            "${widget.name}",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        body: FutureBuilder<void>(
          future: initMethods(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView(
                padding: EdgeInsets.all(16.0), // Add padding to the entire screen
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 100, // Adjust the height to fit the content of horizontal ListView
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: allChatBubbles,
                        ),
                      ),
                      SizedBox(height: 16), // Space between horizontal ListView and text
                      Row(
                        children: [
                          Icon(Icons.task_outlined, color: Colors.brown, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Scheduled Tasks',
                            style: TextStyle(
                              color: Colors.brown,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16), // Space between header and list
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
                          final assignmentList = snapshot.data!.docs;
                          List<AssignmentBubble> myAllAssignments = []; // My assignments (teacher's POV)
                          for (var msg in assignmentList) {
                            final dynamic assignmentId = msg['id'];
                            final dynamic title = msg['title'] ?? '';
                            final dynamic teacher = widget.name ?? '';
                            final dynamic instructions = msg['instructions'] ?? '';
                            final dynamic deadline = msg['deadline'] ?? '';
                            final List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(msg['classes']);

                            AssignmentBubble _bubble = AssignmentBubble(
                              assId: assignmentId,
                              title: title,
                              teacher: teacher,
                              instructions: instructions,
                              deadline: deadline,
                              classes: classes,
                            );
                            if (msg['teacherId'] == widget.id) {
                              myAllAssignments.add(_bubble);
                            }
                          }
                          if (myAllAssignments.isEmpty) {
                            return Center(
                              child: Text(
                                'No Assignments Found',
                                style: TextStyle(color: Colors.brown, fontSize: 16),
                              ),
                            );
                          }
                          return ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: myAllAssignments,
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TeacherUploadPage(id: widget.id!)),
                            );
                          },
                          child: Text('Allocate Assignments', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).colorScheme.secondary,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}


// class _HistoryState extends State<History> {
//   late Stream<QuerySnapshot> _stream;
//
//   List<String> chatIds = []; // doc inside chat-collection
//   List<Student> newMessageStudentModels = [];
//   List<ChatToStudentBubble> allChatBubbles = []; // Contains that circle-widget on the top
//   List<String> newMessageStudentIds = [];
//
//   Future<void> initMethods() async {
//     // Fetch chatIds associated with the widget's id
//     chatIds = await AuthMethods().getChatModel(widget.id!);
//
//     // Fetch the corresponding student models and ids from the chatIds
//     newMessageStudentModels = await AuthMethods().getStudentsModelsFromChatIds(chatIds);
//     newMessageStudentIds = await AuthMethods().getStudentIdsFromChatIds(chatIds);
//
//     // Ensure the lengths of newMessageStudentModels and newMessageStudentIds are the same
//     int n = newMessageStudentModels.length;
//     if (newMessageStudentModels.isNotEmpty) {
//       for (int i = 0; i < n; i++) {
//         // Create and add ChatToStudentBubble with both studentId and studentModel
//         setState(() {
//           allChatBubbles.add(
//             ChatToStudentBubble(
//               studentId: newMessageStudentIds[i],
//               studentModel: newMessageStudentModels[i],
//               teacherId: widget.id!,
//             ),
//           );
//         });
//       }
//     }
//
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _stream = AuthMethods().getAssignmentStream();
//     initMethods();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           leading: Container(
//             margin: EdgeInsets.all(13),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
//                       spreadRadius: 3,
//                       blurRadius: 5,
//                       offset: Offset(0, 2), // Changes position of shadow
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(6),
//                   child: Icon(Icons.arrow_back_ios, color: Colors.brown, size: 18),
//                 ),
//               ),
//             ),
//           ),
//           title: Text(
//             "${widget.name}",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//           backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
//         ),
//
//
//         body: ListView(
//           padding: EdgeInsets.all(16.0), // Add padding to the entire screen
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 100, // Adjust the height to fit the content of horizontal ListView
//                   child: ListView(
//                     scrollDirection: Axis.horizontal,
//                     children: allChatBubbles,
//                   ),
//                 ),
//                 SizedBox(height: 16), // Space between horizontal ListView and text
//                 Row(
//                   children: [
//                     Icon(Icons.task_outlined, color: Colors.brown, size: 24),
//                     SizedBox(width: 8),
//                     Text(
//                       'Scheduled Tasks',
//                       style: TextStyle(
//                         color: Colors.brown,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16), // Space between header and list
//                 StreamBuilder<QuerySnapshot>(
//                   stream: _stream, // Stream of all the assignments
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return Center(
//                         child: CircularProgressIndicator(
//                           backgroundColor: Color(0xFF679289),
//                         ),
//                       );
//                     }
//                     final assignmentList = snapshot.data!.docs;
//                     List<AssignmentBubble> myAllAssignments = []; // My assignments (teacher's POV)
//                     for (var msg in assignmentList) {
//                       final dynamic assignmentId = msg['id'];
//                       final dynamic title = msg['title'] ?? '';
//                       final dynamic teacher = widget.name ?? '';
//                       final dynamic instructions = msg['instructions'] ?? '';
//                       final dynamic deadline = msg['deadline'] ?? '';
//                       final List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(msg['classes']);
//
//                       AssignmentBubble _bubble = AssignmentBubble(
//                         assId: assignmentId,
//                         title: title,
//                         teacher: teacher,
//                         instructions: instructions,
//                         deadline: deadline,
//                         classes: classes,
//                       );
//                       if (msg['teacherId'] == widget.id) {
//                         myAllAssignments.add(_bubble);
//                       }
//                     }
//                     if (myAllAssignments.isEmpty) {
//                       return Center(
//                         child: Text(
//                           'No Assignments Found',
//                           style: TextStyle(color: Colors.brown, fontSize: 16),
//                         ),
//                       );
//                     }
//                     return ListView(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       children: myAllAssignments,
//                     );
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => TeacherUploadPage(id: widget.id!)),
//                       );
//                     },
//                     child: Text('Allocate Assignments', style: TextStyle(color: Colors.white)),
//                     style: ElevatedButton.styleFrom(
//                       primary: Theme.of(context).colorScheme.secondary,
//                       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class AssignmentBubble extends StatefulWidget {
  final dynamic assId; //id
  final dynamic title; //assignment-title
  final dynamic teacher;
  final dynamic instructions;
  final dynamic deadline;
  final List<Map<String, dynamic>> classes;

  AssignmentBubble({this.assId, this.title, this.teacher, this.instructions, this.deadline, required this.classes});

  @override
  State<AssignmentBubble> createState() => _AssignmentBubbleState();
}

class _AssignmentBubbleState extends State<AssignmentBubble> {
  List<String> _timeUntil = ['loading..', 'loading..'];
  late Timer _timer;

  void _startTimer(var timeStamp) {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      //called after every 1 sec take difference from the current-time every one second
      _timeUntil = OurTimeLeft().timeLeft(timeStamp.toDate());
      setState(() {
        //alert box is being shown just once after timer[0]'s value becomes {}
        if (_timeUntil[0] == "REPLACE CURRENT BOOK from below ↓↓↓↓") {
          //deadline exceeded
        }
      });
    });
  }

  @override
  void initState() {
    _startTimer(widget.deadline);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String students = "";
    for (var v in widget.classes) {
      students += "${v['branch']} ${v['section']} ${v['year']} \n";
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        color: Color(0xFF9CDCFD),
        child: Container(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.view_timeline,color: Theme.of(context).colorScheme.primary),
                    Text(
                      'Title',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.brown,
                      ),
                    ),
                    Text(' : '),
                    Text(
                      '${widget.title}',
                      style: TextStyle(
                        color:Colors.blueAccent,
                        // color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                )
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Aligns texts at the top
                  children: [
                    Icon(Icons.rebase_edit,color: Colors.brown.withOpacity(0.7),),
                    Text(
                      'Instructions: ',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 16,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${widget.instructions}',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis, // Handle overflow if the text is too long
                        maxLines: 3, // Limit the number of lines displayed
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.pending,color: Colors.red.withOpacity(0.7),),
                    Text(
                      'Deadline :  ',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${_timeUntil[0]}',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.groups,color: Colors.brown.withOpacity(0.7),),
                    Text(
                      'Allocated to Classes : ',
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$students',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Your onPressed code here
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewSubmissions(assignId: widget.assId,title: widget.title,)),
                    );
                  },
                  child: Text('       View \n Submissions',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF21C799),
                    padding: EdgeInsets.symmetric(horizontal: 12, ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: TextStyle(fontSize: 14, color: Colors.brown,fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>DefaultersScreen(assId: widget.assId,)),
                  );
                },
                child: Center(
                  child:Visibility(
                    visible: _timeUntil[0]=='Blocked Assignment'?true:false, // Set to false to hide the widget
                    child: Row(
                      children: [
                        Icon(Icons.privacy_tip_outlined,color: Colors.red,),
                        SizedBox(width: 5,),
                        Text('View defaulter Students',style: TextStyle(color: Colors.red,decorationColor: Colors.red,decoration: TextDecoration.underline),),
                      ],
                    ),
                  ),

                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
class ChatToStudentBubble extends StatefulWidget {
  Student studentModel;
  String studentId;
  String teacherId;


  ChatToStudentBubble({super.key, required this.studentModel,required this.studentId,required this.teacherId});

  @override
  State<ChatToStudentBubble> createState() => _ChatToStudentBubbleState();
}

class _ChatToStudentBubbleState extends State<ChatToStudentBubble> {
  dynamic studentName = "";
  bool colorPink=false;

  @override
  void initState() {
    super.initState();
    initMethods();
  }

  Future<void> initMethods() async {
    colorPink=await AuthMethods().seenStatusForRecentMessage(widget.teacherId,widget.studentId);
    studentName = widget.studentModel.name;

    setState(() {
      // Format student's name by replacing spaces with newlines
      studentName = studentName?.replaceAll(' ', '\n') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              teacherId: widget.teacherId,
              studentId: widget.studentId,
              isTeacher: true,
            ),
          ),
        );

        //on coming back
        setState(() {
          colorPink = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorPink? Colors.pinkAccent : Colors.grey,
            border: Border.all(
              width: 2,
              color: Colors.transparent, // Transparent color for gradient effect
            ),
          ),
          child: CircleAvatar(
            radius: 35, // Adjust the size to fit the text
            backgroundColor: pblue,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  studentName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Adjust font size as needed
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

