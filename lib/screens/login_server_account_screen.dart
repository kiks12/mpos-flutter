
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mpos/utils/utils.dart';

class LoginServerAccountScreen extends StatefulWidget {
  const LoginServerAccountScreen({Key? key}) : super(key: key);

  @override
  State<LoginServerAccountScreen> createState() => _LoginServerAccountScreenState();
}

class _LoginServerAccountScreenState extends State<LoginServerAccountScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  bool _showPassword = false;
  final formKey = GlobalKey<FormState>();

  TextEditingController emailAddressTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  void loginServerAccount() async {
    try {
      final email = emailAddressTextController.value.text;
      final password = passwordTextController.value.text;
      final signInResponse = await auth.signInWithEmailAndPassword(email: email, password: password);
      if (signInResponse.user != null) {
        Utils().writeServerAccount(email);
        Fluttertoast.showToast(msg: "Logged in as $email");
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
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
                            text: 'Login Server Account',
                          ),
                          Text('Please fill in the form to login to server')
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
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          border: Border.all(color: Theme.of(context).colorScheme.onSecondaryContainer, width: 0.5),
                          borderRadius: BorderRadius.circular(50)
                        ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Text('NOTE: Logging in to the server will require the system to always be connected to the internet'),
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed: loginServerAccount,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Text('Login'),
                            ),
                          ),
                        ],
                      ),
                    ),
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
