import 'package:cloud_firestore/cloud_firestore.dart';
import 'grocery_model.dart';


class GroceryListModel {

  String id;
  String title;
  bool primary;
  List<GroceryModel> groceries;


  GroceryListModel.fromMap(String id, Map<String, dynamic> map, List<GroceryModel> groceries)
    : id = id,
      title = map['title'],
      primary = map['primary'],
      groceries = groceries;


  GroceryListModel.fromSnapshot(DocumentSnapshot snapshot, List<GroceryModel> groceries)
    : this.fromMap(
        snapshot.documentID,
        snapshot.data,
        groceries,
      );


  String toString() => "GroceryListModel>$title:$groceries:$primary";
}