import 'package:flutter/material.dart';
import '../blocs/groceries_provider.dart';
import '../blocs/auth_provider.dart';
import '../models/grocery_model.dart';


class GroceryListItem extends StatelessWidget {

  final GroceryModel grocery;
  final GroceriesBloc groceriesBloc;
  final AuthBloc authBloc;


  GroceryListItem({ this.grocery, this.groceriesBloc, this.authBloc });


  Widget build(context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        title: renderText(grocery.inCart, grocery.item),
        trailing: renderText(grocery.inCart, grocery.quantity.toString()),
        onTap: () {
          groceriesBloc.toggleInCart(grocery.id, !grocery.inCart);
        },
        onLongPress: () {
          groceriesBloc.editGrocery(grocery);
        }
      ),
    );
  }


  Widget renderText(bool inCart, String text) {

    if (inCart) {
      return Text(
        " " + text + " ",
        style: TextStyle(
          fontSize: 25.0,
          color: Colors.grey,
          decoration: TextDecoration.lineThrough,
        ),
      );
    } else {
      return Text(
        " " + text + " ",
        style: TextStyle(
          fontSize: 25.0,
        ),
      );
    }
  }
}