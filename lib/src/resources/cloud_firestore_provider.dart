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


  void updateUser() {


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


  Future<GroceryModel> addGrocery(Map<String, dynamic> grocery, GroceryListModel list) async {

    // Get the list reference
    DocumentReference listReference = _firestore.collection('lists').document(list.id);

    // Add the list reference to the grocery map
    grocery['list'] = listReference;

    // Add the new item to firebase
    await _firestore.collection('groceries')
      .document().setData(grocery);

    // Get that new item
    QuerySnapshot snapshot = await _firestore.collection('groceries')
      .where('item', isEqualTo: grocery['item'])
      .where('quantity', isEqualTo: grocery['quantity'])
      .where('inCart', isEqualTo: grocery['inCart'])
      .where('list', isEqualTo: grocery['list'])
      .getDocuments();

    DocumentSnapshot newGrocery = snapshot.documents[0];

    final newData = {
      'groceries': FieldValue.arrayUnion([ newGrocery.reference ])
    };

    listReference.updateData(newData);

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


  String getAvailableListTitle(UserModel currentUser, { i: 1 }) {

    String title = 'New List $i';
    bool titleInUse = false;

    currentUser.lists.forEach((GroceryListModel list) {
      if (list.title == title) {
        titleInUse = true;
      }
    });

    if (titleInUse) {
      i++;
      return getAvailableListTitle(currentUser, i: i);
    } else {
      return title;
    }
  }


  Future<GroceryListModel> createList(UserModel currentUser) async {

    String title = getAvailableListTitle(currentUser);

    DocumentReference userReference = _firestore.collection('users').document(currentUser.id);

    Map<String, dynamic> newListData = { 
      'title': title, 
      'primary': false, 
      'groceries': [],
      'user': userReference
    };

    await _firestore.collection('lists')
      .document().setData(newListData);

    // Get the newly created list
    QuerySnapshot snapshot = await _firestore.collection('lists')
      .where('title', isEqualTo: title)
      .where('user', isEqualTo: userReference)
      .getDocuments();

    DocumentSnapshot newList = snapshot.documents[0];

    final newData = {
      'lists': FieldValue.arrayUnion([ newList.reference ])
    };

    _firestore.collection('users').document(currentUser.id)
      .updateData(newData);

    return GroceryListModel.fromSnapshot(newList, []);
  }


  Future<bool> deleteList(GroceryListModel list, UserModel user) async {

    // Delete the reference to the list in the user
    DocumentReference userReference = _firestore.collection('users').document(user.id);
    DocumentSnapshot userSnapshot = await userReference.get();

    List newLists = [];

    userSnapshot.data['lists'].forEach((userList) {
      if (userList.documentID != list.id) {
        newLists.add(userList);
      }
    });

    userReference.updateData({ 'lists': newLists });

    // Delete all groceries referenced in the list
    DocumentReference listReference = _firestore.collection('lists').document(list.id);
    DocumentSnapshot listSnapshot = await listReference.get();
    listSnapshot.data['groceries'].forEach((grocery) {
      grocery.delete();
    });

    // Delete the list
    listReference.delete();

    return true;
  }
}
