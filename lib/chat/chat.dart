import 'package:assignmates/database/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';//for conversions of date-time into required formats

class ChatScreen extends StatefulWidget {

  dynamic teacherId;
  dynamic studentId;

  ChatScreen({this.teacherId,this.studentId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  dynamic messageText;
  TextEditingController messageController=new TextEditingController();//for clearing the message
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  dynamic _stream;
  dynamic _currentUserName;
  bool _loading=true;
  @override
  void getDetails(){
    // _stream=OurDatabase().getMessageStream(widget.grpId);
  }
  void initState() {
    // TODO: implement initState
    getDetails();//streams are a-synchronous
    setState(() {
      _loading=false;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //different preview of chat-messages corresponding to different users

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF679289),
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
                  child: Icon(Icons.home,color: Colors.green,size: 20,)),),
            ),
          ),
        ],
        title: Row(
          children: [
            Icon(Icons.message_outlined,color: Colors.white,size: 40,),
            Text('Chat with Members :)',style: TextStyle(color: Colors.brown,fontFamily: 'Cabin',fontWeight:FontWeight.bold),),
          ],
        ),
      ),
      backgroundColor: Color(0xFFFFFACA),
      body: SafeArea(
        child: Column(
          children: [

                    Text('Student Id:${widget.studentId}'),
                    Text('Teacher Id:${widget.teacherId}'),

            // StreamBuilder<QuerySnapshot>(
            //     stream: _stream,
            //     builder: (context, snapshot) {
            //       //snapshot dosent have data ->show spinner there
            //       if (!snapshot.hasData) {
            //         return Center(
            //           child: CircularProgressIndicator(
            //             backgroundColor: Color(0xFF679289), //will spin for no-data and as soon data is ready it will get destroyed.
            //           ),
            //         );
            //       }
            //       final messages = snapshot.data!.docs;
            //       List<MessageBubble>allMessages=[];
            //       for(var msg in messages){
            //         final dynamic _msg = msg['message'];
            //         final dynamic _sender= msg['user'];
            //         final dynamic _timeFromDB=msg['time'];//time jb vo db me add hue
            //         //convert dateTime.now()into required formats
            //         final dynamic ddmmyyyy= DateFormat.Hm().format(_timeFromDB.toDate());
            //         final dynamic date=DateFormat('dd/MM/yyyy').format(_timeFromDB.toDate());
            //         // Output will be in hour:minute format (e.g., 12:34)
            //         bool _isMe=false;
            //         if(_sender==_currentUserName)_isMe=true;
            //         MessageBubble _bubble=MessageBubble(msg: _msg,sender: _sender,isMe: _isMe,date: date,ddmmyy: ddmmyyyy,);
            //         allMessages.add(_bubble);
            //       }
            //       return Expanded(
            //         child: Column(
            //           children: [
            //             Text('Student Id:${widget.studentId}'),
            //             Text('Student Id:${widget.teacherId}'),
            //           ],
            //         ),
            //         //take up as much space available
            //         // child: ListView(
            //         //   //ListView -> alternative to Column Widget
            //         //   reverse:
            //         //   true, //sticky to the end->neeche se upr scroll kro
            //         //   padding:
            //         //   EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            //         //   children: allMessages,
            //         // ),
            //       );
            //       // return Container();
            //     }),
            Container(
              // decoration: ourTheme().kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        //clear the TextField as soon as send button is pressed.
                        messageText = value;
                      },
                      // decoration: ourTheme().kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // DateTime now = DateTime.now();
                      // createdon = now;
                      // _firestore.collection('groups').doc(widget.grpId).collection('messages').add({
                      //   'message':messageController.text,
                      //   'user':_currentUserName,
                      //   'time':Timestamp.now(),
                      // });
                      // messageController.clear();
                    },
                    child: Text(
                      'Send',
                      // style: ourTheme().kSendButtonTextStyle,
                    ),
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
class MessageBubble extends StatelessWidget {
  final dynamic ddmmyy;
  final dynamic date;
  final dynamic msg;
  final dynamic sender;
  final dynamic isMe;
  MessageBubble({this.ddmmyy,this.date,this.msg, this.sender, this.isMe});
  @override
  Widget build(BuildContext context) {
    //Material is customizable-widget
    ////We need to add padding around each MsgBubble
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Expanded(
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text('$sender'),
            Material(
              elevation: 5.0,
              borderRadius: isMe
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
              color: isMe ? Color(0xFF679289) : Colors.brown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '$msg',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
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

