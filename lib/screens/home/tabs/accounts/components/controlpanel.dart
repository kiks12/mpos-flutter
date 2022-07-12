import 'package:flutter/material.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/accounts/addAccountScreen.dart';

class AccountsScreenControlPanel extends StatefulWidget {
  const AccountsScreenControlPanel({
    Key? key,
    required this.text,
    required this.padding,
    required this.accountBox,
  }) : super(key: key);

  final String text;
  final EdgeInsets padding;
  final Box<Account> accountBox;

  @override
  State<AccountsScreenControlPanel> createState() =>
      _AccountsScreenControlPnaelState();
}

class _AccountsScreenControlPnaelState
    extends State<AccountsScreenControlPanel> {
  final TextEditingController searchController = TextEditingController();

  void navigateToAddAccountScreen() {
    if (widget.text.contains('Admin')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddAccountScreen(
            admins: true,
            accountBox: widget.accountBox,
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAccountScreen(
          admins: false,
          accountBox: widget.accountBox,
        ),
      ),
    );
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              HeaderTwo(
                  padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                  text: widget.text),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text('Search'),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: navigateToAddAccountScreen,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text('Create User'),
            ),
          ),
        ],
      ),
    );
  }
}
