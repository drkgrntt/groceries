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
  final _editingCurrentList = BehaviorSubject<bool>();
  final _currentGrocery = BehaviorSubject<GroceryModel>();

  final groceryInputController = TextEditingController();
  final groceryQuantityController = TextEditingController();

  final listInputController = TextEditingController();
  final _listInputText = BehaviorSubject<String>();


  Stream<List<GroceryListModel>> get lists => _lists.stream;
  Stream<GroceryListModel> get currentList => _currentList.stream;
  Stream<bool> get editingCurrentList => _editingCurrentList.stream;
  Stream<GroceryModel> get currentGrocery => _currentGrocery.stream;
  Stream<String> get groceryInputText => _groceryInputText.stream;
  Stream<String> get groceryQuantity => _groceryQuantity.stream;

  Function(String) get updateGroceryInputText => _groceryInputText.sink.add;
  Function(String) get updateGroceryQuantity => _groceryQuantity.sink.add;
  Function(String) get updateListInputText => _listInputText.sink.add;
  Function(GroceryListModel) get updateCurrentList => _currentList.sink.add;
  Function(bool) get editCurrentList => _editingCurrentList.sink.add;
  Function(GroceryModel) get updateCurrentGrocery => _currentGrocery.sink.add;


  ///
  /// Initialize the groceries bloc using a passed [userStream] observable
  ///
  void init (Stream<UserModel> userStream) {

    // Get the user model from the steram
    userStream.listen((UserModel user) {

      // Add the lists to our bloc
      _lists.sink.add(user.lists);

      // If we don't have a current list
      if (_currentList.value == null) {

        // Select the primary list as the initial current list
        _lists.value.forEach((list) {
          if (list.primary) {
            updateCurrentList(list);
          }
        });
      }
    });
  }


  ///
  /// Delete all groceries marked as in cart
  ///
  void clearInCart() {

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
  void toggleInCart(GroceryModel grocery) {

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

    // Set current grocery to the selected grocery
    updateCurrentGrocery(grocery);

    // Update the input fields and streams
    updateGroceryInputText(grocery.item);
    groceryInputController.text = grocery.item;
    updateGroceryQuantity('${grocery.quantity}');
    groceryQuantityController.text = '${grocery.quantity}';
  }


  ///
  /// Sets the selected [list] as editing
  ///
  void editList(GroceryListModel list) {

    // Set the current list to the selected list and say we're editing it
    updateCurrentList(list);
    editCurrentList(true);

    // Update the input field and stream
    updateListInputText(list.title);
    listInputController.text = list.title;
  }


  ///
  /// Updates a grocery list's title
  ///
  void submitListTitle() {

    // Update the selected list
    GroceryListModel newList = _currentList.value;
    newList.title = _listInputText.value;
    _repository.updateList(newList);

    // Remove the editing state
    updateListInputText('');
    listInputController.clear();
    editCurrentList(false);
  }


  ///
  /// Creates a new list document and adds it to the list belonging
  /// to the [currentUser]
  ///
  void createList(UserModel currentUser) async {

    GroceryListModel newList = await _repository.createList(currentUser);
    updateCurrentList(newList);
    currentUser.lists.add(newList);
    _lists.sink.add(currentUser.lists);
  }


  ///
  /// Deletes a provided [deletedList]
  ///
  void deleteList(GroceryListModel deletedList, UserModel currentUser) async {

    // Delete the list from the db and remove it from the user stream
    bool deleted = await _repository.deleteList(deletedList, currentUser);
    currentUser.lists.remove(deletedList);

    // Once deleted, update the groceries bloc state
    if (deleted) {

      List<GroceryListModel> newLists = [];

      _lists.value.forEach((GroceryListModel list) {

      // If we just deleted the current list
      // Select the primary list as the current list
        if (list.primary && _currentList.value.id == deletedList.id) {
          updateCurrentList(list);
        }

        // Update the lists stream
        if (list.id != deletedList.id) {
          newLists.add(list);
        }
      });

      _lists.sink.add(newLists);
    }
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
      newGrocery = await _repository.addGrocery(groceryMap, _currentList.value);

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
    await _editingCurrentList.close();
    await _currentGrocery.close();
    await _listInputText.close();
  }
}