import 'package:flutter/material.dart';
import '../blocs/groceries_provider.dart';
import '../models/grocery_list_model.dart';

class DrawerMenu extends StatelessWidget {


  final GroceriesBloc groceriesBloc;
  final List<GroceryListModel> lists;


  DrawerMenu({ this.groceriesBloc, this.lists });


  Widget build(BuildContext context) {

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[

          // Drawer header
          _buildDrawerHeader(), 

          // Grocery lists
          ...lists.map((list) => _buildDrawerItem(list, context)).toList(),

          // "Add new" option
          _buildAddNewOption(context),
        ],
      ),
    );
  }


  Widget _buildDrawerHeader() {
    
    return Container(
      height: 80.0,
      child: DrawerHeader(
        child: Text(
          'Grocery Lists',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(color: Colors.blue),
      ),
    );
  }


  Widget _buildDrawerItem(GroceryListModel list, BuildContext context) {

    return Container(
      key: ValueKey(list.id),
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
      ),
      child: ListTile(
        title: Text(list.title),
        onTap: () {
          groceriesBloc.updateCurrentList(list);
          Navigator.pop(context);
        },
      ),
    );
  }


  Widget _buildAddNewOption(BuildContext context) {

    return Container(
      key: ValueKey('addNew'),
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: ListTile(
        title: Text('Add new list'),
        onTap: () {
          // groceriesBloc.createNewList();
          Navigator.pop(context);
        },
      ),
    );
  }
}