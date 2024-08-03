import 'package:flutter/material.dart';
import 'studentsignup.dart';
import 'package:assignmates/database/database.dart';
import 'package:assignmates/student/record.dart';
import 'package:assignmates/models/student.dart';

class StudentLoginScreen extends StatelessWidget {
  const StudentLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Login',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            margin: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // const SizedBox(height: 120),
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/th(4).jpeg'),
                  radius: 100,
                ),
                const SizedBox(height: 40),
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
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    Student? retVal=await AuthMethods().loginStudent(email.text, password.text);
                    if(retVal?.enroll!=''){
                      //fetch info corresponding to this user
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StudentRecords(name: retVal!.name,
                              email: retVal!.email,branch: retVal.branch!,enroll: retVal.enroll!,year: retVal.year!,section: retVal.section!,)),
                      );
                    }
                    // Handle sign-in logic here
                  },
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 20),
                const Text('If account does not exist?'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StudentSignupScreen()),
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
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'studentsignup.dart';
//
// class StudentLoginScreen extends StatelessWidget {
//   const StudentLoginScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Login',style: TextStyle(color: Colors.white),),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios ,color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Container(
//             margin: const EdgeInsets.all(25),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const SizedBox(height: 120,),
//                 const CircleAvatar(
//                   backgroundImage: AssetImage('assets/images/th(4).jpeg'),
//                   radius: 100,
//                 ),
//                 const SizedBox(height: 40),
//                 const TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const TextField(
//                   obscureText: true,
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle sign-in logic here
//                   },
//                   child: const Text('Sign In'),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text('If account does not exist?'),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const StudentSignupScreen()),
//                     );
//                   },
//                   child: const Text('Sign Up',style: TextStyle(decoration: TextDecoration.underline),),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }