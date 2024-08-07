
import 'package:assignmates/database/database.dart';
import 'package:assignmates/utilities/showSnackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/student.dart';
import '../models/teacher.dart';
import '../theme.dart';//for conversions of date-time into required formats

bool isTeacherG=false;

class ChatScreen extends StatefulWidget {

  dynamic teacherId;
  dynamic studentId;
  dynamic isTeacher;//kaha se aaye h
  //par har message koi bhi bhej skta h teacher/student

  ChatScreen({this.teacherId,this.studentId,required this.isTeacher});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

dynamic studentName;
dynamic teacherName;

class _ChatScreenState extends State<ChatScreen> {

  dynamic messageText;
  TextEditingController messageController=new TextEditingController();//for clearing the message
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  dynamic _stream;
  // dynamic _currentUserName;
  bool _loading=true;
  @override
  // bool studentSideNewMessage = false;
  dynamic valOfTeacherSideNewMsg;//existing value
  dynamic valOfStudentSideNewMsg;

  void getDetails() async{
    _stream=AuthMethods().getChatStreamForStudents(widget.teacherId, widget.studentId);
    // _stream=OurDatabase().getMessageStream(widget.grpId);
    Student _student=await AuthMethods().getStudentInfo(widget.studentId);
    setState(() {
      studentName=_student.name;
    });

    Teacher _teacher=await AuthMethods().getTeacherInfo(widget.teacherId);
    setState(() {
      teacherName=_teacher.name;
    });

    valOfTeacherSideNewMsg=await AuthMethods().getExistingValueOfTeacherSideNewMessage(widget.teacherId,widget.studentId);
    valOfStudentSideNewMsg=await AuthMethods().getExistingValueOfStudentSideNewMessage(widget.teacherId,widget.studentId);

    setState(() {

    });
    // studentName.split(' ')[0];
  }
  flipState()async{
    await AuthMethods().flipSeenStatus(widget.teacherId, widget.studentId,isTeacherG);
  }
  void initState() {
    // TODO: implement initState
    getDetails();//streams are a-synchronous
    setState(() {
      _loading=false;
    });
    if(widget.isTeacher){
      isTeacherG=true;
    }
    flipState();//seen status studentSideNewMessage set to false
    //seen status from student side of teacherSideNewMessage set to false
    //if we are teacher,we have now seen all the messages of the current-student-teacher screen
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //different preview of chat-messages corresponding to different users

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: pblue,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
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
                  child: Icon(Icons.home,color: pblue,size: 20,)),),
            ),
          ),
        ],
        title: Row(
          children: [
            Icon(Icons.message_outlined,color: Colors.white,size: 40,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('  Doubt Section',style: TextStyle(color: Colors.white,fontFamily: 'Cabin',fontWeight:FontWeight.bold),),
                Text('   ${teacherName}',style: TextStyle(color: Colors.white,fontSize: 12),),
              ],
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
        child: SafeArea(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    //snapshot dosent have data ->show spinner there
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: pblue, //will spin for no-data and as soon data is ready it will get destroyed.
                        ),
                      );
                    }
                    final messages = snapshot.data!.docs;
                    List<MessageBubble>allMessages=[];
                    for(var msg in messages){
                      final dynamic _msg = msg['message'];
                      final dynamic _timeFromDB=msg['time'];//time jb vo db me add hue
                      //convert dateTime.now()into required formats
                      final dynamic ddmmyyyy= DateFormat.Hm().format(_timeFromDB.toDate());
                      final dynamic date=DateFormat('dd/MM/yyyy').format(_timeFromDB.toDate());
                      dynamic user=msg['user'];//student or teacher->msg ??
                      // Output will be in hour:minute format (e.g., 12:34)
                      bool isTeacher=false;
                      if(user=='teacher'){
                        isTeacher=true;
                      }
                      MessageBubble _bubble=MessageBubble(msg: _msg,sender:user,isStudent: !isTeacher,date: date,ddmmyy: ddmmyyyy,);
                      allMessages.add(_bubble);
                    }
                    return Expanded(
                      //take up as much space available
                      child: ListView(
                        //ListView -> alternative to Column Widget
                        reverse:
                        true, //sticky to the end->neeche se upr scroll kro
                        padding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        children: allMessages,
                      ),
                    );
                    // return Container();
                  }),

                      // Text('Student Id:${widget.studentId}'),
                      // Text('Teacher Id:${widget.teacherId}'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5), // Background color of the input field
                    borderRadius: BorderRadius.circular(18.0), // Optional: add rounded corners
                    border: Border.all(color: Colors.grey), // Optional: add border to the container
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0), // Padding around the input field
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            onChanged: (value) {
                              messageText = value;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              hintText: 'Type your message here...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (messageController.text.isEmpty) {
                              showCustomSnackbar(context, 'Enter text to send !');
                            } else {
                              if(widget.isTeacher==false){
                                //and dont change the value of teacherSideNewMessage

                                _firestore.collection('chat').doc(widget.teacherId + ' ' + widget.studentId).set({
                                  'teacherId': widget.teacherId,
                                  'studentId': widget.studentId,
                                  //we have new-message from student-side to be shown at teacher-side
                                  'studentSideNewMessage':true,
                                  'teacherSideNewMessage':false,
                                });
                              }else{
                                _firestore.collection('chat').doc(widget.teacherId + ' ' + widget.studentId).set({
                                  'teacherId': widget.teacherId,
                                  'studentId': widget.studentId,
                                  //we have new-message from student-side to be shown at teacher-side
                                  'studentSideNewMessage':false,
                                  'teacherSideNewMessage':true,
                                });
                              }

                              _firestore.collection('chat').doc(widget.teacherId + ' ' + widget.studentId).collection('messages').add({
                                'message': messageController.text,
                                'time': Timestamp.now(),
                                'user':(widget.isTeacher==true)?'teacher':'student',
                              });
                              messageController.clear();

                            }
                          },
                          child: Text(
                            'Send',
                            style: TextStyle(color: Theme.of(context).primaryColor), // Optional: Customize send button style
                          ),
                        ),
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
class MessageBubble extends StatelessWidget {
  final dynamic ddmmyy;
  final dynamic date;
  final dynamic msg;
  dynamic sender;//teacher ya to student
  bool isStudent;
  MessageBubble({this.ddmmyy,this.date,this.msg, this.sender, required this.isStudent});

  @override
  Widget build(BuildContext context) {
    //Material is customizable-widget
    ////We need to add padding around each MsgBubble
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Expanded(
        child: Column(
          crossAxisAlignment:
          (sender=='teacher') ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            // Text('$sender'),
            Material(
              elevation: 5.0,
              borderRadius: (sender=='teacher')
                  ? BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
                  : BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              color: (sender=='teacher') ? Colors.blueGrey: green,
              child: Column(
                crossAxisAlignment: (sender=='teacher')? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '$msg',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(ddmmyy.toString(),style: TextStyle(color: Colors.white,fontSize: 10),),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                    child: Text(date.toString(),style: TextStyle(color: Colors.white,fontSize: 8),),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//why context is used in flutter ?

// By using the context, you can create reusable widgets that can adapt to the environment and services they are used in,
// making it easier to create complex and flexible user interfaces.
//
// In Flutter, the context is passed down the widget tree from parent to child,
// allowing child widgets to access the context of their parent and ancestors.
// This makes it possible for widgets to use information from higher up in the tree,
//     without having to pass it down as an argument to every widget along the way.

