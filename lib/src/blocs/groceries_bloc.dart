import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/grocery_model.dart';
import '../models/grocery_list_model.dart';
import '../models/user_model.dart';
import '../resources/repository.dart';


class GroceriesBloc {

  final _repository = Repository();
  final _lists = BehaviorSubject<List<GroceryListModel>>();
  final _groceryInputText = BehaviorSubject<String>();
  final _groceryQuantity = BehaviorSubject<String>();
  final _currentList = BehaviorSubject<GroceryListModel>();
  final _currentGrocery = BehaviorSubject<GroceryModel>();
  final groceryInputController = TextEditingController();
  final groceryQuantityController = TextEditingController();


  Stream<List<GroceryListModel>> get lists => _lists.stream;
  Stream<GroceryListModel> get currentList => _currentList.stream;
  Stream<GroceryModel> get currentGrocery => _currentGrocery.stream;
  Stream<String> get groceryInputText => _groceryInputText.stream;
  Stream<String> get groceryQuantity => _groceryQuantity.stream;

  Function(String) get updateGroceryInputText => _groceryInputText.sink.add;
  Function(String) get updateGroceryQuantity => _groceryQuantity.sink.add;
  Function(GroceryListModel) get updateCurrentList => _currentList.sink.add;
  Function(GroceryModel) get updateCurrentGrocery => _currentGrocery.sink.add;


  ///
  /// Get a list of the user's lists
  ///
  void fetchLists(Observable<UserModel> model) {

    model.listen((UserModel user) {

      _lists.sink.add(user.lists);
    });
  }


  ///
  /// Delete all groceries marked as in cart
  ///
  void clearInCart() async {

    // Update the DB
    _repository.clearInCart(_currentList.value.id);

    // Start a new list
    GroceryListModel list = _currentList.value;
    List<GroceryModel> groceries = [];
    
    // Find groceries that are not in cart and include them
    list.groceries.forEach((GroceryModel grocery) {
      if (!grocery.inCart) {
        groceries.add(grocery);
      }
    });

    list.groceries = groceries;

    updateCurrentList(list);
  }


  ///
  /// Mark a [grocery] as in cart or not in cart
  /// 
  void toggleInCart(GroceryModel grocery) async {

    grocery.inCart = !grocery.inCart;

    // Update the database
    _repository.updateGrocery(grocery);

    updateOneGroceryInList(grocery, false);
  }


  ///
  /// Change one [grocery] in the current list
  /// or add the [grocery] to the current list if it is a [newGrocery]
  ///
  void updateOneGroceryInList(GroceryModel grocery, bool newGrocery) {

    GroceryListModel list = _currentList.value;

    if (!newGrocery) {
      final groceries = list.groceries.map((item) {
        if (item.id == grocery.id) {
          item = grocery;
        }

        return item;
      });

      list.groceries = groceries.toList();
    } else {
      list.groceries.add(grocery);
    }

    updateCurrentList(list);
  }


  ///
  /// Sets the selected [grocery] as editing
  ///
  void editGrocery(GroceryModel grocery) {

    // Set current grocery to the selected id
    updateCurrentGrocery(grocery);

    // Update the input fields and streams
    updateGroceryInputText(grocery.item);
    groceryInputController.text = grocery.item;
    updateGroceryQuantity('${grocery.quantity}');
    groceryQuantityController.text = '${grocery.quantity}';
  }


  ///
  /// Creates or updates a grocery depending on the _currentGrocery value
  ///
  void submitGroceryItem() async {

    GroceryModel newGrocery;
    bool created;

    // Check to see if we have a current grocery we are editing
    if (_currentGrocery.value != null) {

      // If so, update the grocery with the grocery's id
      newGrocery = _currentGrocery.value;
      newGrocery.item = _groceryInputText.value;
      newGrocery.quantity = int.parse(_groceryQuantity.value);
      newGrocery.inCart = false;

      _repository.updateGrocery(newGrocery);

      created = false;

    } else {

      // Build a map to create a new grocery
      final Map<String, dynamic> groceryMap = {
        'item': _groceryInputText.value,
        'quantity': int.parse(_groceryQuantity.value),
        'inCart': false
      };

      // Create a grocery and add it to the grocery list
      newGrocery = await _repository.addGrocery(groceryMap, _currentList.value.id);

      created = true;
    }

    // Update stream
    updateOneGroceryInList(newGrocery, created);

    // Clear streams and controllers and refetch the grocery list
    updateCurrentGrocery(null);
    updateGroceryInputText('');
    groceryInputController.clear();
    groceryQuantityController.clear();
  }


  void dispose() async {

    await _lists.close();
    await _groceryInputText.close();
    await _groceryQuantity.close();
    await _currentList.close();
    await _currentGrocery.close();
  }
}