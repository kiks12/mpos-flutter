import 'package:flutter/material.dart';
import 'package:mpos/components/CheckboxWithLabel.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({
    Key? key,
    required this.admins,
    required this.accountBox,
  }) : super(key: key);

  final bool admins;
  final Box<Account> accountBox;

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
      isAdmin: widget.admins,
    );

    try {
      widget.accountBox.put(newAccount);
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
        title:
            Text(widget.admins ? 'Add Admin Account' : 'Add Employee Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
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
                                value: widget.admins,
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
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          child: Text('Back'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: createAccount,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
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
    );
  }
}
