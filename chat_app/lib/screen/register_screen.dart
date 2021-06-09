import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  FirebaseApp app;

  RegisterScreen({required this.app});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('REGISTER'),
      ),
      body: Center(
        child: Text('REGISTER SCREEN'),
      ),
    );
  }
}