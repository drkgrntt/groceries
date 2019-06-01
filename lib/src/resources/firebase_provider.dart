import 'package:firebase_auth/firebase_auth.dart';


class FirebaseProvider {


  final FirebaseAuth _firebase = FirebaseAuth.instance;


  Future<dynamic> login(String email, String password) async {

    return await _firebase.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<FirebaseUser> fetchCurrentUser() async {

    return await _firebase.currentUser();
  }


  void logout() async {

    return await _firebase.signOut();
  }
}