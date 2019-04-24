import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';


class GroceriesApiProvider {

  Firestore _firestore = Firestore.instance;


  Stream<QuerySnapshot> fetchGroceries() {

    final snapshot = _firestore.collection('groceries').snapshots();
    
    return snapshot;
  }
}
