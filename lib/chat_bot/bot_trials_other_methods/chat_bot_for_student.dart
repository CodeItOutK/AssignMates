// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// class ChatMessage{
//   final String text;
//   final bool isUser;
//
//   ChatMessage(this.text, this.isUser);
// }
//
//
// class StudentChatBotScreen extends StatefulWidget {
//   const StudentChatBotScreen({super.key});
//
//   @override
//   State<StudentChatBotScreen> createState() => _StudentChatBotScreenState();
// }
//
// Future<String> generateResponse(String prompt)async{
//   const apiKey = "sk-Vlu-J6gKiVo7tdhZR8K4biQi__Q_3L-vwYvp1AMQvZT3BlbkFJCSjYPUAwdZqBoNGVOUSVovtTFqvC9DR-7Nv7U4L3QA";
//   var url = Uri.https("api.openai.com","/v1/completions");
//   final response = await http.post(
//     url,
//     headers:{
//       "Content-Type" : "application/json",
//       "Authorization" : "Bearer $apiKey"
//     },
//     body: json.encode({
//       "model" : "text-davinci-003",
//       "prompt" : prompt,
//       "temperature" : 0,
//       "max-token" : 4000,
//       "top_p" : 0,
//       "frequency_penalty": 0.0,
//       "presence_penalty": 0.0
//     }),
//   );
//
//   Map<String,dynamic> newResponse = jsonDecode(response.body);
//
//   return newResponse['choices'][0]['text'];
//
// }
//
// class _StudentChatBotScreenState extends State<StudentChatBotScreen> {
//   TextEditingController messageController = TextEditingController();
//   final scrollController = ScrollController();
//   List<ChatMessage>chatMessages = [];
//   late bool isLoading;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     isLoading=false;
//   }
//
//   void scrollDown(){
//     scrollController.animateTo(
//         scrollController.position.maxScrollExtent,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut);
//   }
//
//   void sendMessage(String message)async{
//     final response = await http.post(Uri.parse('https://api.openai.com/v1/engines/text-davinci-003/completions'),
//       headers: {
//       'Content-Type': 'application/json',
//         'Authorization': 'Bearer $apikey',
//       },
//       body: json.encode({
//         'prompt' : message,
//         'max-tokens':50
//       })
//     );
//     if(response.statusCode==200){
//       final jsonResponse = json.decode(response.body);
//       setState(() {
//         chatMessages.add(ChatMessage(message, true));
//         chatMessages.add(ChatMessage(jsonResponse['choices'][0]['text'], false));
//       });
//     }
//     else{
//       print("Request failed with status : ${response.statusCode}");
//     }
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title:Text("AI Tutor"),
//           centerTitle: true,
//         ),
//
//         body: Column(
//           children: [
//             Expanded(
//                 child:ListView.builder(
//                   itemCount: chatMessages.length,
//                   itemBuilder: (context,index){
//                     final message = chatMessages[index];
//                     return ChatBubble(
//                       text:message.text,
//                       isUser: message.isUser,
//                     );
//                   },
//                 ),
//             ),
//             Padding(padding: EdgeInsets.all(8),
//               child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     cursorColor: Colors.white,
//                     controller: messageController,
//                     decoration: InputDecoration(hintText: "Send a message",hintStyle: TextStyle(color: Colors.white)),
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 IconButton(
//                   icon:const Icon(Icons.send),
//                   color: Colors.white,
//                   onPressed: (){
//                     sendMessage(messageController.text);
//                     messageController.clear();
//                   },
//                 ),
//               ],
//             ),
//             ),
//           ],
//         ),
//     );
//   }
// }
//
// class ChatBubble extends StatelessWidget {
//   final String text;
//   final bool isUser;
//   const ChatBubble({super.key, required this.text, required this.isUser});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
//         child: Row(
//           mainAxisAlignment: isUser?MainAxisAlignment.end:MainAxisAlignment.start,
//           children: [
//             if(!isUser)
//               CircleAvatar(
//                 backgroundColor: Colors.blue,
//                 child: Text("AI"),
//               ),
//               Container(
//                 constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width*0.7,
//                 ),
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: isUser?Colors.blue:Colors.grey,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(text, style: TextStyle(
//                   color: Colors.white,
//                 ),),
//               ),
//             if(isUser)
//               CircleAvatar(
//                 backgroundColor: Colors.green,
//                 child: Icon(Icons.person),
//               )
//           ],
//         ),
//     );
//   }
// }
//
// /*
// My secret key
// sk-Vlu-J6gKiVo7tdhZR8K4biQi__Q_3L-vwYvp1AMQvZT3BlbkFJCSjYPUAwdZqBoNGVOUSVovtTFqvC9DR-7Nv7U4L3QA
// */
//
// // import 'dart:async';
// // import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
// // import 'package:flutter/material.dart';
// // import 'package:assignmates/theme.dart';
// //
// // import 'chatMessageForBot.dart';
// // class StudentChatBotScreen extends StatefulWidget {
// //   const StudentChatBotScreen({super.key});
// //
// //   @override
// //   State<StudentChatBotScreen> createState() => _StudentChatBotScreenState();
// // }
// //
// // class _StudentChatBotScreenState extends State<StudentChatBotScreen> {
// //   final TextEditingController _controller = TextEditingController();
// //   final List<ChatMsgForBot> _messages = [];
// //   OpenAI? chatGPT;
// //   StreamSubscription? _subscription;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     chatGPT=OpenAI.instance;
// //   }
// //   @override
// //   void dispose() {
// //     _subscription?.cancel();
// //     super.dispose();
// //   }
// //
// //   void _sendMessage(){
// //     ChatMsgForBot _message = ChatMsgForBot(text: _controller.text, sender: "user");
// //     setState(() {
// //       _messages.insert(0,_message);
// //     });
// //     _controller.clear();
// //     final request = CompleteReq()
// //   }
// //   Widget _buildTextComposer(){
// //     return Padding(
// //       padding: const EdgeInsets.all(8),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: TextField(
// //               cursorColor: Colors.white,
// //               onSubmitted: (value)=>_sendMessage(),
// //               controller: _controller,
// //               decoration: InputDecoration(hintText: "Send a message",hintStyle: TextStyle(color: Colors.white)),
// //               style: TextStyle(color: Colors.white),
// //             ),
// //           ),
// //           IconButton(
// //             icon:const Icon(Icons.send),
// //             color: Colors.white,
// //             onPressed: (){
// //               _sendMessage();
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title:Text("AI Tutor"),
// //         centerTitle: true,
// //       ),
// //       body:SafeArea(
// //         child: Column(
// //           children:[
// //             Flexible(
// //               child: ListView.builder(
// //                 reverse: true,
// //                 padding: EdgeInsets.all(8),
// //                 itemCount: _messages.length,
// //                   itemBuilder: (context,index){
// //                     return _messages[index];
// //                 }
// //               ),
// //             ),
// //             Container(
// //               decoration:BoxDecoration(
// //                 color :pblue,
// //               ),
// //               child: _buildTextComposer(),
// //             ),
// //           ]
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
