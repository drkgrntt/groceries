import 'package:cloud_firestore/cloud_firestore.dart';


class GroceryModel {

  final String item;
  final int quantity;
  final DocumentReference reference;


  GroceryModel.fromMap(Map<String, dynamic> map, { this.reference })
    : assert(map['item'] != null),
      assert(map['quantity'] != null),
      item = map['item'],
      quantity = map['quantity'];


  GroceryModel.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, reference: snapshot.reference);


  @override


  String toString() => "GroceryModel<$item:$quantity";
}