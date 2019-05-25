import 'package:flutter/material.dart';
import './screens/grocery_list.dart';
import './screens/login.dart';
import './blocs/groceries_provider.dart';
import './blocs/auth_provider.dart';
import './models/grocery_list_model.dart';

// Base app component
class App extends StatelessWidget {

  Widget build(BuildContext context) {

    return AuthProvider(
      child: GroceriesProvider(
        child: MaterialApp(
          title: 'Groceries',
          onGenerateRoute: routes,
        ),
      ),
    );
  }


  // Route filter
  Route routes(RouteSettings settings) {

    // Login
    if (settings.name == '/') {

      return MaterialPageRoute(
        builder: (context) {

          return LoginForm();
        },
      );

    // Grocery List
    } else {

      return MaterialPageRoute(
        builder: (context) {

          // Get the current user and the user's lists
          final authBloc = AuthProvider.of(context);
          authBloc.fetchCurrentUser();

          final groceriesBloc = GroceriesProvider.of(context);
          groceriesBloc.fetchLists(authBloc.currentUser);

          // Select the primary list as the initial current list
          groceriesBloc.lists.listen((List<GroceryListModel> lists) {

            lists.forEach((list) {
              if (list.primary) {
                groceriesBloc.updateCurrentList(list);
              }
            });
          });

          return GroceryList();
        },
      );
    }
  }
}