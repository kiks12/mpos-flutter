import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/accounts/components/accounts_header.dart';
import 'package:mpos/screens/home/tabs/accounts/components/accounts_tab_bar.dart';
import 'package:mpos/screens/home/tabs/accounts/tabs/admins.dart';
import 'package:mpos/screens/home/tabs/accounts/tabs/employees.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late Stream<Query<Account>> adminAccountsStream;
  late Stream<Query<Account>> employeeAccountsStream;
  List<Account> _employeeList = [];
  List<Account> _adminList = [];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    super.dispose();
    _adminList = [];
    _employeeList = [];
  }

  void refresh() {
    initializeAdminAccountsStream();
    initializeEmployeeAccountsStream();
  }

  void searchAccount(String stringToSearch) {
    final adminQueryBuilder = objectBox.accountBox.query(
      Account_.isAdmin.equals(true).andAll([
      Account_.firstName.contains(stringToSearch, caseSensitive: false)
        .or(Account_.lastName.contains(stringToSearch, caseSensitive: false))
        .or(Account_.middleName.contains(stringToSearch, caseSensitive: false))
        .or(Account_.emailAddress.contains(stringToSearch, caseSensitive: false))
        .or(Account_.contactNumber.contains(stringToSearch, caseSensitive: false))
      ])
    ).order(Account_.id);
    final employeeQueryBuilder = objectBox.accountBox.query(
        Account_.isAdmin.equals(false).andAll([
          Account_.firstName.contains(stringToSearch, caseSensitive: false)
              .or(Account_.lastName.contains(stringToSearch, caseSensitive: false))
              .or(Account_.middleName.contains(stringToSearch, caseSensitive: false))
              .or(Account_.emailAddress.contains(stringToSearch, caseSensitive: false))
              .or(Account_.contactNumber.contains(stringToSearch, caseSensitive: false))
        ])
    ).order(Account_.id);
    adminAccountsStream = adminQueryBuilder.watch(triggerImmediately: true);
    employeeAccountsStream = employeeQueryBuilder.watch(triggerImmediately: true);

    adminAccountsStream.listen((event) {
      _adminList = event.find();
      setState(() {});
    });
    employeeAccountsStream.listen((event) {
      _employeeList = event.find();
      setState(() {});
    });
  }

  void initializeAdminAccountsStream() {
    final adminAccountQueryBuilder = objectBox.accountBox
        .query(Account_.isAdmin.equals(true))
      ..order(Account_.id, flags: Order.descending);
    adminAccountsStream =
        adminAccountQueryBuilder.watch(triggerImmediately: true);

    adminAccountsStream.listen((event) {
      _adminList = event.find();
      setState(() {});
    });
  }

  void initializeEmployeeAccountsStream() {
    final nonAdminAccountQueryBuilder = objectBox.accountBox
        .query(Account_.isAdmin.equals(false))
      ..order(Account_.id, flags: Order.descending);
    employeeAccountsStream =
        nonAdminAccountQueryBuilder.watch(triggerImmediately: true);

    employeeAccountsStream.listen((event) {
      _employeeList = event.find();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AccountsScreenControlPanel(
                refresh: refresh,
                searchCallback: searchAccount,
              ),
              const AccountsScreenTabBar(),
              Expanded(
                child: TabBarView(
                  children: [
                    EmployeesAccountsTab(employeeList: _employeeList),
                    AdminAccountsTab(adminList: _adminList),
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
