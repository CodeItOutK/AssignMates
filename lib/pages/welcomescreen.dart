import 'package:flutter/material.dart';
import 'teacherlogin.dart';
import 'studentlogin.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,height: 200,
                child:Image.asset(
                  'assets/images/davvlogo1.png', // Add your welcome image asset here
                  height: 180,
                  width: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Text(
                    'Welcome to',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    'AssignMates@IET-DAVV',
                    style: TextStyle(
                      fontSize: 24,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Select Profile',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TeacherLoginScreen()),
                      );
                    },
                    child: const Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/th(1).jpeg'), // Add your student image asset herefit: BoxFit.cover
                        ),
                        SizedBox(height: 10),
                        Text('Teacher',style: TextStyle(decoration: TextDecoration.underline)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudentLoginScreen()),
                      );
                    },
                    child: const Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/images/th(3).jpeg'), // Add your student image asset here
                        ),
                        SizedBox(height: 10),
                        Text('Student',style: TextStyle(decoration: TextDecoration.underline),),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}