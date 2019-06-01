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
  final _validationMessage = BehaviorSubject<String>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Stream<UserModel> get currentUser => _currentUser.stream;

  Stream<String> get email => 
    _email.stream.transform(validateEmail);

  Stream<String> get password => 
    _password.stream.transform(validatePassword);

  Stream<String> get validationMessage =>
    _validationMessage.stream;
    
  Stream<bool> get submitValid =>
    Observable.combineLatest2(email, password, (e, p) => true);

  Function(String) get changeEmail => _email.sink.add;
  Function(String) get changePassword => _password.sink.add;
  Function(String) get changeValidationMessage => _validationMessage.sink.add;


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


  Future<dynamic> submit() async {

    changeValidationMessage('Logging you in.');

    String validEmail = _email.value;
    String validPassword = _password.value;

    final user = await _repository.login(validEmail, validPassword);
    
    if (user is String) {
      return changeValidationMessage(user);
    } else {
      changeValidationMessage('');
      return user;
    }
  }


  void logout() {

    _repository.logout();
  }


  dispose() {

    _currentUser.close();
    _email.close();
    _password.close();
    _validationMessage.close();
  }
}