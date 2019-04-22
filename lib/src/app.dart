import 'package:flutter/material.dart';
import './screens/grocery_list.dart';

class App extends StatelessWidget {

  @override
  
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Groceries',
      home: GroceryList(),
    );
  }
}