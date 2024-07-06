import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({Key? key}) : super(key: key);

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final formKey = GlobalKey<FormState>();
  String _error = '';

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
  bool _isAdmin = false;
  bool _showPassword = false;

  bool passwordMatches() {
    return passwordTextController.text == confirmPasswordTextController.text;
  }

  void createAccount() {
    if (!formKey.currentState!.validate()) return;

    if (!passwordMatches()) {
      setState(() {
        _error = 'Password does not match';
      });
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
      Fluttertoast.showToast(msg: "Successfully created new account");
    } on UniqueViolationException {
      setState(() {
        _error = 'This Email Address is used already!';
      });
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create new Account'),
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
                                onTap: () {
                                  _isAdmin = !_isAdmin;
                                  setState(() {});
                                },
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
                                      Checkbox(value: _isAdmin, onChanged: (newVal) {
                                        _isAdmin = newVal!;
                                        setState(() {});
                                      }),
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
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text('Back'),
                            ),
                          ),
                          FilledButton(
                            onPressed: createAccount,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text('Create Account'),
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
