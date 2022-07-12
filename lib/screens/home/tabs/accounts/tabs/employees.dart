import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/accounts/components/controlpanel.dart';
import 'package:mpos/screens/home/tabs/accounts/components/listTile.dart';

class EmployeesAccountsTab extends StatefulWidget {
  const EmployeesAccountsTab({
    Key? key,
    required this.accountsBox,
  }) : super(key: key);

  final Box<Account> accountsBox;

  @override
  State<EmployeesAccountsTab> createState() => _EmployeesAccountsTabState();
}

class _EmployeesAccountsTabState extends State<EmployeesAccountsTab> {
  late Stream<Query<Account>> employeeAccountsStream;

  final StreamController<List<Account>> _employeeListController =
      StreamController<List<Account>>(sync: true);

  @override
  void initState() {
    super.initState();
    initializeEmployeeAccountsStream();
  }

  @override
  void dispose() {
    _employeeListController.close();
    super.dispose();
  }

  void initializeEmployeeAccountsStream() {
    final nonAdminAccountQueryBuilder = widget.accountsBox
        .query(Account_.isAdmin.equals(false))
      ..order(Account_.id, flags: Order.descending);
    employeeAccountsStream =
        nonAdminAccountQueryBuilder.watch(triggerImmediately: true);

    _employeeListController
        .addStream(employeeAccountsStream.map((query) => query.find()));
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
          text: 'Employee Accounts',
          padding: const EdgeInsets.all(0),
          accountBox: widget.accountsBox,
        ),
        Expanded(
          child: StreamBuilder<List<Account>>(
            stream: _employeeListController.stream,
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
