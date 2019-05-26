import 'package:flutter/material.dart';
import '../blocs/groceries_provider.dart';
import '../models/grocery_list_model.dart';

class DrawerMenu extends StatelessWidget {


  final GroceriesBloc groceriesBloc;
  final List<GroceryListModel> lists;


  DrawerMenu({ this.groceriesBloc, this.lists });


  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: groceriesBloc.currentList,
      builder: (context, AsyncSnapshot<GroceryListModel> snapshot) {

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[

              // Drawer header
              _buildDrawerHeader(), 

              // Grocery lists
              ...lists.map((list) {
                return Container(
                  key: ValueKey(list.id),
                  margin: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
                  ),
                  child: _buildDrawerItem(list, snapshot.data, context),
                );
              }).toList(),
              // "Add new" option
              _buildAddNewOption(context),
            ],
          ),
        );
      },
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


  Widget _buildDrawerItem(GroceryListModel list, GroceryListModel currentList, BuildContext context) {

    return StreamBuilder(
      stream: groceriesBloc.editingCurrentList,
      builder: (context, AsyncSnapshot<bool> snapshot) {

        if (!snapshot.hasData) {

          groceriesBloc.editCurrentList(false);

          // Render a grey bar as the loader
          return Center(
            child: Container(
              color: Colors.grey[300],
              margin: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            ),
          );
        }

        // If we are editing and the list item is the current list
        if (snapshot.data && list.id == currentList.id) {
  
          // Render a list title input
          return Row(
            children: <Widget>[
              _textField(groceriesBloc),
              _submitButton(groceriesBloc),
            ],
          );

        } else {

          // Render a normal list item
          return ListTile(
            title: Text(
              list.title,
              style: TextStyle(fontSize: 16.0),
            ),
            onTap: () {
              groceriesBloc.updateCurrentList(list);
              groceriesBloc.editCurrentList(false);
              Navigator.pop(context);
            },
            onLongPress: () {
              groceriesBloc.editList(list);          
            }
          );
        }
      },
    );
  }


  Widget _textField(GroceriesBloc groceriesBloc) {

    return Flexible(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: TextField(
          onChanged: groceriesBloc.updateListInputText,
          controller: groceriesBloc.listInputController,
          decoration: InputDecoration(
            labelText: 'Grocery List Name',
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
          ),
        ),
      ),
    );
  }


  Widget _submitButton(GroceriesBloc groceriesBloc) {

    return RaisedButton(
      child: Text('Done'),
      color: Colors.blue,
      textColor: Colors.white,
      onPressed: () {
        groceriesBloc.submitListTitle();
      },
    );
  }


  Widget _buildAddNewOption(BuildContext context) {

    return Container(
      key: ValueKey('addNew'),
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: ListTile(
        title: Text(
          'Add new list',
          style: TextStyle(fontSize: 16.0),
        ),
        onTap: () {
          // groceriesBloc.createNewList();
          Navigator.pop(context);
        },
      ),
    );
  }
}