import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_model.dart';


class GroceriesFsProvider {

  CollectionReference _groceries = Firestore.instance.collection('groceries');


  Future<List<GroceryModel>> fetchGroceries() async {

    final List<GroceryModel> groceryList = [];

    final snapshot = await _groceries.getDocuments();

    snapshot.documents.forEach((document) {
      final grocery = GroceryModel.fromSnapshot(document);
      groceryList.add(grocery);
    });

    return groceryList;
  }


  void toggleInCart(String id, bool value) {

    _groceries.document(id).updateData({ 'inCart': value });
  }


  void clearInCart() {

    _groceries.getDocuments()
      .then((data) {
        data.documents.forEach((document) {
          if (document.data['inCart']) {
            _groceries.document(document.documentID).delete();
          }
        });
      });
  }


  void addGrocery(Map<String, dynamic> grocery) {

    _groceries
      .document().setData(grocery);
  }


  void updateGrocery(Map<String, dynamic> grocery, String id) {
    
    _groceries
      .document(id).setData(grocery);
  }
}
