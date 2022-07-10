import 'package:flutter/material.dart';
import 'package:mpos/screens/homeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile POS',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const HomeScreen(),
    );
  }
}
