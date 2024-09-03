// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'chat_message_type.dart';
// import 'chat_message_widget_dpyt.dart';
//
//
//
// class ChatBotScreen extends StatefulWidget {
//   const ChatBotScreen({super.key});
//
//   @override
//   State<ChatBotScreen> createState() => _ChatBotScreenState();
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
// class _ChatBotScreenState extends State<ChatBotScreen> {
//   TextEditingController textController = TextEditingController();
//   final scrollController = ScrollController();
//   List<ChatMessage>messages = [];
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
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:Text("AI Tutor"),
//         centerTitle: true,
//       ),
//
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child:ListView.builder(
//                 controller: scrollController,
//                 itemCount: messages.length,
//                 itemBuilder: (context,index){
//                   var message = messages[index];
//                   return ChatMessageWidget(text: message.text,chatMessageType: message.chatMessageType,);
//                 },
//               ),
//             ),
//             Visibility(
//               visible: isLoading,
//                 child: Padding(
//                   padding: EdgeInsets.all(8),
//                   child: CircularProgressIndicator(
//                     color: Colors.white,
//                   ),
//                 )
//             ),
//             Padding(padding: EdgeInsets.all(8),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       textCapitalization: TextCapitalization.sentences,
//                       style: TextStyle(color: Colors.white),
//                       controller: textController,
//                       decoration: InputDecoration(
//                         fillColor: Color(0xFF444654),
//                         filled: true,
//                         border: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                         errorBorder: InputBorder.none,
//                         disabledBorder: InputBorder.none
//                       ),
//                     ),
//                   ),
//                   Visibility(
//                       visible: !isLoading,
//                       child:Container(
//                         child: IconButton(
//                           icon: Icon(Icons.send_rounded,
//                           color: Color.fromRGBO(142, 142, 160, 1)
//                           ),
//                           onPressed: ()async{
//                             setState(() {
//                               messages.add(ChatMessage(
//                                   text: textController.text,
//                                   chatMessageType: ChatMessageType.user,
//                               ),
//                               );
//                               isLoading=true;
//                             });
//                             var input = textController.text;
//                             textController.clear();
//                             Future.delayed(Duration(milliseconds: 50)).then((_) =>
//                             scrollDown()
//                             );
//                             generateResponse(input).then((value){
//                               setState(() {
//                                 isLoading = false;
//                                 messages.add(
//                                  ChatMessage(text: value, chatMessageType: ChatMessageType.bot)
//                                 );
//                               });
//                               textController.clear();
//                               Future.delayed(Duration(milliseconds: 50)).then((_) => scrollDown());
//                             });
//                           },
//                         ),
//                       )
//                   ),
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// /*
// My secret key
// sk-Vlu-J6gKiVo7tdhZR8K4biQi__Q_3L-vwYvp1AMQvZT3BlbkFJCSjYPUAwdZqBoNGVOUSVovtTFqvC9DR-7Nv7U4L3QA
//
// yt code- https://www.youtube.com/watch?v=gjlr55zvxTY
//
// */
//
//
