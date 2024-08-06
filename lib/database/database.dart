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

  Stream<QuerySnapshot> getAssignmentStream() {
    var _stream = _firestore.collection('assignments').snapshots();
    return _stream;
  }

  Future<Teacher> signUpTeacher(String email, String password,
      String fullName) async {
    try {
      // Create the user with email and password
      var authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Add user details to the 'teachers' collection
      await _firestore.collection('teachers').doc(authResult.user!.uid).set(
        {
          'id': authResult.user!.uid,
          'name': fullName,
          'email': email,
          'accountCreated': Timestamp.now(),
        },
      );
      Teacher _teacher = await getTeacherInfo(authResult.user!.uid);
      return _teacher;
    } catch (e) {
      // retval = e.toString();
    }
    return Teacher();
  }

  Future<Student> getStudentInfo(String id) async {
    var student = Student();
    try {
      DocumentSnapshot _documentSnapshot = await _firestore.collection(
          'students').doc(id).get();
      if (_documentSnapshot.exists) {
        // Check if the document exists
        Map<String, dynamic> data = _documentSnapshot.data() as Map<
            String,
            dynamic>;
        student.name = data['name'] ?? '';
        student.email = data['email'] ?? '';
        student.enroll = data['enroll'] ?? '';
        student.branch = data['branch'] ?? '';
        student.accountCreated = data['accountCreated'] ?? '';
        student.section = data['section'] ?? '';
        student.year = data['year'] ?? '';
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
      DocumentSnapshot _documentSnapshot = await _firestore.collection(
          'teachers').doc(id).get();
      if (_documentSnapshot.exists) {
        // Check if the document exists
        Map<String, dynamic> data = _documentSnapshot.data() as Map<
            String,
            dynamic>;
        teacher.name = data['name'] ?? '';
        teacher.email = data['email'] ?? '';
        teacher.id = data['id'];
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
      DocumentSnapshot _documentSnapshot = await _firestore.collection(
          'teachers').doc(id).get();
      if (_documentSnapshot.exists) {
        // Check if the document exists
        Map<String, dynamic> data = _documentSnapshot.data() as Map<
            String,
            dynamic>;
        return data['name'] ?? '';
      } else {
        print('Cannot fetch teacher info');
      }
    } catch (e) {
      print('Error fetching teacher info: $e');
    }
    return 'unavaialable';
  }

  Future<String> signUpStudent(String email, String password, String fullName,
      String enroll, String branch, String section, String year) async {
    String retval = "error";
    try {
      // Create the user with email and password
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Add user details to the 'students' collection
      await _firestore.collection('students').doc(authResult.user!.uid).set(
        {

          'email': email,
          'name': fullName,
          'enroll': enroll,
          'branch': branch,
          'accountCreated': Timestamp.now(),
          'section': section,
          'year': year,
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
      var _authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
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
  Stream getTeachersStream() {
    var _stream = _firestore.collection('teachers').snapshots();
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
      return data?['name'] ??
          'Unknown'; // Default to 'Unknown' if name field is missing
    } else {
      return 'Teacher not found';
    }
  }

  Future<void> doneWithAnAssignment(String assId, String teacherId,
      List<File> files) async {
    String studentId = _auth.currentUser!.uid;
    // DocumentSnapshot _docRef = await _firestore.collection('students').doc(studentId).get();

    List<Map<String, dynamic>> doneAssignment = [];

    try {
      // Upload files to Firebase Storage and get URLs
      List<String> fileUrls = [];
      for (File file in files) {
        String fileName = basename(file.path);
        Reference storageRef = FirebaseStorage.instance.ref().child(
            'assignments/$assId/$fileName');
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

  String getCurrentUser() {
    return _auth.currentUser!.uid;
  }

  //get students submissions from submitted-assignments
  getDoneAssignments() {
    // String currentTeacherId=_auth.currentUser!.uid;
    var stream = _firestore.collection('doneAssignments').snapshots();
    return stream;
  }

  Future<void>overDueAssignments(String assId,String teacherId)async{
    List<Map<String, dynamic>> overdueAssignment = [];
    String studentId=_auth.currentUser!.uid;
    Map<String, dynamic> assignmentData = {
      'teacherId': teacherId,
      'studentId': studentId,
      // 'timeOfSubmit': Timestamp.now(),
    };

    overdueAssignment.add(assignmentData);

    // Update Firestore
    await _firestore.collection('blockedAssignment').doc(assId).set({
      'submissions':FieldValue.arrayUnion(overdueAssignment),
    }, SetOptions(merge: true));
  }

  Future<List<Student>> getDefaulterList(String assId)async{
    List<Student> studentModels = [];

    try {
      // Get the document snapshot asynchronously
      DocumentSnapshot<Map<String, dynamic>> _docRef = await FirebaseFirestore.instance
          .collection('blockedAssignment')
          .doc(assId)
          .get();

      if (_docRef.exists) {
        // Access the 'submissions' array from the document
        List<dynamic> submissions = _docRef.data()?['submissions'] ?? [];

        // Iterate through each submission map and extract the studentId
        for (var submission in submissions) {
          if (submission is Map<String, dynamic> && submission.containsKey('studentId')) {
            // submission['studentId'];
            Student _student=await getStudentInfo(submission['studentId']);
            studentModels.add(_student);
          }
        }
      }
    } catch (e) {
      print('Error fetching student IDs: $e');
    }
    return studentModels;
  }

// Get all the Student IDs who were assigned this assignment
  Future<List<String>> getClassesForAnAssignment(String assId) async {
    List<String> classes = [];

    // Get the document snapshot asynchronously
    DocumentSnapshot _docRef = await _firestore.collection('assignments').doc(
        assId).get();

    // Safely access the data from the document
    var data = _docRef.data() as Map<String, dynamic>?;

    if (data != null) {
      List<Map<String, dynamic>> classInDb = List<Map<String, dynamic>>.from(
          data['classes']);
      for (var v in classInDb) {
        classes.add('${v['branch']} ${v['section']} ${v['year']}');
      }
    }
    print('2');
    return await getStudentForThisAssignment(classes);
  }
//
// // Get all students that belong to the classes related to the assignment
  Future<List<String>> getStudentForThisAssignment(List<String> classes) async {
    List<String> students = [];
    try {
      // Get all documents from the 'students' collection
      QuerySnapshot querySnapshot = await _firestore.collection('students')
          .get();

      // Loop through each document in the collection
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Access the branch, section, and year
        var branch = data['branch'];
        var section = data['section'];
        var year = data['year'];

        String class1 = '$branch $section $year';
        if (classes.contains(class1)) {
          students.add(doc.id); // Add student ID
        }
      }
    } catch (e) {
      print('Error fetching student info: $e');
    }
    print('3');
    return students;
  }
//
// // Get the IDs of students who have completed the assignment
  Future<dynamic> studentsDoneThatAssignment(String assId) async {
    List<String> ids = []; // IDs of students who submitted
    DocumentSnapshot<Map<String, dynamic>> _querySnapshot = await _firestore
        .collection('doneAssignments')
        .doc(assId).get();

    if (_querySnapshot.exists) {
      // Access the 'submissions' array from the document
      List<dynamic> submissions = _querySnapshot.data()?['submissions'] ?? [];

      // Iterate through each submission map and extract the studentId
      for (var submission in submissions) {
        if (submission is Map<String, dynamic> && submission.containsKey('studentId')) {
          // submission['studentId'];
          String _studentId=submission['studentId'];
          ids.add(_studentId);
        }
      }
      return ids;
    }

    // for (var doc in _querySnapshot.data().forEach((key, value) { })) {
    //   var data = doc.data() as Map<String, dynamic>;
    //   ids.add(data[]['studentId']);
    // }
    // print('4');
    // return ids;
  }
  //COPY OF ABOVE-todo
  // Future<List<String>> studentsDoneThatAssignment(String assId) async {
  //   List<String> ids = []; // IDs of students who submitted
  //   QuerySnapshot _querySnapshot = await _firestore
  //       .collection('doneAssignments')
  //       .doc(assId)
  //       .collection('submissions')
  //       .get();
  //
  //   for (var doc in _querySnapshot.docs) {
  //     var data = doc.data() as Map<String, dynamic>;
  //     ids.add(data['studentId']);
  //   }
  //   print('4');
  //   return ids;
  // }

// Get the IDs of students who are defaulters for the assignment
  Future<List<String>> defaulterStudentIds(String assId) async {
    print('1');
    List<String> givenList =
        await getClassesForAnAssignment(assId);
    List<String> doneList = await studentsDoneThatAssignment(assId);
    Set<String> difference = givenList.toSet()
        .difference(doneList.toSet())
        .cast<String>();
    List<String> differenceList = difference.toList();
    print('5');
    return differenceList;
  }


//   //saare StudentIds jinhe ye assign diya tha
//   Future<List<String>> getClassesForAnAssignment(String assId) async {
//     List<String> classes = [];
//
//     // Get the document snapshot asynchronously
//     DocumentSnapshot _docRef = await _firestore.collection('assignments').doc(assId).get();
//
//     // Safely access the data from the document
//     var data = _docRef.data() as Map<String, dynamic>?;
//
//     if (data != null) {
//       List<Map<String,dynamic>>classInDb=data['classes'];
//       for(var v in classInDb){
//         classes.add( v['branch']+' '+v['section']+' '+v['year'] );
//       }
//     }
//     print('2');
//     return await getStudentForThisAssignment(classes);
//   }
//
//   Future<List<String>> getStudentForThisAssignment(List<String> classes) async {
//     List<String> students = [];
//     try {
//       // Get all documents from the 'students' collection
//       QuerySnapshot querySnapshot = await _firestore.collection('students').get();
//
//       // Loop through each document in the collection
//       for (var doc in querySnapshot.docs) {
//         var data = doc.data() as Map<String, dynamic>;
//
//         // Access the branch, section, and year
//         var branch = data['branch'];
//         var section = data['section'];
//         var year = data['year'];
//
//         String class1=branch+' '+section+' '+year;
//         if(classes.contains(class1)){
//           students.add(class1);
//         }
//       }
//     } catch (e) {
//       print('Error fetching student info: $e');
//     }
//     print('3');
//     return students;
//   }
//
//   //todo->>>>>>>>implement fully
//   //donelist
//   //frontend se yha aaye
//   Future<List<String>> studentsDoneThatAssignment(String assId)async{
//     List<String>ids=[];//jin students ne submit kiya h
//     DocumentSnapshot _docRef=_firestore.collection('doneAssignments').doc(assId).collection('submissions').get() as DocumentSnapshot<Object?>;
//
//     if (_docRef.exists) {
//       // Assuming the teacher's name is stored under the 'name' field
//       List<Map<String, dynamic>>? data = _docRef.data() as List<Map<String, dynamic>>?;
//       for(var v in data!){
//         ids.add(v['studentId']);
//       }
//     }
//     print('4');
//     return ids;
//   }
//   //ids of defaulter students
//   Future<List<String>> defaulterStudentIds(String assId)async{
//     print('1');
//     List<String>givenList=await getClassesForAnAssignment(assId);
//     List<String>doneList=await studentsDoneThatAssignment(assId);
//     Set<String> difference = givenList.toSet().difference(doneList.toSet()).cast<String>();
//     List<String> differenceList = difference.toList();
//     print('5');
//     return differenceList;
//   }
//
// }
  Future<List<String>> getAllTeachersForAStudent(String branch,String section,String year) async{
    Set<String>allTeachersId={};
    QuerySnapshot _allAssIds=await _firestore.collection('assignments').get();
    for (var v in _allAssIds.docs){
      // List<Map<String,dynamic>>allClasses=v['classes'];
      List<dynamic> allClasses = v['classes'] as List<dynamic>;
      for(var c in allClasses){
        if(c['branch']==branch && c['section']==section && c['year']==year){
          allTeachersId.add(v['teacherId']);
        }
      }
    }
    return allTeachersId.toList();
  }

  getChatStreamForStudents(String teacherId,String studentId){
    return _firestore.collection('chat').doc(teacherId+' '+studentId).collection('messages').orderBy('time',descending: true).snapshots();
  }

  getChatModel(String teacherId)async{
    List<String>docIds=[];
    QuerySnapshot _qs=await _firestore.collection('chat').get();
    for (var v in _qs.docs){
      if(v['teacherId']==teacherId){
        docIds.add(v.id);
      }
    }
    return docIds;
  }

  getStudentsModelsFromChatIds(List<String>docIds)async{
    List<Student>studentModel=[];
    for(var id in docIds){
      DocumentSnapshot _ds=await _firestore.collection('chat').doc(id).get();
      studentModel.add(await getStudentInfo(_ds['studentId']));
    }
    return studentModel;
  }

  getStudentIdsFromChatIds(List<String>docIds)async{
    List<String>studentIds=[];
    for(var id in docIds){
      DocumentSnapshot _ds=await _firestore.collection('chat').doc(id).get();
      studentIds.add(_ds['studentId']);
    }
    return studentIds;
  }
  //SEEN FUNC FROM TEACHER-SIDE
  //false->grey border
  seenStatusForRecentMessage(String teacherId,String studentId)async{
    bool isSeen=false;//show color
    DocumentSnapshot _docSnap=await _firestore.collection('chat').doc(teacherId+' '+studentId).get();
    if(_docSnap['studentSideNewMessage']==false){
      return false;
    }else{//msg is alredy seen
      return true;
    }
    return isSeen;
  }
  flipSeenStatus(String teacherId,String studentId,bool isTeacher)async{
      //and dont change the value of teacherSideNewMessage
    if(isTeacher){
      dynamic pvsValTeacherSideNewMessage=await getExistingValueOfTeacherSideNewMessage(teacherId, studentId);
      await _firestore.collection('chat').doc(teacherId+' '+studentId).set({
        'studentId':studentId,
        'teacherId':teacherId,
        'studentSideNewMessage':false,
        'teacherSideNewMessage':pvsValTeacherSideNewMessage,
      });
    }else{
      //student ne teacher side ka new message dekh liya h
      dynamic pvsValStudentSideNewMessage=await getExistingValueOfStudentSideNewMessage(teacherId, studentId);
      await _firestore.collection('chat').doc(teacherId+' '+studentId).set({
        'studentId':studentId,
        'teacherId':teacherId,
        'studentSideNewMessage':pvsValStudentSideNewMessage,
        'teacherSideNewMessage':false,
      });
    }


  }
  getExistingValueOfTeacherSideNewMessage(String teacherId,String studentId)async{
    DocumentSnapshot<Map<String, dynamic>>docSnap=await _firestore.collection('chat').doc(teacherId+' '+studentId).get();
    return docSnap['teacherSideNewMessage'];
  }
  getExistingValueOfStudentSideNewMessage(String teacherId,String studentId)async{
    DocumentSnapshot<Map<String, dynamic>>docSnap=await _firestore.collection('chat').doc(teacherId+' '+studentId).get();
    return docSnap['studentSideNewMessage'];
  }

}
