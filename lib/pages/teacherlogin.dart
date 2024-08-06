import 'package:assignmates/models/teacher.dart';
import 'package:assignmates/utilities/showSnackbar.dart';
import 'package:flutter/material.dart';
import 'package:assignmates/teacher/history.dart';
import 'teachersignup.dart';
import 'package:assignmates/database/database.dart';

class TeacherLoginScreen extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Login',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 120,
                backgroundImage: AssetImage('assets/images/teacher.jpg'), // Add your teacher image asset here
              ),
              const SizedBox(height: 20),
              TextField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // login teacher
                  Teacher? retVal=await AuthMethods().loginTeacher(email.text, password.text);
                  if(retVal==null){
                    showCustomSnackbar(context, 'Wrong Credentials');
                  }else{
                    var _id=retVal!.id;
                    print('id---->>>>>');
                    print(_id);
                    //get name of the teacher
                    if(retVal!.name!=''){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => History(name: retVal!.name,id:_id)),
                      );
                    }
                  }
                },
                child: const Text('Log In'),
              ),
              const SizedBox(height: 20),
              const Text('If account do not exist?'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TeacherSignupScreen()),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}