import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../models/grocery_model.dart';
import '../resources/repository.dart';


class GroceriesBloc {

  final _repository = Repository();
  final _groceries = PublishSubject<List<GroceryModel>>();
  final _groceryInputText = BehaviorSubject<String>();
  final _groceryQuantity = BehaviorSubject<String>();
  final _currentGrocery = BehaviorSubject<String>();
  final groceryInputController = TextEditingController();
  final groceryQuantityController = TextEditingController();

  Observable<List<GroceryModel>> get groceries => _groceries.stream;
  Stream<String> get groceryInputText => _groceryInputText.stream;
  Stream<String> get groceryQuantity => _groceryQuantity.stream;
  Stream<String> get currentGrocery => _currentGrocery.stream;

  Function(String) get updateGroceryInputText => _groceryInputText.sink.add;
  Function(String) get updateGroceryQuantity => _groceryQuantity.sink.add;
  Function(String) get updateCurrentGrocery => _currentGrocery.sink.add;


  ///
  /// Get a current list of groceries
  ///
  void fetchGroceries() async {

    // Get a snapshot of the grocery list
    final List<GroceryModel> groceryList = await _repository.fetchGroceries();

    // Add the list to the sink
    _groceries.sink.add(groceryList);
  }


  ///
  /// Delete all groceries marked as in cart
  ///
  void clearInCart() {

    _repository.clearInCart();
    fetchGroceries();
  }


  ///
  /// Mark a grocery with [id] as in cart or not in cart [value]
  /// 
  void toggleInCart(String id, bool value) {

    _repository.toggleInCart(id, value);
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
  void submitGroceryItem() {

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

      // Otherwise, create a grocery
      _repository.addGrocery(grocery);
    }

    // Clear streams and controllers and refetch the grocery list
    updateCurrentGrocery('');
    updateGroceryInputText('');
    groceryInputController.clear();
    groceryQuantityController.clear();
    fetchGroceries();
  }


  void dispose() async {

    await _groceries.close();
    await _groceryInputText.close();
    await _groceryQuantity.close();
    await _currentGrocery.close();
    groceryInputController.dispose();
    groceryQuantityController.dispose();
  }
}