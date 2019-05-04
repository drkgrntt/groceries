import 'package:flutter/material.dart';
import './screens/grocery_list.dart';
import './screens/login.dart';
import './blocs/groceries_provider.dart';
import './blocs/auth_provider.dart';
import './models/user_model.dart';

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

    if (settings.name == '/') {

      return MaterialPageRoute(
        builder: (context) {

          return LoginForm();
        },
      );

    } else {

      return MaterialPageRoute(
        builder: (context) {

          final authBloc = AuthProvider.of(context);
          authBloc.fetchCurrentUser();

          final groceriesBloc = GroceriesProvider.of(context);
          groceriesBloc.fetchLists(authBloc.currentUser);

          return GroceryList();
        },
      );
    }
  }
}