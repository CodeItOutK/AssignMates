import 'package:assignmates/database/database.dart';
import 'package:flutter/material.dart';
import 'package:assignmates/student/record.dart';

class StudentSignupScreen extends StatelessWidget {
  const StudentSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController name = TextEditingController();
    TextEditingController enroll = TextEditingController();
    TextEditingController email = TextEditingController();
    TextEditingController password = TextEditingController();
    String? branch; // Make branch nullable

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Signup',
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/th(4).jpeg'),
                radius: 100,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Class',
                  border: OutlineInputBorder(),
                ),
                items: ['CSA', 'IT', 'MECH', 'E&I', 'CIVIL', 'ETC']
                    .map((classOption) => DropdownMenuItem<String>(
                  value: classOption,
                  child: Text(classOption),
                ))
                    .toList(),
                onChanged: (value) {
                  branch = value;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: enroll,
                decoration: const InputDecoration(
                  labelText: 'Enrollment No.',
                  border: OutlineInputBorder(),
                ),
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
                  String retVal=await AuthMethods().signUpStudent(email.text, password.text, name.text,enroll.text,branch!);
                  if(retVal=="success"){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StudentRecords(name: name.text,email: email.text,enroll: enroll.text,branch: branch!,)),
                    );
                  }
                  // Handle sign-up logic here
                  // Example: AuthMethods.signUpUser(email.text, password.text, name.text, enroll.text, branch)
                },
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// class StudentSignupScreen extends StatelessWidget {
//   const StudentSignupScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Signup',style: TextStyle(color: Colors.white),),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios ,color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircleAvatar(
//                 backgroundImage: AssetImage('assets/images/th(4).jpeg'),
//                 radius: 100,
//               ),
//               const SizedBox(height: 20),
//               const TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: 'Class',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: ['CSA', 'IT', 'MECH', 'E&I', 'CIVIL', 'ETC']
//                     .map((classOption) => DropdownMenuItem<String>(
//                   value: classOption,
//                   child: Text(classOption),
//                 ))
//                     .toList(),
//                 onChanged: (value) {
//                   // Handle class selection
//                 },
//               ),
//               const SizedBox(height: 20),
//               const TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Enrollment No.',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const TextField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'Password',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   // Handle sign-up logic here
//                   // AuthMethods.signUpUser()
//                 },
//                 child: const Text('Sign Up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }