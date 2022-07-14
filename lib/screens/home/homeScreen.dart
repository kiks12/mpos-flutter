import 'package:flutter/material.dart';

import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/objectBox.dart';
import 'package:mpos/screens/home/tabs/accounts/accountsScreen.dart';
import 'package:mpos/screens/home/tabs/attendance/attendanceScreen.dart';
import 'package:mpos/screens/home/tabs/cashierScreen.dart';
import 'package:mpos/screens/home/tabs/dashboardScreen.dart';
import 'package:mpos/screens/home/tabs/inventory/inventoryScreen.dart';
import 'package:mpos/screens/home/tabs/settingsScreen.dart';
import 'package:mpos/screens/home/tabs/timeInTimeOutScreen.dart';
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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Account? currentAccount;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentAccount = Utils().getCurrentAccount(objectBox);
    });
  }

  late final _tabController =
      TabController(length: currentAccount!.isAdmin ? 6 : 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: TabBar(
          controller: _tabController,
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
                      'Time In/Time Out',
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
        controller: _tabController,
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
                TimeInTimeOutScreen(
                  tabController: _tabController,
                ),
                const SettingsScreen(),
              ],
      ),
    );
  }
}
