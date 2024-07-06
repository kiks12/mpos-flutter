import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/object_box.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/admin_registration_screen.dart';
import 'package:mpos/screens/forgot_password_screen.dart';
import 'package:mpos/screens/home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.objectBox}) : super(key: key);

  final ObjectBox objectBox;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _error = '';
  bool _showPassword = false;
  final formKey = GlobalKey<FormState>();

  TextEditingController emailAddressTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  void exitApp() {
    exit(0);
  }

  void navigateToForgotPasswordScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
  }

  void navigateToAdminRegistrationScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AdminRegistrationScreen()));
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
      _error = 'Account not found!';
      setState(() {});
      return;
    }

    Account currentAccount = emailResult[0];

    if (currentAccount.password != password) {
      _error = 'Incorrect password!';
      setState(() {});
      return;
    }

    _error = '';
    setState(() {});

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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
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
                      padding: const EdgeInsets.only(top: 15),
                      isPassword: !_showPassword,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: GestureDetector(
                            onTap: () {
                              _showPassword = !_showPassword;
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Checkbox(value: _showPassword, onChanged: (newVal) {
                                  _showPassword = newVal!;
                                  setState(() {});
                                }),
                                const Text("Show Password")
                              ],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: navigateToForgotPasswordScreen,
                          child: const Text("Forgot Password?"),
                        )
                      ],
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
                                  vertical: 5, horizontal: 10),
                              child: Text('Exit'),
                            ),
                          ),
                          FilledButton(
                            onPressed: login,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(onPressed: navigateToAdminRegistrationScreen, child: const Text("Create new Admin Account")),
                      ],
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
