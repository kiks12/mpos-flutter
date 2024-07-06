
import 'package:flutter/material.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({Key? key}) : super(key: key);


  @override
  State<AdminRegistrationScreen> createState() =>
      _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final TextEditingController firstNameTextController = TextEditingController();
  final TextEditingController middleNameTextController =
      TextEditingController();
  final TextEditingController lastNameTextController = TextEditingController();
  final TextEditingController contactNumberTextController =
      TextEditingController();
  final TextEditingController emailAddressTextController =
      TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController confirmPasswordTextController =
      TextEditingController();

  final _isAdmin = true;
  bool _showPassword = false;
  String _error = '';

  final formKey = GlobalKey<FormState>();

  bool passwordMatches() {
    return passwordTextController.text == confirmPasswordTextController.text;
  }

  void registerAdminAccount() {
    if (!formKey.currentState!.validate()) return;

    if (!passwordMatches()) {
      _error = 'Password does not match';
      setState(() {});
      return;
    }

    Account newAccount = Account(
      firstName: firstNameTextController.text,
      middleName: middleNameTextController.text,
      lastName: lastNameTextController.text,
      contactNumber: contactNumberTextController.text,
      emailAddress: emailAddressTextController.text,
      password: passwordTextController.text,
      isAdmin: _isAdmin,
    );

    try {
      objectBox.accountBox.put(newAccount);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MyApp()));
    } on UniqueViolationException {
      _error = 'This Email Address is used already!';
      setState(() {});
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Admin Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.50,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HeaderOne(
                      padding: EdgeInsets.all(30),
                      text: 'Admin Account Registration',
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const HeaderTwo(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          text: 'Personal Information',
                        ),
                        TextFormFieldWithLabel(
                          label: 'First Name',
                          controller: firstNameTextController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          isPassword: false,
                        ),
                        TextFormFieldWithLabel(
                          label: 'Middle Name',
                          controller: middleNameTextController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          isPassword: false,
                        ),
                        TextFormFieldWithLabel(
                          label: 'Last Name',
                          controller: lastNameTextController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          isPassword: false,
                        ),
                        TextFormFieldWithLabel(
                          label: 'Contact Number',
                          controller: contactNumberTextController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          isPassword: false,
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const HeaderTwo(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          text: 'Email and Password',
                        ),
                        TextFormFieldWithLabel(
                          label: 'Email Address',
                          controller: emailAddressTextController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          isPassword: false,
                        ),
                        TextFormFieldWithLabel(
                          label: 'Password',
                          controller: passwordTextController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          isPassword: _showPassword ? false : true,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          isPassword: _showPassword ? false : true,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0),
                              child: Text(
                                _error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: _isAdmin ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                                      border: Border.all(
                                          color: _isAdmin ? Theme.of(context).colorScheme.onPrimaryContainer : Colors.black26,
                                          width: 0.5
                                      )
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(value: _isAdmin, onChanged: (newVal) {}),
                                      const Text("Admin Account"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton(
                            onPressed: registerAdminAccount,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              child: Text('Register'),
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
