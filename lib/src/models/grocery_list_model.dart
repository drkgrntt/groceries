import 'package:cloud_firestore/cloud_firestore.dart';
import 'grocery_model.dart';
import 'user_model.dart';


class GroceryListModel {

  final String id;
  final String title;
  final List<String> groceries;


  GroceryListModel.fromMap(String id, Map<String, dynamic> map, List<String> groceries)
    : id = id,
      title = map['title'],
      groceries = groceries;


  GroceryListModel.fromSnapshot(DocumentSnapshot snapshot, List<String> groceries)
    : this.fromMap(
        snapshot.documentID,
        snapshot.data,
        groceries,
      );


  String toString() => "GroceryListModel>$title:$groceries";
}