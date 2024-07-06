
import 'package:flutter/material.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/screens/home/tabs/accounts/components/account_list_item.dart';

class AdminAccountsTab extends StatefulWidget {
  const AdminAccountsTab({
    Key? key,
    required this.adminList
  }) : super(key: key);

  final List<Account> adminList;

  @override
  State<AdminAccountsTab> createState() => AdminAccountsTabState();
}

class AdminAccountsTabState extends State<AdminAccountsTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _itemBuilder(Account account) {
    return AccountListTile(account: account);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) =>  _itemBuilder(widget.adminList[index]),
      shrinkWrap: true,
      itemCount: widget.adminList.length,
      padding: const EdgeInsets.all(10),
    );
  }
}
