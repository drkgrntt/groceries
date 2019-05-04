import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_model.dart';
import '../models/grocery_list_model.dart';
import '../models/user_model.dart';


class CloudFirestoreProvider {

  Firestore _firestore = Firestore.instance;


  Future<UserModel> fetchUser(String userId) async {

    List<String> lists = [];

    final userSnapshot = await _firestore.collection('users').document(userId).get();

    userSnapshot.data['lists'].forEach((list) {
      lists.add(list.documentID);
    });

    return UserModel.fromSnapshot(userSnapshot, lists);
  }


  Future<List<GroceryListModel>> fetchGroceryLists(List<String> listIds) async {

    final List<GroceryListModel> lists = [];

    for( final id in listIds ) {
      DocumentSnapshot listSnapshot = await _firestore.collection('lists').document(id).get();

      List<String> groceries = [];

      listSnapshot.data['groceries'].forEach((grocery) {
        groceries.add(grocery.documentID);
      });

      lists.add(GroceryListModel.fromSnapshot(listSnapshot, groceries));
    }

    return lists;
  }


  // ================================ //
  //        Grocery CRUD Actions      //
  // ================================ //


  Future<List<GroceryModel>> fetchGroceries(List<String> groceryIds) async {

    final List<GroceryModel> groceryList = [];

    for( final id in groceryIds ) {
      DocumentSnapshot grocery = await _firestore.collection('groceries').document(id).get();
      groceryList.add(GroceryModel.fromSnapshot(grocery));
    }

    return groceryList;
  }


  void toggleInCart(String id, bool value) {

    _firestore.collection('groceries').document(id).updateData({ 'inCart': value });
  }


  Future<List<String>> clearInCart(String listId) async {

    QuerySnapshot groceriesSnapshot = await _firestore.collection('groceries').getDocuments();

    List<DocumentReference> removedGroceries = [];
    List<String> ids = [];

    groceriesSnapshot.documents.forEach((document) {
      if (document.data['inCart']) {
        ids.add(document.documentID);
        removedGroceries.add(document.reference);
        _firestore.collection('groceries').document(document.documentID).delete();
      }

    });

    final removedDocuments = {
      'groceries': FieldValue.arrayRemove(removedGroceries)
    };

    _firestore.collection('lists').document(listId).updateData(removedDocuments);

    return ids;
  }


  Future<GroceryModel> addGrocery(Map<String, dynamic> grocery, String listId) async {

    // Add the new item to firebase
    await _firestore.collection('groceries')
      .document().setData(grocery);

    // Get that new item
    QuerySnapshot snapshot = await _firestore.collection('groceries')
      .where('item', isEqualTo: grocery['item'])
      .where('quantity', isEqualTo: grocery['quantity'])
      .where('inCart', isEqualTo: grocery['inCart'])
      .getDocuments();

    DocumentSnapshot newGrocery = snapshot.documents[0];

    final newData = {
      'groceries': FieldValue.arrayUnion([ newGrocery.reference ])
    };

    await _firestore.collection('lists').document(listId)
      .updateData(newData);

    return GroceryModel.fromSnapshot(newGrocery);
  }


  void updateGrocery(Map<String, dynamic> grocery, String id) {
    
    _firestore.collection('groceries')
      .document(id).setData(grocery);
  }
}
