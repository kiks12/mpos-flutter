import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/screens/admin_registration_screen.dart';
import 'package:mpos/screens/restore_data_screen_local.dart';

class StartUpMenuScreen extends StatefulWidget {
  const StartUpMenuScreen({Key? key}) : super(key: key);

  @override
  State<StartUpMenuScreen> createState() => _StartUpMenuScreenState();
}

class _StartUpMenuScreenState extends State<StartUpMenuScreen> {
  void navigateToAdminRegistrationScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AdminRegistrationScreen(),
      ),
    );
  }

  void navigateToRestoreFromJsonScreen() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocalRestoreDataScreen(),
      ),
    );
  }

  void exitApp() {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: const Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderOne(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              text: 'Start Up'),
                          Text('Please select an option to continue.')
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: navigateToAdminRegistrationScreen,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          child: Text('Create new Admin Account'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: navigateToRestoreFromJsonScreen,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            child: Text('Restore from json files'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: exitApp,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          child: Text('Exit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
