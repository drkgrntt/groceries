import 'package:flutter/material.dart';
import '../models/grocery_model.dart';
import '../blocs/groceries_provider.dart';
import '../widgets/grocery_list_item.dart';
import '../widgets/grocery_item_input.dart';


class GroceryList extends StatelessWidget {
  

  Widget build(BuildContext context) {

    // TODO: Move this to app.dart
    final groceriesBloc = GroceriesProvider.of(context);
    groceriesBloc.fetchGroceries();

    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            tooltip: "Clear groceries in cart",
            color: Colors.white,
            onPressed: () {
              groceriesBloc.clearInCart();
            }
          ),
        ]
      ),
      body: Column(
        children: [
          _buildBody(groceriesBloc),
          GroceryItemInput(),
        ],
      ),
    );
  }


  Widget _buildBody(GroceriesBloc groceriesBloc) {

    return StreamBuilder(
      stream: groceriesBloc.groceries,
      builder: (context, AsyncSnapshot<List<GroceryModel>>snapshot) {

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return _buildList(context, snapshot.data, groceriesBloc);
      }
    );
  }


  Widget _buildList(BuildContext context, List<GroceryModel> snapshot, GroceriesBloc groceriesBloc) {

    return Flexible(
      child: ListView(
        padding: const EdgeInsets.only(top: 20.0),
        children: snapshot.map((data) => _buildListItem(context, data, groceriesBloc)).toList(),
      ),
    );
  }


  Widget _buildListItem(BuildContext context, GroceryModel grocery, GroceriesBloc groceriesBloc) {

    return Padding(
      key: ValueKey(grocery.item),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GroceryListItem(grocery: grocery, groceriesBloc: groceriesBloc),
    );
  }
}
