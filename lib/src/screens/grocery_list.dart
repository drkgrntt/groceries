import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/record.dart';


class GroceryList extends StatefulWidget {

  @override

  _GroceryListState createState() {

    return _GroceryListState();
  }
}


class _GroceryListState extends State<GroceryList> {
  
  @override

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Grocery List')),
      body: _buildBody(context),
    );
  }


  Widget _buildBody(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('groceries').snapshots(),
      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        }

        return _buildList(context, snapshot.data.documents);
      }
    );
  }


  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {

    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }


  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Padding(
      key: ValueKey(record.item),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.item),
          trailing: Text(record.quantity.toString()),
          onTap: () {
            record.reference.updateData({'quantity': record.quantity + 1});
          },
        ),
      ),
    );
  }
}
