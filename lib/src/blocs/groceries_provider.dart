import 'package:flutter/material.dart';
import 'groceries_bloc.dart';
export 'groceries_bloc.dart';


class GroceriesProvider extends InheritedWidget {

  final GroceriesBloc bloc;


  GroceriesProvider({ Key key, Widget child })
    : bloc = GroceriesBloc(),
      super(key: key, child: child);

  
  bool updateShouldNotify(_) => true;


  static GroceriesBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(GroceriesProvider)
      as GroceriesProvider).bloc;
  }
}