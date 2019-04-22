import 'package:cloud_firestore/cloud_firestore.dart';


class Record {

  final String item;
  final int quantity;
  final DocumentReference reference;


  Record.fromMap(Map<String, dynamic> map, {this.reference})
    : assert(map['item'] != null),
      assert(map['quantity'] != null),
      item = map['item'],
      quantity = map['quantity'];


  Record.fromSnapshot(DocumentSnapshot snapshot)
    : this.fromMap(snapshot.data, reference: snapshot.reference);


  @override


  String toString() => "Record<$item:$quantity";
}