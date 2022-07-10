import 'package:flutter/material.dart';
import 'package:mpos/screens/home/tabs/accountsScreen.dart';
import 'package:mpos/screens/home/tabs/attendanceScreen.dart';
import 'package:mpos/screens/home/tabs/cashierScreen.dart';
import 'package:mpos/screens/home/tabs/dashboardScreen.dart';
import 'package:mpos/screens/home/tabs/inventoryScreen.dart';
import 'package:mpos/screens/home/tabs/settingsScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 6,
      child: Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Cashier',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Inventory',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Accounts',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Attendance',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Dashboard',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Settings',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CashierScreen(),
            InventoryScreen(),
            AccountsScreen(),
            AttendanceScreen(),
            DashboardScreen(),
            SettingsScreen(),
          ],
        ),
      ),
    );
  }
}
