import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/accounts/components/controlpanel.dart';
import 'package:mpos/screens/home/tabs/accounts/components/listTile.dart';

class AdminAccountsTab extends StatefulWidget {
  const AdminAccountsTab({
    Key? key,
    required this.accountsBox,
  }) : super(key: key);

  final Box<Account> accountsBox;

  @override
  State<AdminAccountsTab> createState() => AdminAccountsTabState();
}

class AdminAccountsTabState extends State<AdminAccountsTab> {
  late Stream<Query<Account>> adminAccountsStream;

  final StreamController<List<Account>> _adminListController =
      StreamController<List<Account>>(sync: true);

  @override
  void initState() {
    super.initState();
    initializeAdminAccountsStream();
  }

  @override
  void dispose() {
    _adminListController.close();
    super.dispose();
  }

  void initializeAdminAccountsStream() {
    final adminAccountQueryBuilder = widget.accountsBox
        .query(Account_.isAdmin.equals(true))
      ..order(Account_.id, flags: Order.descending);
    adminAccountsStream =
        adminAccountQueryBuilder.watch(triggerImmediately: true);

    _adminListController
        .addStream(adminAccountsStream.map((query) => query.find()));
  }

  AccountListTile Function(BuildContext, int) _itemBuilder(
      List<Account> accounts) {
    return (BuildContext context, int index) {
      return AccountListTile(
        accounts: accounts,
        index: index,
        accountsBox: widget.accountsBox,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccountsScreenControlPanel(
          text: 'Admin Accounts',
          padding: const EdgeInsets.all(0),
          accountBox: widget.accountsBox,
        ),
        Expanded(
          child: StreamBuilder<List<Account>>(
            stream: _adminListController.stream,
            builder: ((context, snapshot) => ListView.builder(
                  itemBuilder: _itemBuilder(snapshot.data ?? []),
                  shrinkWrap: true,
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  padding: const EdgeInsets.all(10),
                )),
          ),
        ),
      ],
    );
  }
}
