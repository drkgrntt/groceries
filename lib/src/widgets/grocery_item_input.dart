import 'package:flutter/material.dart';
import '../blocs/groceries_provider.dart';


class GroceryItemInput extends StatelessWidget {

  Widget build(context) {

    final groceriesBloc = GroceriesProvider.of(context);

    return Row(
      children: [
        textField(groceriesBloc),
        submitButton(groceriesBloc),
      ],
    );
  }


  Widget textField(GroceriesBloc groceriesBloc) {

    return StreamBuilder(
      stream: groceriesBloc.groceryInputText,
      builder: (context, snapshot) {

        return Flexible(
          child: TextField(
            onChanged: groceriesBloc.updateGroceryInputText,
            decoration: InputDecoration(
              hintText: 'Nuts',
              labelText: 'Grocery Item',
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
            ),
            controller: groceriesBloc.groceryInputController
          ),
        );
      },
    );
  }


  Widget submitButton(GroceriesBloc groceriesBloc) {

    return StreamBuilder(
      stream: groceriesBloc.groceryInputText,
      builder: (context, snapshot) {

        return RaisedButton(
          child: Text('Add'),
          color: Colors.blue,
          textColor: Colors.white,
          onPressed: () {
            if (snapshot.data != null && snapshot.data != '') {
              groceriesBloc.submitGroceryItem();
            }
          },
        );
      }
    );
    

  }
}