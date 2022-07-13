import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/utils/utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void logout() {
    GetStorage().remove('id');
    GetStorage().remove('email');

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
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
            const SettingsHeader(),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      width: 1, color: Color.fromARGB(255, 228, 228, 228)),
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.5,
              child: TextButton(
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Edit Account'),
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
  const SettingsHeader({Key? key}) : super(key: key);

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
  Account? currentAccount;
  @override
  void initState() {
    super.initState();
    setState(() {
      currentAccount = Utils().getCurrentAccount(objectBox);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              child: Text(currentAccount!.firstName[0].toUpperCase()),
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
                        '${currentAccount!.lastName}, ${currentAccount!.firstName} ${currentAccount!.middleName[0].toUpperCase()}.',
                  ),
                  Text(currentAccount!.emailAddress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
