import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpTeacher(String email,String password,String fullName) async{
    String retval="error";
    try{
      var authResult=await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // _currentUser.uid=authResult.user!.uid;
      // _currentUser.email=authResult.user!.email;
      // _currentUser.fullName=fullName;
      // //created the user in users collection and update the _currentUser by fetching details when logging-in
      // String ?isUserIndb=await OurDatabase().createUser(_currentUser);//created user in db->add method in db
      // if(isUserIndb=="success")retval="success";
      retval="success";
    }catch(e){
      retval=e.toString();
    }
    return retval;
  }
  Future<String> loginTeacher(String email,String password) async{
    String retVal="error";
    try{
      var authResult=await _auth.signInWithEmailAndPassword(email: email, password: password);
      retVal="success";
    }catch(e){
      print(e);
      retVal="error";
    }
    return retVal;
  }

}