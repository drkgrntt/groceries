import 'package:flutter/material.dart';
import './screens/grocery_list.dart';
import './blocs/groceries_provider.dart';

class App extends StatelessWidget {

  @override
  
  Widget build(BuildContext context) {

    return GroceriesProvider(
      child: MaterialApp(
        title: 'Groceries',
        home: GroceryList(),
      ),
    );
  }
}