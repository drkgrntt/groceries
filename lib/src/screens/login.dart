import 'package:flutter/material.dart';
import '../blocs/auth_provider.dart';
import '../models/user_model.dart';


class LoginForm extends StatelessWidget {

  Widget build(BuildContext context) {

    final authBloc = AuthProvider.of(context);

    // TODO: Remove these. This is just for convenience.
    authBloc.emailController.text = 'drkgrntt@gmail.com';
    authBloc.changeEmail('drkgrntt@gmail.com');
    authBloc.passwordController.text = 'abcd1234';
    authBloc.changePassword('abcd1234');

    // Render the screen
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
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

      // Render the form
      body: Container(
        margin: EdgeInsets.all(20.0),
        child:  Column(

          // Put in the center of the screen
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          // Render fields
          children: <Widget>[
            _emailField(authBloc),
            _passwordField(authBloc),
            Container(margin: EdgeInsets.only(top: 25.0)),
            _authValidation(authBloc),
            _submitButton(authBloc),
          ],
        ),
      ),
    );
  }

  
  // Render the email field
  Widget _emailField(AuthBloc authBloc) {

    // Get the email stream
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
      },
    );
  }


  // Render the password field
  Widget _passwordField(AuthBloc authBloc) {

    // Get the password stream
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


  Widget _authValidation(AuthBloc authBloc) {

    // Get the validator stream
    return StreamBuilder(
      stream: authBloc.validationMessage,
      builder: (context, snapshot) {
      
        if (!snapshot.hasData) {
          return Container(margin: EdgeInsets.only(top: 25.0));
        }

        return Center(
          child: Text(
            snapshot.data,
            style: TextStyle(
              color: Colors.red[700],
              fontStyle: FontStyle.italic
            ),
          ),
        );
      },
    );
  }


  // Render the submit button
  Widget _submitButton(AuthBloc authBloc) {

    // Get the validator stream
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

              // Only navigate if we got a valid user model
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