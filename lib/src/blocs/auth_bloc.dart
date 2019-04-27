import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';


class AuthBloc {

  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Stream<String> get email => _email.stream;
  Stream<String> get password => _password.stream;

  Function(String) get changeEmail => _email.sink.add;
  Function(String) get changePassword => _password.sink.add;


  submit() {

    final validEmail = _email.value;
    final validPassword = _password.value;

    // TODO: Connect to api
    print('Email: $validEmail');
    print('Password: $validPassword');

    changeEmail('');
    emailController.text = '';
    changePassword('');
    passwordController.text = '';
  }


  dispose() {

    _email.close();
    _password.close();
  }
}