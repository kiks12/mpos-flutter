
import 'package:flutter/material.dart';
import 'package:mpos/components/copyright.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 2), () {
      checkNextScreen();
    });
  }

  Future<void> checkNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.get("user_id");
    final deviceId = prefs.get("device_id");

    if (userId == null) {
      if (mounted) Navigator.of(context).pushNamed(supabaseLoginScreenRoute);
    }

    if (userId != null && deviceId == null) {
      if (mounted) Navigator.of(context).pushNamed(posDeviceSelectionScreenRoute);
    }

    if (userId != null && deviceId != null) {
      if (mounted) Navigator.of(context).pushNamed(homeScreenRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: HeaderOne(
                    padding: const EdgeInsets.all(0),
                    text: 'LOGO',
                  ),
                ),
              ),
              // const Padding(padding: EdgeInsets.symmetric(vertical: 100)),
              const Copyright(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
