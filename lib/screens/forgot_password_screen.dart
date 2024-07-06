
import 'package:flutter/material.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/objectbox.g.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String _error = '';
  bool _showPassword = false;
  final formKey = GlobalKey<FormState>();

  TextEditingController emailAddressTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController confirmPasswordTextController = TextEditingController();

  void changePassword() {
    if (!formKey.currentState!.validate()) return;
    String email = emailAddressTextController.text;

    final emailQuery = objectBox.accountBox
        .query(Account_.emailAddress.equals(email))
        .build();
    final emailResult = emailQuery.findFirst();

    if (emailResult == null) {
      _error = 'Account not found!';
      setState(() {});
      return;
    }

    String password = passwordTextController.text;
    String confirmPassword = confirmPasswordTextController.text;

    if (password != confirmPassword) {
      _error = 'Password not matching!';
      setState(() {});
      return;
    }

    try {
      emailResult.password = confirmPassword;
      objectBox.accountBox.put(emailResult);
      _error = "Successfully changed account password";
      setState(() {});
    } catch (e) {
      _error = e.toString();
      setState(() {});
    }
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
                            text: 'Change Password',
                          ),
                          Text('Fill out the form to change your password')
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
                    TextFormFieldWithLabel(
                      label: 'Confirm Password',
                      controller: confirmPasswordTextController,
                      padding: const EdgeInsets.only(top: 0),
                      isPassword: !_showPassword,
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
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Text('Login now'),
                            ),
                          ),
                          FilledButton(
                            onPressed: changePassword,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Text('Change Password'),
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
