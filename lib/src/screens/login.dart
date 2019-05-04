import 'package:flutter/material.dart';
import '../blocs/auth_provider.dart';
import '../models/user_model.dart';


class LoginForm extends StatelessWidget {

  Widget build(BuildContext context) {

    final authBloc = AuthProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Login!'),
        // actions: <Widget>[
        //   IconButton(
        //     icon: Icon(Icons.format_list_bulleted),
        //     tooltip: "Quick Start",
        //     color: Colors.white,
        //     onPressed: () {
        //       Navigator.pushNamed(context, '/list');
        //     }
        //   ),
        // ],
      ),
      body: Container(
        margin: EdgeInsets.all(20.0),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _emailField(authBloc),
            _passwordField(authBloc),
            Container(margin: EdgeInsets.only(top: 25.0)),
            _submitButton(authBloc),
          ],
        ),
      ),
    );
  }


  Widget _emailField(AuthBloc authBloc) {

    return StreamBuilder(
      stream: authBloc.email,
      builder: (context, snapshot) {

        return TextField(
          onChanged: authBloc.changeEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'you@example.com',
            labelText: 'Email',
            errorText: snapshot.error
          ),
          controller: authBloc.emailController
        );
      }
    );
  }


  Widget _passwordField(AuthBloc authBloc) {

    return StreamBuilder(
      stream: authBloc.password,
      builder: (context, snapshot) {

        return TextField(
          onChanged: authBloc.changePassword,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            labelText: 'Password',
            errorText: snapshot.error
          ),
          controller: authBloc.passwordController,
        );
      }
    );
  }


  Widget _submitButton(AuthBloc authBloc) {

    return StreamBuilder(
      stream: authBloc.submitValid,
      builder: (context, snapshot) {
        return RaisedButton(
          child: Text('Login'),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () async {
            
            if (snapshot.hasData) {
              final user = await authBloc.submit();

              if (user is UserModel) {
                Navigator.pushNamed(context, '/list/${user.id}');
              }
            } else {
              return null;
            }
            
          },
        );
      },
    );
  }
}