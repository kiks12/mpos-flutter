import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/components/text_form_field_with_label.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/screens/backup_data_screen_local.dart';
import 'package:mpos/screens/home/tabs/accounts/edit_account_screen.dart';
import 'package:mpos/screens/login_server_account_screen.dart';
import 'package:mpos/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

import '../../restore_data_screen_local.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Account? currentAccount;
  final formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  String serverAccount = "";

  String _error = '';

  @override
  void initState() {
    super.initState();
    currentAccount = Utils().getCurrentAccount(objectBox);
    serverAccount = Utils().getServerAccount();
    setState(() {});
  }

  void navigateToLoginServerAccount() {
    Navigator.push(context, MaterialPageRoute(builder: ((context) => const LoginServerAccountScreen())));
  }

  void navigateToBackupScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const LocalBackupDataScreen())));
  }

  void navigateToRestoreDataScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const LocalRestoreDataScreen())));
  }

  void logoutServerAccount() async {
    try {
      await FirebaseAuth.instance.signOut();
      Utils().removeServerAccount();
      Fluttertoast.showToast(msg: "Logged out Server Account");
      serverAccount = Utils().getServerAccount();
      setState(() {});
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
    }
  }

  void logout() {
    GetStorage().remove('id');
    GetStorage().remove('email');

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
  }

  void navigateToEditAccountScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAccountScreen(
          account: currentAccount,
          accountBox: objectBox.accountBox,
        ),
      ),
    );
  }

  void _resetApp() async {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != currentAccount!.password) {
      _error = 'Incorrect Password';
      setState(() {});
      return;
    }

    GetStorage().remove('id');
    GetStorage().remove('email');

    objectBox.accountBox.removeAll();
    objectBox.attendanceBox.removeAll();
    objectBox.expirationDateBox.removeAll();
    objectBox.transactionBox.removeAll();
    objectBox.ingredientBox.removeAll();
    objectBox.storeDetailsBox.removeAll();
    objectBox.productBox.removeAll();
    objectBox.packagedProductBox.removeAll();
    objectBox.discountBox.removeAll();

    objectBox.store.close();

    final directory = await getApplicationDocumentsDirectory();
    final objectBoxDir = Directory('${directory.path}/objectbox');

    if (await objectBoxDir.exists()) {
      await objectBoxDir.delete(recursive: true);
    }

    Fluttertoast.showToast(msg: "Reset Successful! Exiting in 3 seconds");
    Timer(const Duration(seconds: 3), () {
      exit(0);
    });
  }

  void _onCancel(void Function(void Function()) setState) {
    passwordController.text = '';
    _error = '';
    setState(() {});
    Navigator.pop(context);
  }

  Future<void> _showResetDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: ((context, setState) => AlertDialog(
                title: const Text('Reset System'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                          'Resetting Mobile Point of Sale System. Please enter your admin password.'),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Form(
                          key: formKey,
                          child: TextFormFieldWithLabel(
                            label: 'Password',
                            controller: passwordController,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            isPassword: true,
                          ),
                        ),
                      ),
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => _onCancel(setState),
                  ),
                  FilledButton(
                    onPressed: _resetApp,
                    child: const Text('Confirm'),
                  ),
                ],
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderOne(padding: EdgeInsets.all(0), text: 'Settings'),
                  SettingsHeader(
                    currentAccount: currentAccount,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1, color: Color.fromARGB(255, 228, 228, 228)),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                      onPressed: navigateToEditAccountScreen,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Edit Account'),
                      ),
                    ),
                  ),
                  if (serverAccount == "") Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1, color: Color.fromARGB(255, 228, 228, 228)),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                      onPressed: navigateToLoginServerAccount,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Login Server Account'),
                      ),
                    ),
                  ),
                  if (serverAccount != "") Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1, color: Color.fromARGB(255, 228, 228, 228)),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                      onPressed: logoutServerAccount,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Logout Server Account'),
                      ),
                    ),
                  ),
                  if (currentAccount!.isAdmin)
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1, color: Color.fromARGB(255, 228, 228, 228)),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButton(
                        onPressed: navigateToBackupScreen,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Backup Database'),
                        ),
                      ),
                    ),
                  if (currentAccount!.isAdmin)
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1, color: Color.fromARGB(255, 228, 228, 228)),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButton(
                        onPressed: navigateToRestoreDataScreen,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Restore Data'),
                        ),
                      ),
                    ),
                  if (currentAccount!.isAdmin)
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1, color: Color.fromARGB(255, 228, 228, 228)),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: TextButton(
                        onPressed: _showResetDialog,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Reset System'),
                        ),
                      ),
                    ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1, color: Color.fromARGB(255, 228, 228, 228)),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                      onPressed: logout,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Logout'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsHeader extends StatefulWidget {
  const SettingsHeader({
    Key? key,
    required this.currentAccount,
  }) : super(key: key);

  final Account? currentAccount;

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                child: Text(widget.currentAccount!.firstName[0].toUpperCase()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderTwo(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      text:
                          '${widget.currentAccount!.lastName}, ${widget.currentAccount!.firstName} ${widget.currentAccount!.middleName[0].toUpperCase()}.',
                    ),
                    Text(widget.currentAccount!.emailAddress),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
