import 'package:flutter/material.dart';
class History extends StatelessWidget {
  final String name;
  const History({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Teacher ${name} \'s dashboard",style: TextStyle(color: Colors.white),),
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(child:Text('Upload Assignments'),),
      ),
    );
  }
}