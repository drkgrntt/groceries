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


  ///
  /// Tell the firestore provider to remove groceries marked as inCart
  ///
  void clearInCart(String listId) {

    _cloudFirestoreProvider.clearInCart(listId);
  }


  ///
  /// Tell the firestore provider to add a [grocery] to the list with [listId]
  ///
  Future<GroceryModel> addGrocery(Map<String, dynamic> grocery, String listId) async {

    return await _cloudFirestoreProvider.addGrocery(grocery, listId);
  }

  
  ///
  /// Tell the firestore provider to update the document with [id]
  /// with new information in [grocery]
  ///
  void updateGrocery(GroceryModel grocery) {

    final Map<String, dynamic> groceryMap = {
      'item': grocery.item,
      'quantity': grocery.quantity,
      'inCart': grocery.inCart
    };

    _cloudFirestoreProvider.updateGrocery(groceryMap, grocery.id);
  }
}