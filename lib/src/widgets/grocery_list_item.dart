import 'package:flutter/material.dart';
import '../blocs/groceries_provider.dart';
import '../models/grocery_model.dart';


class GroceryListItem extends StatelessWidget {

  final GroceryModel grocery;
  final GroceriesBloc groceriesBloc;


  GroceryListItem({ this.grocery, this.groceriesBloc });


  Widget build(context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        title: renderText(grocery),
        trailing: Text(grocery.quantity.toString()),
        onTap: () {
          groceriesBloc.toggleInCart(grocery.id, !grocery.inCart);
        },
      ),
    );
  }


  Widget renderText(GroceryModel grocery) {

    if (grocery.inCart) {
      return Text(
        grocery.item,
        style: TextStyle(decoration: TextDecoration.lineThrough),
      );
    } else {
      return Text(grocery.item);
    }
  }
}