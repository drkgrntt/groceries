import 'package:flutter/material.dart';
import '../blocs/groceries_provider.dart';
import '../blocs/auth_provider.dart';
import '../models/grocery_list_model.dart';

class DrawerMenu extends StatelessWidget {


  final GroceriesBloc groceriesBloc;
  final AuthBloc authBloc;
  final List<GroceryListModel> lists;


  DrawerMenu({ this.groceriesBloc, this.lists, this.authBloc });


  Widget build(BuildContext context) {

    return Drawer(
      child: Column(
        children: <Widget>[
          _buildDrawer(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            child: Center(
              child: RaisedButton(
                child: Text('Log Out'),
                color: Colors.red[700],
                textColor: Colors.white,
                onPressed: () {
                  // Logout and go to first screen
                  authBloc.logout();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDrawer() {

    return StreamBuilder(
      stream: groceriesBloc.currentList,
      builder: (context, AsyncSnapshot<GroceryListModel> snapshot) {

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
    
        return Flexible(
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
              style: _textStyle(list, currentList),
            ),
            trailing: !list.primary ? IconButton(
              icon: Icon(Icons.clear),
              color: Colors.red[700],
              onPressed: () {
                return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text('Are you sure you want to delete ${list.title}?'),
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Text('Yes'),
                          onPressed: () {
                            groceriesBloc.deleteList(list, authBloc.currentUser);
                            Navigator.pop(context);
                          }
                        ),
                        SimpleDialogOption(
                          child: Text('No'),
                          onPressed: () {
                            Navigator.pop(context);
                          }
                        ),
                      ],
                    );
                  },
                );
              }
            ) : null,
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


  TextStyle _textStyle(GroceryListModel list, GroceryListModel currentList) {

    // Indicate current list
    if (list.id == currentList.id) {
      return TextStyle(
        fontSize: 16.0, 
        fontStyle: FontStyle.italic,
        color: Colors.blue[900],
      );
    } else {
      return TextStyle(fontSize: 16.0);
    }
  }


  Widget _textField(GroceriesBloc groceriesBloc) {

    return Flexible(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: TextField(
          textCapitalization: TextCapitalization.sentences,
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
          groceriesBloc.createList(authBloc.currentUser);
          Navigator.pop(context);
        },
      ),
    );
  }
}