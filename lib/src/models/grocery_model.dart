import 'package:cloud_firestore/cloud_firestore.dart';


class GroceryModel {

  final String id;
  final String item;
  final int quantity;
  final bool inCart;
  final DocumentReference reference;


  GroceryModel.fromMap(String id, Map<String, dynamic> map, { this.reference })
    : id = id,
      item = map['item'],
      quantity = map['quantity'],
      inCart = map['inCart'];


  GroceryModel.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.documentID, snapshot.data, reference: snapshot.reference);


  @override


  String toString() => "GroceryModel>$item:$quantity:$inCart";
}