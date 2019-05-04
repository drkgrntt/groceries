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
  final _currentGrocery = BehaviorSubject<String>();
  final groceryInputController = TextEditingController();
  final groceryQuantityController = TextEditingController();


  Observable<List<GroceryListModel>> get lists => _lists.stream;
  Observable<List<GroceryModel>> get groceries => _groceries.stream;
  Stream<GroceryListModel> get currentList => _currentList.stream;
  Stream<String> get currentGrocery => _currentGrocery.stream;
  Stream<String> get groceryInputText => _groceryInputText.stream;
  Stream<String> get groceryQuantity => _groceryQuantity.stream;

  Function(String) get updateGroceryInputText => _groceryInputText.sink.add;
  Function(String) get updateGroceryQuantity => _groceryQuantity.sink.add;
  Function(GroceryListModel) get updateCurrentList => _currentList.sink.add;
  Function(String) get updateCurrentGrocery => _currentGrocery.sink.add;


  ///
  /// Get a current list of groceries
  ///
  void fetchGroceries() {

    currentList.listen((GroceryListModel list) async {

      // Get the groceries for the current list
      List<GroceryModel> groceries = await _repository.fetchGroceries(list.groceries);

      _groceries.sink.add(groceries);
    });
  }


  ///
  /// Get a list of the user's lists
  ///
  void fetchLists(Observable<UserModel> model) {

    model.listen((UserModel user) async {

      List<GroceryListModel> lists = await _repository.fetchLists(user.lists);
      _lists.sink.add(lists);
    });
  }


  ///
  /// Delete all groceries marked as in cart
  ///
  void clearInCart() async {

    List<String> removedIds = await _repository.clearInCart(_currentList.value.id);

    GroceryListModel newList = _currentList.value;

    removedIds.forEach((id) {
      newList.groceries.remove(id);
    });
    
    _currentList.sink.add(newList);

    fetchGroceries();
  }


  ///
  /// Mark a grocery with [id] as in cart or not in cart [value]
  /// 
  void toggleInCart(String id, bool value) {

    _repository.toggleInCart(id, value);
    fetchGroceries();
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
    updateCurrentGrocery(grocery.id);

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

    // Build a map for the new grocery
    final Map<String, dynamic> grocery = {
      'item': _groceryInputText.value,
      'quantity': int.parse(_groceryQuantity.value),
      'inCart': false
    };

    // Check to see if we have a current grocery we are editing
    if (_currentGrocery.value != '' && _currentGrocery.value != null) {

      // If so, update the grocery with the grocery's id
      _repository.updateGrocery(grocery, _currentGrocery.value);
    } else {

      // Otherwise, create a grocery and add it to the grocery list
      GroceryModel newGrocery = await _repository.addGrocery(grocery, _currentList.value.id);
      GroceryListModel newList = _currentList.value;
      newList.groceries.add(newGrocery.id);
      _currentList.sink.add(newList);
    }

    // Clear streams and controllers and refetch the grocery list
    updateCurrentGrocery('');
    updateGroceryInputText('');
    groceryInputController.clear();
    groceryQuantityController.clear();
    fetchGroceries();
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