import 'package:flutter/material.dart';
import '../models/grocery_model.dart';
import '../blocs/groceries_provider.dart';
import '../widgets/grocery_list_item.dart';


class GroceryList extends StatelessWidget {
  

  Widget build(BuildContext context) {

    // TODO: Move this to app.dart
    final groceriesBloc = GroceriesProvider.of(context);
    groceriesBloc.fetchGroceries();

    return Scaffold(
      appBar: AppBar(title: Text('Grocery List')),
      body: _buildBody(groceriesBloc),
    );
  }


  Widget _buildBody(GroceriesBloc groceriesBloc) {

    return StreamBuilder(
      stream: groceriesBloc.groceries,
      builder: (context, AsyncSnapshot<List<GroceryModel>>snapshot) {

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return _buildList(context, snapshot.data);
      }
    );
  }


  Widget _buildList(BuildContext context, List<GroceryModel> snapshot) {

    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }


  Widget _buildListItem(BuildContext context, GroceryModel grocery) {

    return Padding(
      key: ValueKey(grocery.item),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GroceryListItem(grocery: grocery),
    );
  }
}
