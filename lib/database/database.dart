import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpTeacher(String email, String password, String fullName) async {
    String retval = "error";
    try {
      // Create the user with email and password
      var authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Add user details to the 'teachers' collection
      await _firestore.collection('teachers').doc(authResult.user!.uid).set(
          {
            'name':fullName,
            'email':email,
            'accountCreated':Timestamp.now(),
          }
      );

      retval = "success";
    } catch (e) {
      retval = e.toString();
    }
    return retval;
  }
  Future<String> signUpStudent(String email, String password, String fullName,String enroll,String class1) async {
    String retval = "error";
    try {
      // Create the user with email and password
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Add user details to the 'teachers' collection
      await _firestore.collection('students').doc(authResult.user!.uid).set(
          {
            'email':email,
            'name':fullName,
            'enroll':enroll,
            'class':class1,
            'accountCreated':Timestamp.now(),
          }
      );

      retval = "success";
    } catch (e) {
      retval = e.toString();
    }
    return retval;
  }

  Future<String> loginTeacher(String email, String password) async {
    String retVal = "error";
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      retVal = "success";
    } catch (e) {
      print(e);
      retVal = e.toString();
    }
    return retVal;
  }
  Future<String> loginStudent(String email, String password) async {
    String retVal = "error";
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      retVal = "success";
    } catch (e) {
      print(e);
      retVal = e.toString();
    }
    return retVal;
  }
}
