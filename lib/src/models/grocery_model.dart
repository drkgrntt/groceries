import 'package:cloud_firestore/cloud_firestore.dart';


class GroceryModel {

  final String id;
  final String item;
  final int quantity;
  final bool inCart;


  GroceryModel.fromMap(String id, Map<String, dynamic> map)
    : id = id,
      item = map['item'],
      quantity = map['quantity'],
      inCart = map['inCart'];


  GroceryModel.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(
        snapshot.documentID, 
        snapshot.data,
      );


  String toString() => "GroceryModel>$item:$quantity:$inCart";
}