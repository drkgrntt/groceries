import 'package:flutter/material.dart';
import '../models/grocery_model.dart';
import '../models/grocery_list_model.dart';
import '../blocs/groceries_provider.dart';
import '../blocs/auth_provider.dart';
import '../widgets/grocery_list_item.dart';
import '../widgets/grocery_item_input.dart';


class GroceryList extends StatelessWidget {
  

  Widget build(BuildContext context) {

    // Get blocs
    final groceriesBloc = GroceriesProvider.of(context);
    final authBloc = AuthProvider.of(context);
    
    // Fetch all grocery lists
    return StreamBuilder(
      stream: groceriesBloc.currentList,
      builder: (context, AsyncSnapshot<GroceryListModel> currentList) {

        // Render loading screen until they're loaded
        if (!currentList.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Loading . . .'),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(currentList.data, groceriesBloc),
          drawer: _buildDrawer(currentList.data, groceriesBloc),
          body: _buildBody(currentList.data, groceriesBloc, authBloc),
        );
      },
    );
  }


  Widget _buildAppBar(GroceryListModel currentList, GroceriesBloc groceriesBloc) {

    return AppBar(
      title: Text(currentList.title),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.remove_shopping_cart),
          tooltip: "Clear groceries in the cart",
          color: Colors.white,
          onPressed: () {
            groceriesBloc.clearInCart();
          }
        ),
      ]
    );
  }


  Widget _buildDrawer(GroceryListModel currentList, GroceriesBloc groceriesBloc) {

    return StreamBuilder(
      stream: groceriesBloc.lists,
      builder: (context, AsyncSnapshot<List<GroceryListModel>> lists) {

        if (!lists.hasData) {
          return Drawer(
            child: Center(child: CircularProgressIndicator())
          );
        }

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Lists'),
                decoration: BoxDecoration(color: Colors.blue),
              ), 
              ...lists.data.map((list) => _buildDrawerItem(list, groceriesBloc, context)).toList(),
            ],
          ),
        );
      },
    );
  }


  Widget _buildDrawerItem(GroceryListModel list, GroceriesBloc groceriesBloc, BuildContext context) {

    return Padding(
      key: ValueKey(list.id),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(list.title),
        onTap: () {
          groceriesBloc.updateCurrentList(list);
          Navigator.pop(context);
        },
      ),
    );
  }


  Widget _buildBody(GroceryListModel currentList, GroceriesBloc groceriesBloc, AuthBloc authBloc) {
    return Column(
      children: [
        _buildList(currentList.groceries, groceriesBloc, authBloc),
        GroceryItemInput(),
      ],
    );
  }


  Widget _buildList(List<GroceryModel> list, GroceriesBloc groceriesBloc, AuthBloc authBloc) {

    return Flexible(
      child: ListView(
        padding: const EdgeInsets.only(top: 20.0),
        children: list.map((grocery) => _buildListItem(grocery, groceriesBloc, authBloc)).toList(),
      ),
    );
  }


  Widget _buildListItem(GroceryModel grocery, GroceriesBloc groceriesBloc, AuthBloc authBloc) {

    return Padding(
      key: ValueKey(grocery.id),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GroceryListItem(grocery: grocery, groceriesBloc: groceriesBloc, authBloc: authBloc),
    );
  }
}
