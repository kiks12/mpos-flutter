import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/objectBox.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/homeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.objectBox}) : super(key: key);

  final ObjectBox objectBox;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _error = '';
  final formKey = GlobalKey<FormState>();

  TextEditingController emailAddressTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  void exitApp() {
    exit(0);
  }

  void login() {
    if (!formKey.currentState!.validate()) return;
    String email = emailAddressTextController.text;
    String password = passwordTextController.text;

    final emailQuery = widget.objectBox.accountBox
        .query(Account_.emailAddress.equals(email))
        .build();
    final emailResult = emailQuery.find();

    if (emailResult.isEmpty) {
      setState(() {
        _error = 'Account not found!';
      });
      return;
    }

    Account currentAccount = emailResult[0];

    if (currentAccount.password != password) {
      setState(() {
        _error = 'Incorrect password!';
      });
      return;
    }

    setState(() {
      _error = '';
    });

    GetStorage().write('id', currentAccount.id);
    GetStorage().write('email', currentAccount.emailAddress);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const <Widget>[
                          HeaderOne(
                            padding: EdgeInsets.symmetric(vertical: 0),
                            text: 'Welcome',
                          ),
                          Text('Please Login to continue')
                        ],
                      ),
                    ),
                    TextFormFieldWithLabel(
                      label: 'Email Address',
                      controller: emailAddressTextController,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      isPassword: false,
                    ),
                    TextFormFieldWithLabel(
                      label: 'Password',
                      controller: passwordTextController,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      isPassword: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: exitApp,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 25),
                              child: Text('Exit'),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: login,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 25),
                              child: Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
