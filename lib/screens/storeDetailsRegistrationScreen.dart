import 'package:flutter/material.dart';

class StoreDetailsRegistrationScreen extends StatefulWidget {
  const StoreDetailsRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<StoreDetailsRegistrationScreen> createState() =>
      _StoreDetailsRegistrationScreenState();
}

class _StoreDetailsRegistrationScreenState
    extends State<StoreDetailsRegistrationScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Store Details Registration'),
      ),
    );
  }
}
