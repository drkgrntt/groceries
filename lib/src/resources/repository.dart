import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_model.dart';
import 'groceries_api_provider.dart';


class Repository {

  final GroceriesApiProvider _groceriesApiProvider = GroceriesApiProvider();


  Stream<QuerySnapshot> fetchGroceries() {

    return _groceriesApiProvider.fetchGroceries();
  }
}