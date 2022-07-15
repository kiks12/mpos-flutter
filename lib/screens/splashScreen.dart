import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/models/objectBox.dart';
import 'package:mpos/screens/home/homeScreen.dart';
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

    if (GetStorage().read('email') == null) {
      startTimer(
        LoginScreen(objectBox: widget.objectBox),
      );
      return;
    }

    startTimer(
      const HomeScreen(),
    );
  }

  void startTimer(dynamic nextScreen) {
    Duration duration = const Duration(seconds: 3);
    Timer(duration, () => navigateToNextScreen(nextScreen));
  }

  void navigateToNextScreen(dynamic nextScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => nextScreen,
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
