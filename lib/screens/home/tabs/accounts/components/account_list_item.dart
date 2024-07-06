
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/screens/home/tabs/accounts/edit_account_screen.dart';

class AccountListTile extends StatefulWidget {
  const AccountListTile({
    Key? key,
    required this.account,
  }) : super(key: key);

  final Account account;

  @override
  State<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends State<AccountListTile> {

  @override
  void initState() {
    super.initState();
  }

  void deleteAccount() {
    objectBox.accountBox.remove(widget.account.id);
    Fluttertoast.showToast(msg: "Successfully deleted account");
  }

  void navigateToEditScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAccountScreen(
          account: widget.account,
          accountBox: objectBox.accountBox,
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
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
                      '${widget.account.lastName}, ${widget.account.firstName} - ${widget.account.emailAddress}'),
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
            FilledButton(
              child: const Text('Confirm'),
              onPressed: () {
                deleteAccount();
                Navigator.of(context).pop();
              },
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
                child: Text(widget.account.firstName[0].toUpperCase()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        '${widget.account.lastName}, ${widget.account.firstName} ${widget.account.middleName[0].toUpperCase()}.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(widget.account.contactNumber),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: IconButton.filled(
                  icon: const Icon(Icons.edit),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.blue, backgroundColor: const Color.fromRGBO(230, 230, 255, 1)
                  ),
                  onPressed: navigateToEditScreen,
                ),
              ),
              IconButton.filled(
                icon: const Icon(Icons.delete),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.red, backgroundColor: const Color.fromRGBO(255, 230, 230, 1)
                ),
                onPressed: showDeleteConfirmationDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
