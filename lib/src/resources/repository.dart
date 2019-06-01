import '../models/grocery_model.dart';
import '../models/grocery_list_model.dart';
import '../models/user_model.dart';
import 'cloud_firestore_provider.dart';
import 'firebase_provider.dart';


class Repository {

  final CloudFirestoreProvider _cloudFirestoreProvider = CloudFirestoreProvider();
  final FirebaseProvider _firebaseProvider = FirebaseProvider();
  // TODO: Figure out iOS codes.
  // These codes definitely exist on Android.
  // I don't know if iOS uses these same codes or not.
  final errorMessages = {
    'ERROR_USER_NOT_FOUND': 'No user exists with this email address.',
    'ERROR_WRONG_PASSWORD': 'Invalid password.'
  };


  Future<dynamic> login(String email, String password) async {

    try {

      final user = await _firebaseProvider.login(email, password);
      return await fetchUserData(user.uid);

    } catch (error) {

      return errorMessages[error.code];
    }
  }


  Future<UserModel> fetchCurrentUser() async {

    final user = await _firebaseProvider.fetchCurrentUser();
    return await fetchUserData(user.uid);
  }


  Future<UserModel> fetchUserData(String userId) async {

    return await _cloudFirestoreProvider.fetchUser(userId);
  }


  void logout() {

    return _firebaseProvider.logout();
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
  Future<GroceryModel> addGrocery(Map<String, dynamic> grocery, GroceryListModel list) async {

    return await _cloudFirestoreProvider.addGrocery(grocery, list);
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


  void updateList(GroceryListModel list) {

    final Map<String, dynamic> listMap = {
      'title': list.title
    };

    _cloudFirestoreProvider.updateList(listMap, list.id);
  }


  Future<GroceryListModel> createList(currentUser) async {

    return await _cloudFirestoreProvider.createList(currentUser);
  }

  Future<bool> deleteList(GroceryListModel list, UserModel user) async {

    return await _cloudFirestoreProvider.deleteList(list, user);
  }
}