import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_model.dart';
import '../resources/repository.dart';


class GroceriesBloc {

  final _repository = Repository();
  final _groceries = PublishSubject<List<GroceryModel>>();
  final _groceryInputText = BehaviorSubject<String>();
  final _groceryQuantity = BehaviorSubject<String>();
  final groceryInputController = TextEditingController();
  final groceryQuantityController = TextEditingController();

  Observable<List<GroceryModel>> get groceries => _groceries.stream;
  Stream<String> get groceryInputText => _groceryInputText.stream;
  Stream<String> get groceryQuantity => _groceryQuantity.stream;

  Function(String) get updateGroceryInputText => _groceryInputText.sink.add;
  Function(String) get updateGroceryQuantity => _groceryQuantity.sink.add;


  void fetchGroceries() {

    // Get a snapshot of the grocery list
    final Stream<QuerySnapshot> snapshot = _repository.fetchGroceries();

    snapshot.listen((data) {
      final List<GroceryModel> groceryList = [];

      // Fill a list with the groceries from the snapshot
      data.documents.forEach((document) {
        final grocery = GroceryModel.fromSnapshot(document);
        groceryList.add(grocery);
      });

      // Add the list to the sink
      _groceries.sink.add(groceryList);
    });
  }


  void clearInCart() {

    _repository.clearInCart();
  }


  void toggleInCart(String id, bool value) {

    _repository.toggleInCart(id, value);
  }


  void submitGroceryItem() {

    final Map<String, dynamic> grocery = {
      'item': _groceryInputText.value,
      'quantity': int.parse(_groceryQuantity.value),
      'inCart': false
    };

    _repository.addGrocery(grocery);

    updateGroceryInputText('');
    groceryInputController.clear();
    groceryQuantityController.clear();
  }


  void dispose() async {

    await _groceries.close();
    await _groceryInputText.close();
    await _groceryQuantity.close();
    groceryInputController.dispose();
    groceryQuantityController.dispose();
  }
}