// import 'package:assignmates/chat_bot/bot_yt_hussain_mustafa/consts.dart';
// import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
// import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
// import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
// import 'package:dash_chat_2/dash_chat_2.dart';
// import 'package:flutter/material.dart';
//
// import '../../theme.dart';
//
// class BotPage extends StatefulWidget {
//   const BotPage({super.key});
//
//   @override
//   State<BotPage> createState() => _BotPageState();
// }
//
// class _BotPageState extends State<BotPage> {
//
//   final _openAI = OpenAI.instance.build(
//       token:OPENAI_API_KEY,
//       baseOption: HttpSetup(
//           receiveTimeout:const Duration(seconds: 5)
//       ),
//       enableLog: true,
//   );
//
//
//   final ChatUser _currentUser = ChatUser(id: '1', firstName: 'You');
//   final ChatUser _gptChatUser = ChatUser(id: '2', firstName: 'AI Mentor');
//   List<ChatMessage> _messages = <ChatMessage>[];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Chat with Mentor",
//         style: TextStyle(color: Colors.white),),
//         centerTitle: true,
//       ),
//       body: DashChat(currentUser: _currentUser,
//           messageOptions: const MessageOptions(
//             currentUserContainerColor: Colors.blueAccent,
//             textColor: Colors.white
//           ),
//           onSend: (ChatMessage m){
//             getChatResponse(m);
//           },
//           messages: _messages),
//     );
//   }
//
//   Future<void> getChatResponse(ChatMessage m)async{
//     setState(() {
//       _messages.insert(0,m);
//     });
//     List<Messages> _messagesHistory = _messages.reversed.map((m) {
//       if(m.user== _currentUser){
//         return Messages(role: Role.user,content: m.text);
//       }
//       else {
//         return Messages(role: Role.assistant,content: m.text);
//       }
//     }).toList();
//
//     final request = ChatCompleteText(
//         model:GptTurboChatModel(),
//         messages: _messagesHistory,
//         maxToken: 200
//     );
//
//     final response = await _openAI.onChatCompletion(request: request);
//     for(var elem in response!.choices){
//       if(elem.message!=null){
//         setState(() {
//           _messages.insert(
//               0,
//               ChatMessage(
//                   user: _gptChatUser,
//                   createdAt:DateTime.now(),
//                   text: elem.message!.content)
//           );
//         });
//       }
//     }
//
//   }
//
// }
