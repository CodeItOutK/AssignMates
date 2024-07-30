// import 'package:assignmates/pages/teacheruploadpage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class History extends StatefulWidget {
//   final String? name; // name of the teacher
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
//   final Stream<QuerySnapshot<Map<String, dynamic>>> _stream =
//   FirebaseFirestore.instance.collection('assignments').snapshots();
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text("Teacher ${widget.name} 's dashboard", style: TextStyle(color: Colors.white)),
//           backgroundColor: Theme.of(context).colorScheme.primary,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                 stream: _stream, // stream of all the assignments
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         backgroundColor: Color(0xFF679289),
//                       ),
//                     );
//                   }
//                   // all the list
//                   final assignmentList = snapshot.data!.docs;
//                   List<MessageBubble> myAllAssignments = []; // my assignments (teacher's pov)
//                   for (var msg in assignmentList) {
//                     // match if currentUser's id matches with db's teacherId
//                     final dynamic title = msg['title'] ?? '';
//                     final dynamic teacher = widget.name ?? '';
//                     final dynamic instructions = msg['instructions'] ?? '';
//                     final dynamic deadline = msg['deadline'] ?? '';
//                     final List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(msg['classes']);
//
//                     MessageBubble _bubble = MessageBubble(
//                       title: title,
//                       teacher: teacher,
//                       instructions: instructions,
//                       deadline: deadline,
//                       classes: classes,
//                     );
//                     if (msg['teacherId'] == widget.id) {
//                       myAllAssignments.add(_bubble);
//                     }
//                   }
//                   if (myAllAssignments.isEmpty) {
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
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => TeacherUploadPage(id: widget.id!)),
//                   );
//                 },
//                 child: Text('Allocate assignments'),
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreen),
//                   foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//                   padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   // Your onPressed code here
//                 },
//                 child: Text('View Submissions'),
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreen),
//                   foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
//                   padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
//                   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                     RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
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
//   final List<Map<String, dynamic>> classes;
//
//   MessageBubble({this.title, this.teacher, this.instructions, this.deadline, required this.classes});
//
//   @override
//   Widget build(BuildContext context) {
//     String students = "";
//     for (var v in classes) {
//       students += "${v['branch']} ${v['section']} ${v['year']} ";
//     }
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text('Title: $title'),
//           Material(
//             elevation: 5.0,
//             borderRadius: BorderRadius.only(
//               topRight: Radius.circular(20),
//               bottomLeft: Radius.circular(20),
//               bottomRight: Radius.circular(20),
//             ),
//             color: Color(0xFF679289),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(5),
//                   child: Text(
//                     'Instructions-$instructions',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(5),
//                   child: Text(
//                     'Deadline-$deadline',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 10),
//                   child: Text('Allocated to Classes $students', style: TextStyle(color: Colors.white, fontSize: 10)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:assignmates/database/database.dart';
import 'package:assignmates/pages/teacheruploadpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  late Stream<QuerySnapshot> _stream ;
  final String _currentUserName = "currentUserName"; // Replace with actual current user name

  @override
  void initState() {
    _stream=AuthMethods().getAssignmentStream();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Teacher ${widget.name} 's dashboard", style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: _stream,//stream of all the assign-ments
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Color(0xFF679289),
                      ),
                    );
                  }
                  //all the list
                  final assignmentList = snapshot.data!.docs;
                  List<MessageBubble> myAllAssignments = [];//my -assignments(teachers pov)
                  // final dynamic title;
                  // final dynamic teacher;
                  // final dynamic instructions;
                  // final dynamic deadline;
                  // final List<String> classes;
                  for (var msg in assignmentList) {//match is currentUsers id matches with db's teacherId
                    final dynamic title=msg['title']??'';
                    final dynamic teacher=widget.name??'';
                    final dynamic instructions=msg['instructions']??'';
                    final dynamic deadline=msg['deadline']??'';
final List<Map<String, dynamic>> classes = List<Map<String, dynamic>>.from(msg['classes']);

                    MessageBubble _bubble = MessageBubble(
                      title: title,
                      teacher: teacher,
                      instructions: instructions, // Replace with actual data
                      deadline: deadline,
                      classes: classes, // Replace with actual data
                    );
                    // myAllAssignments.add(_bubble);
                    if (msg['teacherId']==widget.id){
                      myAllAssignments.add(_bubble);
                    }
                  }
                  if(myAllAssignments.isEmpty){
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherUploadPage(id: widget.id!)),
                  );
                },
                child: Text('Allocate assignments'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreen),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Your onPressed code here
                },
                child: Text('View Submissions'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreen),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final dynamic title;
  final dynamic teacher;
  final dynamic instructions;
  final dynamic deadline;
  final List<Map<String,dynamic>> classes;

  MessageBubble({this.title, this.teacher, this.instructions, this.deadline, required this.classes});
  // MessageBubble({this.title,this.teacher, this.instructions, this.deadline, });

  @override
  Widget build(BuildContext context) {
    String students = "";
    for (var v in classes) {
      students += "${v['branch']} ${v['section']} ${v['year']} ";
    }
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Title: $title'),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: Color(0xFF679289),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Instructions-$instructions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Deadline-$deadline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Allocated to Classes $students', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
