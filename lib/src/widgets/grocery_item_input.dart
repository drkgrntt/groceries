import 'package:flutter/material.dart';
import '../blocs/groceries_provider.dart';


class GroceryItemInput extends StatelessWidget {

  Widget build(context) {

    final groceriesBloc = GroceriesProvider.of(context);

    return StreamBuilder(
      stream: groceriesBloc.groceryInputText,
      builder: (context, snapshot) {

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              textField(groceriesBloc),
              numberField(groceriesBloc),
              submitButton(groceriesBloc, snapshot),
            ],
          ),
        );
      },
    );
  }


  Widget numberField(GroceriesBloc groceriesBloc) {

    return Container(
      width: 80.0,
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        onChanged: groceriesBloc.updateGroceryQuantity,
        controller: groceriesBloc.groceryQuantityController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: '2',
          labelText: 'Quantity',
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        ),
      ),
    );
  }


  Widget textField(GroceriesBloc groceriesBloc) {

    return Flexible(
      child: TextField(
        onChanged: groceriesBloc.updateGroceryInputText,
        controller: groceriesBloc.groceryInputController,
        decoration: InputDecoration(
          hintText: 'Nuts',
          labelText: 'Grocery Item',
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        ),
      ),
    );
  }


  Widget submitButton(GroceriesBloc groceriesBloc, AsyncSnapshot snapshot) {

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
}