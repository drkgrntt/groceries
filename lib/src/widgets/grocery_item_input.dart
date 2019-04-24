import 'package:flutter/material.dart';
import '../blocs/groceries_provider.dart';


class GroceryItemInput extends StatelessWidget {

  Widget build(context) {

    final groceriesBloc = GroceriesProvider.of(context);

    return StreamBuilder(
      stream: groceriesBloc.groceryInputText,
      builder: (context, snapshot) {
        return TextField(
          onChanged: groceriesBloc.changeGroceryInputText,
          decoration: InputDecoration(
            hintText: 'Bread',
            labelText: 'Grocery Item',
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
          ),
        );
      },
    );
  }
}