import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/screens/backupDataScreen.dart';
import 'package:mpos/screens/home/tabs/accounts/editAccountScreen.dart';
import 'package:mpos/screens/restoreDataScreen.dart';
import 'package:mpos/utils/utils.dart';

const serverUploadAPIEndpoint =
    'https://mpos-data-center.herokuapp.com/backup/upload/';
const loginAPIEndpoint = 'https://mpos-data-center.herokuapp.com/login/';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Account? currentAccount;

  final formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();

  String _error = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      currentAccount = Utils().getCurrentAccount(objectBox);
    });
  }

  void navigateToBackupScreen(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const BackupDataScreen())));
  }

  void navigateToRestoreDataScreen(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const RestoreDataScreen())));
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

  void _resetApp() {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != currentAccount!.password) {
      setState(() {
        _error = 'Incorrect Password';
      });
      return;
    }

    objectBox.accountBox.removeAll();
    objectBox.attendanceBox.removeAll();
    objectBox.expirationDateBox.removeAll();
    objectBox.transactionBox.removeAll();
    objectBox.ingredientBox.removeAll();
    objectBox.storeDetailsBox.removeAll();
    objectBox.productBox.removeAll();

    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => const MyApp())));
  }

  void _onCancel(void Function(void Function()) setState) {
    passwordController.text = '';
    setState(() {
      _error = '';
    });
    Navigator.pop(context);
  }

  Future<void> _showResetDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                  ElevatedButton(
                    child: const Text('Confirm'),
                    onPressed: _resetApp,
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
      body: Center(
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
                  onPressed: () => navigateToBackupScreen(context),
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
                  onPressed: () => navigateToRestoreDataScreen(context),
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
                child: Text(widget.currentAccount!.firstName[0].toUpperCase()),
                radius: 40,
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
