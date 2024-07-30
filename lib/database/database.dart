import 'package:assignmates/models/student.dart';
import 'package:assignmates/models/teacher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAssignmentStream(){
    var _stream=_firestore.collection('assignments').snapshots();
    return _stream;
  }

  Future<Teacher> signUpTeacher(String email, String password, String fullName) async {
    try {
      // Create the user with email and password
      var authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Add user details to the 'teachers' collection
      await _firestore.collection('teachers').doc(authResult.user!.uid).set(
        {
          'id':authResult.user!.uid,
          'name': fullName,
          'email': email,
          'accountCreated': Timestamp.now(),
        },
      );
      Teacher _teacher=await getTeacherInfo(authResult.user!.uid);
      return _teacher;
    } catch (e) {
      // retval = e.toString();
    }
    return Teacher();
  }

  Future<Student> getStudentInfo(String id) async {
    var student = Student();
    try {
      DocumentSnapshot _documentSnapshot = await _firestore.collection('students').doc(id).get();
      if (_documentSnapshot.exists) {
        // Check if the document exists
        Map<String, dynamic> data = _documentSnapshot.data() as Map<String, dynamic>;
        student.name = data['name'] ?? '';
        student.email = data['email'] ?? '';
        student.enroll = data['enroll'] ?? '';
        student.branch = data['class'] ?? '';
        student.accountCreated = data['accountCreated'] ?? '';
      } else {
        print('Cannot fetch student info');
      }
    } catch (e) {
      print('Error fetching student info: $e');
    }
    return student;
  }

  Future<Teacher> getTeacherInfo(String id) async {
    var teacher = Teacher();
    try {
      DocumentSnapshot _documentSnapshot = await _firestore.collection('teachers').doc(id).get();
      if (_documentSnapshot.exists) {
        // Check if the document exists
        Map<String, dynamic> data = _documentSnapshot.data() as Map<String, dynamic>;
        teacher.name = data['name'] ?? '';
        teacher.email = data['email'] ?? '';
        teacher.id=data['id'];
      } else {
        print('Cannot fetch teacher info');
      }
    } catch (e) {
      print('Error fetching teacher info: $e');
    }
    return teacher;
  }

  Future<String> signUpStudent(String email, String password, String fullName, String enroll, String class1) async {
    String retval = "error";
    try {
      // Create the user with email and password
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Add user details to the 'students' collection
      await _firestore.collection('students').doc(authResult.user!.uid).set(
        {

          'email': email,
          'name': fullName,
          'enroll': enroll,
          'class': class1,
          'accountCreated': Timestamp.now(),
        },
      );

      retval = "success";
    } catch (e) {
      retval = e.toString();
    }
    return retval;
  }

  Future<Teacher?> loginTeacher(String email, String password) async {
    try {
      var _authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return await getTeacherInfo(_authResult.user!.uid);
    } catch (e) {
      print('Error logging in teacher: $e');
      return null;
    }
  }

  Future<Student?> loginStudent(String email, String password) async {
    try {
      var _authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return await getStudentInfo(_authResult.user!.uid);
    } catch (e) {
      print('Error logging in student: $e');
      return null;
    }
  }
  // }
  Stream getTeachersStream(){
    var _stream=_firestore.collection('teachers').snapshots();
    return _stream;
  }
}
