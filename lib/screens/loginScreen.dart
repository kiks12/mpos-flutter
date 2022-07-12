import 'package:flutter/material.dart';
import 'package:mpos/models/objectBox.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.objectBox}) : super(key: key);

  final ObjectBox objectBox;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: const Center(
          child: Text('Login Screen'),
        ),
      ),
    );
  }
}
