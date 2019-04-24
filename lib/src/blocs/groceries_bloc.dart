import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_model.dart';
import '../resources/repository.dart';


class GroceriesBloc {

  final _repository = Repository();
  final _groceries = PublishSubject<List<GroceryModel>>();

  Observable<List<GroceryModel>> get groceries => _groceries.stream;


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


  void dispose() async {

    await _groceries.close();
  }
}