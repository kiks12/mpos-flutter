import 'package:flutter/material.dart';

import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/objectBox.dart';
import 'package:mpos/screens/home/tabs/accounts/accountsScreen.dart';
import 'package:mpos/screens/home/tabs/attendanceScreen.dart';
import 'package:mpos/screens/home/tabs/cashierScreen.dart';
import 'package:mpos/screens/home/tabs/dashboardScreen.dart';
import 'package:mpos/screens/home/tabs/inventoryScreen.dart';
import 'package:mpos/screens/home/tabs/settingsScreen.dart';
import 'package:mpos/utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.objectBox,
  }) : super(key: key);

  final ObjectBox objectBox;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Account? currentAccount;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentAccount = Utils().getCurrentAccount(objectBox);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: currentAccount!.isAdmin ? 6 : 2,
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: TabBar(
            tabs: currentAccount!.isAdmin
                ? [
                    const Tab(
                      child: Text(
                        'Cashier',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const Tab(
                      child: Text(
                        'Inventory',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const Tab(
                      child: Text(
                        'Accounts',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const Tab(
                      child: Text(
                        'Attendance',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const Tab(
                      child: Text(
                        'Dashboard',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const Tab(
                      child: Text(
                        'Settings',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ]
                : [
                    const Tab(
                      child: Text(
                        'Cashier',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const Tab(
                      child: Text(
                        'Settings',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
          ),
        ),
        body: TabBarView(
          children: currentAccount!.isAdmin
              ? [
                  const CashierScreen(),
                  const InventoryScreen(),
                  AccountsScreen(
                    accountsBox: widget.objectBox.accountBox,
                  ),
                  const AttendanceScreen(),
                  const DashboardScreen(),
                  const SettingsScreen(),
                ]
              : [
                  const CashierScreen(),
                  const SettingsScreen(),
                ],
        ),
      ),
    );
  }
}
