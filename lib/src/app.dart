import 'package:flutter/material.dart';
import './screens/grocery_list.dart';
import './screens/login.dart';
import './blocs/groceries_provider.dart';
import './blocs/auth_provider.dart';

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


  Route routes(RouteSettings settings) {

    if (settings.name == '/list') {

      return MaterialPageRoute(
        builder: (context) {

          final groceriesBloc = GroceriesProvider.of(context);
          groceriesBloc.fetchGroceries();

          return GroceryList();
        },
      );

    } else {

      return MaterialPageRoute(
        builder: (context) {

          return LoginForm();
        },
      );
    }
  }
}