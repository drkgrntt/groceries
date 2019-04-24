import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_model.dart';


class GroceryListItem extends StatelessWidget {

  final GroceryModel grocery;


  GroceryListItem({ this.grocery });


  Widget build(context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: ListTile(
        title: Text(grocery.item),
        trailing: Text(grocery.quantity.toString()),
        onTap: () => Firestore.instance.runTransaction((transaction) async {
          
          final freshSnapshot = await transaction.get(grocery.reference);
          final fresh = GroceryModel.fromSnapshot(freshSnapshot);

          await transaction.update(
            grocery.reference,
            { 'quantity': fresh.quantity + 1 }
          );
        }),
      ),
    );
  }
}