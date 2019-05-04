import '../models/grocery_model.dart';
import '../models/grocery_list_model.dart';
import '../models/user_model.dart';
import 'cloud_firestore_provider.dart';
import 'firebase_provider.dart';


class Repository {

  final CloudFirestoreProvider _cloudFirestoreProvider = CloudFirestoreProvider();
  final FirebaseProvider _firebaseProvider = FirebaseProvider();


  Future<UserModel> login(String email, String password) async {

    final user = await _firebaseProvider.login(email, password);
    return await fetchUserData(user.uid);
  }


  Future<UserModel> fetchCurrentUser() async {

    final user = await _firebaseProvider.fetchCurrentUser();
    return await fetchUserData(user.uid);
  }


  Future<UserModel> fetchUserData(String userId) async {

    return await _cloudFirestoreProvider.fetchUser(userId);
  }


  Future<List<GroceryListModel>> fetchLists(List<String> listIds) async {

    return await _cloudFirestoreProvider.fetchGroceryLists(listIds);
  }


  ///
  /// Fetch the current grocery list from the firestore provider
  ///
  Future<List<GroceryModel>> fetchGroceries(List<String> groceryIds) async {

    return await _cloudFirestoreProvider.fetchGroceries(groceryIds);
  }


  ///
  /// Tell the firestore provider to remove groceries marked as inCart
  ///
  Future<List<String>> clearInCart(String listId) async {

    return await _cloudFirestoreProvider.clearInCart(listId);
  }


  ///
  /// Tell the firestore provider to mark a grocery 
  /// with [id] as in cart or not in cart [value]
  /// 
  void toggleInCart(String id, bool value) {

    _cloudFirestoreProvider.toggleInCart(id, value);
  }


  ///
  /// Tell the firestore provider to add a [grocery] to the list
  ///
  Future<GroceryModel> addGrocery(Map<String, dynamic> grocery, String listId) async {

    return await _cloudFirestoreProvider.addGrocery(grocery, listId);
  }

  
  ///
  /// Tell the firestore provider to update the document with [id]
  /// with new information in [grocery]
  ///
  void updateGrocery(Map<String, dynamic> grocery, String id) {
    
    _cloudFirestoreProvider.updateGrocery(grocery, id);
  }
}