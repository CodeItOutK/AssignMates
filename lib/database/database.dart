import 'dart:io';
import 'package:assignmates/models/assignments.dart';
import 'package:assignmates/models/student.dart';
import 'package:assignmates/models/teacher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

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
        student.branch = data['branch'] ?? '';
        student.accountCreated = data['accountCreated'] ?? '';
        student.section=data['section']??'';
        student.year=data['year']??'';
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

  Future<String> getAssignmentName(String id) async {

    // title: title, id: id, teacherId: teacherId, fileUrls: fileUrls, classes: classes, instructions: instructions, deadline: deadline
    try {
      DocumentSnapshot _documentSnapshot = await _firestore.collection('teachers').doc(id).get();
      if (_documentSnapshot.exists) {
        // Check if the document exists
        Map<String, dynamic> data = _documentSnapshot.data() as Map<String, dynamic>;
        return data['name'] ?? '';
      } else {
        print('Cannot fetch teacher info');
      }
    } catch (e) {
      print('Error fetching teacher info: $e');
    }
    return 'unavaialable';
  }

  Future<String> signUpStudent(String email, String password, String fullName, String enroll, String branch,String section,String year) async {
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
          'branch': branch,
          'accountCreated': Timestamp.now(),
          'section':section,
          'year':year,
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

  Future<String> getTeacherNameFromId(String teacherId) async {
    // Fetch the document from the 'teachers' collection using the teacherId
    DocumentSnapshot _docRef = await FirebaseFirestore.instance
        .collection('teachers')
        .doc(teacherId)
        .get();

    // Check if the document exists and retrieve the 'name' field
    if (_docRef.exists) {
      // Assuming the teacher's name is stored under the 'name' field
      Map<String, dynamic>? data = _docRef.data() as Map<String, dynamic>?;
      return data?['name'] ?? 'Unknown'; // Default to 'Unknown' if name field is missing
    } else {
      return 'Teacher not found';
    }
  }

  Future<void> doneWithAnAssignment(String assId, String teacherId, List<File> files) async {
    String studentId = _auth.currentUser!.uid;
    // DocumentSnapshot _docRef = await _firestore.collection('students').doc(studentId).get();

    List<Map<String, dynamic>> doneAssignment = [];

  try {
  // Upload files to Firebase Storage and get URLs
  List<String> fileUrls = [];
  for (File file in files) {
    String fileName = basename(file.path);
    Reference storageRef = FirebaseStorage.instance.ref().child('assignments/$assId/$fileName');
    UploadTask uploadTask = storageRef.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    fileUrls.add(downloadUrl);
  }

  // Create the assignment submission data
  Map<String, dynamic> assignmentData = {
    'teacherId': teacherId,
    'studentId': studentId,
    'timeOfSubmit': Timestamp.now(),
    'files': fileUrls,
  };

  doneAssignment.add(assignmentData);

  // Update Firestore
  await _firestore.collection('doneAssignments').doc(assId).set({
  'submissions': FieldValue.arrayUnion(doneAssignment),
  }, SetOptions(merge: true));

  } catch (e) {
  print(e.toString());
  }
  }

  String getCurrentUser (){
    return _auth.currentUser!.uid;
  }

  //get students submissions from submitted-assignments
  getDoneAssignments(){
    // String currentTeacherId=_auth.currentUser!.uid;
    var stream=_firestore.collection('doneAssignments').snapshots();
    return stream;
  }
  //todo->>>>>>>>implement fully
  Future<List<String>> studentsDoneThatAssignment(String assId)async{
    List<String>ids=[];
    DocumentSnapshot _docRef=_firestore.collection('doneAssignments').doc(assId).collection('submissions').get() as DocumentSnapshot<Object?>;

    if (_docRef.exists) {
      // Assuming the teacher's name is stored under the 'name' field
      List<Map<String, dynamic>>? data = _docRef.data() as List<Map<String, dynamic>>?;
      for(var v in data!){
        ids.add(v['studentId']);
      }
    }
    return ids;
  }


}
