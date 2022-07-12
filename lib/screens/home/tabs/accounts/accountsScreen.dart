import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/accounts/tabs/admins.dart';
import 'package:mpos/screens/home/tabs/accounts/tabs/employees.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({
    Key? key,
    required this.accountsBox,
  }) : super(key: key);

  final Box<Account> accountsBox;

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late Stream<Query<Account>> adminAccountsStream;

  final StreamController<List<Account>> _adminListController =
      StreamController<List<Account>>(sync: true);

  @override
  void initState() {
    super.initState();
    initializeAdminAccountsStream();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const AccountsScreenTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    EmployeesAccountsTab(
                      accountsBox: widget.accountsBox,
                    ),
                    AdminAccountsTab(
                      accountsBox: widget.accountsBox,
                    ),
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

class AccountsScreenTabBar extends StatefulWidget {
  const AccountsScreenTabBar({Key? key}) : super(key: key);

  @override
  State<AccountsScreenTabBar> createState() => _AccountsScreenTabBarState();
}

class _AccountsScreenTabBarState extends State<AccountsScreenTabBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: const TabBar(
        tabs: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Employees',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Admins',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
