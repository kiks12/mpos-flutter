import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/models/objectBox.dart';
import 'package:mpos/screens/loginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    Key? key,
    required this.storeName,
    required this.objectBox,
  }) : super(key: key);

  final String storeName;
  final ObjectBox objectBox;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    Duration duration = const Duration(seconds: 3);
    Timer(duration, navigateToNextScreen);
  }

  void navigateToNextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          objectBox: widget.objectBox,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: HeaderOne(
            padding: const EdgeInsets.all(0),
            text: '${widget.storeName} MPOS',
          ),
        ),
      ),
    );
  }
}
