
import 'package:flutter/material.dart';
import 'package:mpos/components/CheckboxWithLabel.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({
    Key? key,
    required this.accountBox,
  }) : super(key: key);

  final Box<Account> accountBox;

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

  final bool isAdmin = true;
  String _error = '';

  final formKey = GlobalKey<FormState>();

  bool passwordMatches() {
    return passwordTextController.text == confirmPasswordTextController.text;
  }

  void registerAdminAccount() {
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
      isAdmin: isAdmin,
    );

    try {
      widget.accountBox.put(newAccount);
    } on UniqueViolationException {
      setState(() {
        _error = 'This Email Address is used already!';
      });
      return;
    }

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Admin Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const HeaderOne(
                  padding: EdgeInsets.all(30),
                  text: 'Admin Account Registration',
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Column(
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
                                vertical: 20, horizontal: 20),
                            isPassword: false,
                          ),
                          TextFormFieldWithLabel(
                            label: 'Middle Name',
                            controller: middleNameTextController,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            isPassword: false,
                          ),
                          TextFormFieldWithLabel(
                            label: 'Last Name',
                            controller: lastNameTextController,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            isPassword: false,
                          ),
                          TextFormFieldWithLabel(
                            label: 'Contact Number',
                            controller: contactNumberTextController,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            isPassword: false,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: Column(
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
                                vertical: 20, horizontal: 20),
                            isPassword: false,
                          ),
                          TextFormFieldWithLabel(
                            label: 'Password',
                            controller: passwordTextController,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            isPassword: true,
                          ),
                          TextFormFieldWithLabel(
                            label: 'Confirm Password',
                            controller: confirmPasswordTextController,
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            isPassword: true,
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
                              CheckboxWithLabel(
                                label: 'Admin Account',
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                value: isAdmin,
                                onChange: (bool? val) {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: registerAdminAccount,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
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
    );
  }
}
