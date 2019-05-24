import 'package:cloud_firestore/cloud_firestore.dart';
import 'grocery_list_model.dart';


class UserModel {

  String id;
  String email;
  List<GroceryListModel> lists;


  UserModel.fromMap(String id, Map<String, dynamic> map, List<GroceryListModel> lists)
    : id = id,
      email = map['email'],
      lists = lists;


  UserModel.fromSnapshot(DocumentSnapshot snapshot, List<GroceryListModel> lists)
    : this.fromMap(
        snapshot.documentID, 
        snapshot.data,
        lists,
      );


  String toString() => "UserModel>$id:$email:$lists";
}
