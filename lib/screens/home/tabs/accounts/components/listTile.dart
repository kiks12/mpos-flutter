import 'package:flutter/material.dart';
import 'package:mpos/models/account.dart';

class AccountListTile extends StatefulWidget {
  const AccountListTile({Key? key, required this.accounts, required this.index})
      : super(key: key);

  final List<Account> accounts;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
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
                  onPressed: () {},
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
                onPressed: () {},
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
