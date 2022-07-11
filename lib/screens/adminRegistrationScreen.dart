import 'package:flutter/material.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<AdminRegistrationScreen> createState() =>
      _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Admin Registration Screen'),
      ),
    );
  }
}
