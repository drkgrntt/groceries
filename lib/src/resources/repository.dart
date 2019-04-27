import '../models/grocery_model.dart';
import 'groceries_fs_provider.dart';


class Repository {

  final GroceriesFsProvider _groceriesFsProvider = GroceriesFsProvider();


  ///
  /// Fetch the current grocery list from the firestore provider
  ///
  Future<List<GroceryModel>> fetchGroceries() async {

    return await _groceriesFsProvider.fetchGroceries();
  }


  ///
  /// Tell the firestore provider to remove groceries marked as inCart
  ///
  void clearInCart() {

    _groceriesFsProvider.clearInCart();
  }


  ///
  /// Tell the firestore provider to mark a grocery 
  /// with [id] as in cart or not in cart [value]
  /// 
  void toggleInCart(String id, bool value) {

    _groceriesFsProvider.toggleInCart(id, value);
  }


  ///
  /// Tell the firestore provider to add a [grocery] to the list
  ///
  void addGrocery(Map<String, dynamic> grocery) {

    _groceriesFsProvider.addGrocery(grocery);
  }

  
  ///
  /// Tell the firestore provider to update the document with [id]
  /// with new information in [grocery]
  ///
  void updateGrocery(Map<String, dynamic> grocery, String id) {
    
    _groceriesFsProvider.updateGrocery(grocery, id);
  }
}