import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserModel {

  final String id;
  final String email;
  final List<String> lists;


  UserModel.fromMap(String id, Map<String, dynamic> map, List<String> lists)
    : id = id,
      email = map['email'],
      lists = lists;


  UserModel.fromSnapshot(DocumentSnapshot snapshot, List<String> lists)
    : this.fromMap(
        snapshot.documentID, 
        snapshot.data,
        lists,
      );


  // UserModel.fromFirebaseUser(FirebaseUser user)
  //   : this.fromMap(
  //       user.uid,
  //       {'email': user.email},
  //       []
  //     );


  String toString() => "UserModel>$id:$email:$lists";
}
