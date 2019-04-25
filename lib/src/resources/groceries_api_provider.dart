import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';


class GroceriesApiProvider {

  Firestore _firestore = Firestore.instance;


  Stream<QuerySnapshot> fetchGroceries() {

    return _firestore.collection('groceries').snapshots();
  }


  void toggleInCart(String id, bool value) {

    _firestore.collection('groceries').document(id).updateData({ 'inCart': value });
  }


  void addGrocery(String grocery) {

    final Map<String, dynamic> newGrocery = {
      'item': grocery,
      'quantity': 1,
      'inCart': false
    };

    _firestore.collection('groceries')
      .document().setData(newGrocery);
  }
}
