import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/main.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/accounts/add_account_screen.dart';

class AccountsScreenControlPanel extends StatefulWidget {
  const AccountsScreenControlPanel({
    Key? key,
    required this.refresh,
    required this.searchCallback,
  }) : super(key: key);

  final void Function() refresh;
  final void Function(String) searchCallback;

  @override
  State<AccountsScreenControlPanel> createState() =>
      _AccountsScreenControlPnaelState();
}

class _AccountsScreenControlPnaelState
    extends State<AccountsScreenControlPanel> {
  final TextEditingController searchController = TextEditingController();

  void navigateToAddAccountScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAccountScreen(),
      ),
    );
    return;
  }

  void deleteAll() {
    objectBox.accountBox.query(Account_.isAdmin.equals(false)).build().remove();
    Fluttertoast.showToast(msg: "Successfully deleted employee accounts");
    Navigator.of(context).pop();
  }

  Future<void> showDeleteAllConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Employee Accounts'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    'Are you sure you want to delete all employee accounts?')
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
              onPressed: deleteAll,
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  width: 300,
                  height: 40,
                  child: TextFormField(
                    maxLines: 1,
                    minLines: 1,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        labelText: "Search",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)
                        )
                    ),
                    controller: searchController,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.search),
                onPressed: () {
                  widget.searchCallback(searchController.text);
                  searchController.text = "";
                },
                label: const Text('Search'),
              ),
              IconButton.filledTonal(onPressed: widget.refresh, icon: const Icon(Icons.refresh))
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: FilledButton.icon(
                    style: IconButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(255, 230, 230, 1),
                        foregroundColor: Colors.red
                    ),
                    icon: const Icon(Icons.delete),
                    onPressed: showDeleteAllConfirmationDialog,
                    label: const Text("Delete All")
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                onPressed: navigateToAddAccountScreen,
                label: const Text('Create User'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
