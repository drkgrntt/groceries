import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_model.dart';
import '../models/grocery_list_model.dart';
import '../models/user_model.dart';


class CloudFirestoreProvider {

  Firestore _firestore = Firestore.instance;


  Future<UserModel> fetchUser(String userId) async {

    List<GroceryListModel> lists = [];
    DocumentSnapshot userSnapshot = await _firestore.collection('users').document(userId).get();

    for (var listRef in userSnapshot.data['lists']) {

      List<GroceryModel> groceries = [];
      DocumentSnapshot listSnapshot = await listRef.get();

      for (var groceryRef in listSnapshot.data['groceries']) {
        DocumentSnapshot grocerySnapshot = await groceryRef.get();

        groceries.add(GroceryModel.fromSnapshot(grocerySnapshot));
      }

      lists.add(GroceryListModel.fromSnapshot(listSnapshot, groceries));
    }

    return UserModel.fromSnapshot(userSnapshot, lists);
  }


  void toggleInCart(String id, bool value) {

    _firestore.collection('groceries').document(id).updateData({ 'inCart': value });
  }


  void clearInCart(String listId) async {

    QuerySnapshot groceriesSnapshot = await _firestore.collection('groceries').getDocuments();

    List<DocumentReference> removedGroceries = [];

    groceriesSnapshot.documents.forEach((document) {
      if (document.data['inCart']) {
        removedGroceries.add(document.reference);
        _firestore.collection('groceries').document(document.documentID).delete();
      }
    });

    final removedDocuments = {
      'groceries': FieldValue.arrayRemove(removedGroceries)
    };

    _firestore.collection('lists').document(listId).updateData(removedDocuments);
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

    _firestore.collection('lists').document(listId)
      .updateData(newData);

    return GroceryModel.fromSnapshot(newGrocery);
  }


  void updateGrocery(Map<String, dynamic> grocery, String id) {
    
    _firestore.collection('groceries')
      .document(id).setData(grocery);
  }


  void updateList(Map<String, dynamic> list, String id) {

    _firestore.collection('lists').document(id)
      .updateData(list);
  }
}
