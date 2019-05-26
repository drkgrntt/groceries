import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';
import '../models/user_model.dart';


class AuthBloc {

  final _repository = Repository();
  final _currentUser = BehaviorSubject<UserModel>();
  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Stream<UserModel> get currentUser => _currentUser.stream;

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


  void fetchCurrentUser() async {

    final user = await _repository.fetchCurrentUser();
    _currentUser.sink.add(user);
  }


  Future<UserModel> submit() async {

    String validEmail = _email.value;
    String validPassword = _password.value;

    return await _repository.login(validEmail, validPassword);
  }


  void logout() {

    _repository.logout();
  }


  dispose() {

    _currentUser.close();
    _email.close();
    _password.close();
  }
}