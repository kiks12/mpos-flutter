import 'package:flutter/material.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/accounts/editAccountScreen.dart';

class AccountListTile extends StatefulWidget {
  const AccountListTile({
    Key? key,
    required this.accounts,
    required this.index,
    required this.accountsBox,
  }) : super(key: key);

  final List<Account> accounts;
  final Box<Account> accountsBox;
  final int index;

  @override
  State<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends State<AccountListTile> {
  Account? curr;

  @override
  void initState() {
    super.initState();
    setState(() {
      curr = widget.accounts[widget.index];
    });
  }

  void deleteAccount(BuildContext context) {
    widget.accountsBox.remove(curr!.id);
    Navigator.of(context).pop();
  }

  void navigateToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAccountScreen(
          account: curr,
          accountBox: widget.accountsBox,
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Are you sure you want to delete this account?'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                      '${curr!.lastName}, ${curr!.firstName} - ${curr!.emailAddress}'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: () => deleteAccount(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                child: Text(curr!.firstName[0].toUpperCase()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        '${curr!.lastName}, ${curr!.firstName} ${curr!.middleName[0].toUpperCase()}.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(curr!.contactNumber),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  onPressed: navigateToEditScreen,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Text('Edit'),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                ),
                onPressed: showDeleteConfirmationDialog,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
