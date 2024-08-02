import 'package:assignmates/database/database.dart';
import 'package:assignmates/teacher/teacheruploadpage.dart';
import 'package:assignmates/teacher/viewSubmissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:assignmates/utilities/timeLeft.dart';
import 'defaulterStudents.dart';



class History extends StatefulWidget {
  final String? name; //name of the teacher
  final String? id;

  const History({
    Key? key,
    required this.name,
    required this.id,
  }) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late Stream<QuerySnapshot> _stream;
  final String _currentUserName = "currentUserName"; // Replace with actual current user name

  @override
  void initState() {
    _stream = AuthMethods().getAssignmentStream();
    super.initState();
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
                      offset: Offset(0, 2), // changes position of shadow
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0), // Add padding to the entire screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  // All the list
                  final assignmentList = snapshot.data!.docs;
                  List<AssignmentBubble> myAllAssignments = []; // My assignments (teacher's POV)
                  for (var msg in assignmentList) {
                    final dynamic assignmentId=msg['id'];
                    final dynamic title = msg['title'] ?? '';
                    final dynamic teacher = widget.name ?? '';
                    final dynamic instructions = msg['instructions'] ?? '';
                    final dynamic deadline = msg['deadline'] ?? '';
                    final List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(msg['classes']);

                    AssignmentBubble _bubble = AssignmentBubble(
                      assId:assignmentId,
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
                  child: Text('Allocate Assignments',style: TextStyle(color: Colors.white),),
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
        ),
      ),
    );
  }
}

class AssignmentBubble extends StatefulWidget {
  final dynamic assId;//id
  final dynamic title;//assignment-title
  final dynamic teacher;
  final dynamic instructions;
  final dynamic deadline;
  final List<Map<String, dynamic>> classes;

  AssignmentBubble({this.assId,this.title, this.teacher, this.instructions, this.deadline, required this.classes});

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

  @override
  void initState() {
    _startTimer(widget.deadline);
    // TODO: implement initState
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
                    MaterialPageRoute(builder: (context) =>DefaultersScreen(assId:widget.assId)),
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


// import 'package:assignmates/database/database.dart';
// import 'package:assignmates/pages/teacheruploadpage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class History extends StatefulWidget {
//   final String? name; //name of the teacher
//   final String? id;
//
//   const History({
//     Key? key,
//     required this.name,
//     required this.id,
//   }) : super(key: key);
//
//   @override
//   _HistoryState createState() => _HistoryState();
// }
//
// class _HistoryState extends State<History> {
//   late Stream<QuerySnapshot> _stream ;
//   final String _currentUserName = "currentUserName"; // Replace with actual current user name
//
//   @override
//   void initState() {
//     _stream=AuthMethods().getAssignmentStream();
//     // TODO: implement initState
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           leading:
//           Row(
//             children: [Container(
//               margin: EdgeInsets.all(10),
//               padding: EdgeInsets.all(5),
//               child: GestureDetector(
//                 onTap: (){
//                   //cant use pop-context bcox u came from push and removed until
//                   Navigator.pop(context);
//                 },
//                 child: Container(decoration:BoxDecoration(color: Color(0xFFFFFACA),
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.yellow.withOpacity(0.5),
//                       spreadRadius: 5,
//                       blurRadius: 7,
//                       offset: Offset(0, 3), // changes position of shadow
//                     ),
//                   ],
//                 ),child: Padding(
//                     padding: EdgeInsets.all(3),
//                     child: Icon(Icons.arrow_back_ios,color: Colors.brown,size: 20,)),),
//               ),
//             ),]
//           ),
//           title: Text("${widget.name}", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
//           backgroundColor: Theme.of(context).colorScheme.primary,
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
//                 child: Row(
//                   children: [
//                     Icon(Icons.task_outlined,color: Colors.brown,),
//                     Padding(
//                     padding: EdgeInsets.symmetric(vertical: 5),
//                     child: Text('Scheduled Tasks',style: TextStyle(color: Colors.brown,fontSize: 18,fontWeight: FontWeight.bold),),
//                   ),]
//                 ),
//               ),
//               StreamBuilder<QuerySnapshot>(
//                 stream: _stream,//stream of all the assign-ments
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         backgroundColor: Color(0xFF679289),
//                       ),
//                     );
//                   }
//                   //all the list
//                   final assignmentList = snapshot.data!.docs;
//                   List<MessageBubble> myAllAssignments = [];//my -assignments(teachers pov)
//                   for (var msg in assignmentList) {//match is currentUsers id matches with db's teacherId
//                     final dynamic title=msg['title']??'';
//                     final dynamic teacher=widget.name??'';
//                     final dynamic instructions=msg['instructions']??'';
//                     final dynamic deadline=msg['deadline']??'';
// final List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(msg['classes']);
//
//                     MessageBubble _bubble = MessageBubble(
//                       title: title,
//                       teacher: teacher,
//                       instructions: instructions, // Replace with actual data
//                       deadline: deadline,
//                       classes: classes, // Replace with actual data
//                     );
//                     // myAllAssignments.add(_bubble);
//                     if (msg['teacherId']==widget.id){
//                       myAllAssignments.add(_bubble);
//                     }
//                   }
//                   if(myAllAssignments.isEmpty){
//                     return Text('Assignments DNE');
//                   }
//                   return ListView(
//                     shrinkWrap: true,
//                     reverse: true,
//                     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//                     children: myAllAssignments,
//                   );
//                 },
//               ),
//               // SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => TeacherUploadPage(id: widget.id!)),
//                     );
//                   },
//                   child: Text('Allocate assignments'),
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF02C798),),
//                     foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//                     padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               Center(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Your onPressed code here
//                   },
//                   child: Text('View Submissions'),
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF02C798),),
//                     foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//                     padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class MessageBubble extends StatelessWidget {
//   final dynamic title;
//   final dynamic teacher;
//   final dynamic instructions;
//   final dynamic deadline;
//   final List<Map<String,dynamic>> classes;
//
//   MessageBubble({this.title, this.teacher, this.instructions, this.deadline, required this.classes});
//   // MessageBubble({this.title,this.teacher, this.instructions, this.deadline, });
//
//   @override
//   Widget build(BuildContext context) {
//     String students = "";
//     for (var v in classes) {
//       students += "${v['branch']} ${v['section']} ${v['year']} \n";
//     }
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Material(
//             elevation: 5.0,
//             borderRadius: BorderRadius.all(
//               Radius.circular(20),
//             ),
//             color: Color(0xFF9CDCFD),
//             child: Container(
//               margin: EdgeInsets.all(10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(
//                       'Title-$title',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(
//                       'Instructions-$instructions',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(5),
//                     child: Text(
//                       'Deadline-$deadline',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 10),
//                     child: Text('Allocated to Classes $students', style: TextStyle(color: Colors.white, fontSize: 10)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
