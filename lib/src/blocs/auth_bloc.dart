import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';


class AuthBloc {

  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Stream<String> get email => 
    _email.stream.transform(validateEmail);

  Stream<String> get password => 
    _password.stream.transform(validatePassword);
    
  Stream<bool> get submitValid =>
    Observable.combineLatest2(email, password, (e, p) => true);

  Function(String) get changeEmail => _email.sink.add;
  Function(String) get changePassword => _password.sink.add;


  final validateEmail = StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email.contains('@')) {
      sink.add(email);
    } else {
      sink.addError('Please enter a valid email.');
    }
  });


  final validatePassword = StreamTransformer<String, String>.fromHandlers(handleData: (password, sink) {
    if (password.length > 3) {
      sink.add(password);
    } else {
      sink.addError('Password must be at least 4 characters.');
    }
  });


  submit() {

    final validEmail = _email.value;
    final validPassword = _password.value;

    // TODO: Connect to api
    print('Email: $validEmail');
    print('Password: $validPassword');
  }


  dispose() {

    _email.close();
    _password.close();
  }
}