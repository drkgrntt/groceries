import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/grocery_model.dart';
import '../models/grocery_list_model.dart';
import '../models/user_model.dart';
import '../resources/repository.dart';


class GroceriesBloc {

  final _repository = Repository();
  final _lists = PublishSubject<List<GroceryListModel>>();
  final _groceries = PublishSubject<List<GroceryModel>>();
  final _groceryInputText = BehaviorSubject<String>();
  final _groceryQuantity = BehaviorSubject<String>();
  final _currentList = BehaviorSubject<GroceryListModel>();
  final _currentGrocery = BehaviorSubject<GroceryModel>();
  final groceryInputController = TextEditingController();
  final groceryQuantityController = TextEditingController();


  Observable<List<GroceryListModel>> get lists => _lists.stream;
  Observable<List<GroceryModel>> get groceries => _groceries.stream;
  Stream<GroceryListModel> get currentList => _currentList.stream;
  Stream<GroceryModel> get currentGrocery => _currentGrocery.stream;
  Stream<String> get groceryInputText => _groceryInputText.stream;
  Stream<String> get groceryQuantity => _groceryQuantity.stream;

  Function(String) get updateGroceryInputText => _groceryInputText.sink.add;
  Function(String) get updateGroceryQuantity => _groceryQuantity.sink.add;
  Function(GroceryListModel) get updateCurrentList => _currentList.sink.add;
  Function(GroceryModel) get updateCurrentGrocery => _currentGrocery.sink.add;


  ///
  /// Get a current list of groceries
  ///
  void fetchGroceries({bool fromDatabase: false}) {

    if (fromDatabase) {

        // Get the groceries for the current list
        // List<GroceryModel> groceries = await _repository.fetchGroceries(list.groceries);

    } else {
      currentList.listen((GroceryListModel list) async {

        _groceries.sink.add(list.groceries);
      });
    }
  }


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

    _repository.clearInCart(_currentList.value.id);

    List<GroceryModel> newList = [];

    _currentList.value.groceries.forEach((grocery) {
      if (!grocery.inCart) {
        newList.add(grocery);
      }
    });

    _groceries.sink.add(newList);
  }


  ///
  /// Mark a grocery with [id] as in cart or not in cart [value]
  /// 
  void toggleInCart(GroceryModel grocery) async {

    grocery.inCart = !grocery.inCart;

    // Update the database
    _repository.updateGrocery(grocery);

    updateOneGroceryInList(grocery);
  }


  void updateOneGroceryInList(GroceryModel grocery) {

    GroceryListModel list = _currentList.value;

    // Make a new list
    List<GroceryModel> newList = [];

    bool found = false;

    list.groceries.forEach((item) {
      if (item.id == grocery.id) {
        newList.add(grocery);
        found = true;
      } else {
        newList.add(item);
      }
    });

    if (!found) {
      newList.add(grocery);
    }

    _groceries.sink.add(newList);
  }


  void selectList(GroceryListModel list) {

    updateCurrentList(list);
    fetchGroceries();
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
  void submitGroceryItem() {

    GroceryModel newGrocery;

    // Check to see if we have a current grocery we are editing
    if (_currentGrocery.value != null) {

      newGrocery = _currentGrocery.value;
      newGrocery.item = _groceryInputText.value;
      newGrocery.quantity = int.parse(_groceryQuantity.value);
      newGrocery.inCart = false;

      // If so, update the grocery with the grocery's id
      _repository.updateGrocery(newGrocery);

    } else {

      // Build a map for the new grocery
      final Map<String, dynamic> groceryMap = {
        'item': _groceryInputText.value,
        'quantity': int.parse(_groceryQuantity.value),
        'inCart': false
      };

      // Create a grocery and add it to the grocery list
      _repository.addGrocery(groceryMap, _currentList.value.id);
    }

    // Update stream
    updateOneGroceryInList(newGrocery);

    // Clear streams and controllers and refetch the grocery list
    updateCurrentGrocery(null);
    updateGroceryInputText('');
    groceryInputController.clear();
    groceryQuantityController.clear();
  }


  void dispose() async {

    await _lists.close();
    await _groceries.close();
    await _groceryInputText.close();
    await _groceryQuantity.close();
    await _currentList.close();
    await _currentGrocery.close();
  }
}