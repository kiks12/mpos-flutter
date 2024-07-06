
import 'package:flutter/material.dart';

import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/expiration_dates.dart';
import 'package:mpos/objectbox.g.dart';

import 'package:mpos/screens/home/tabs/accounts/accounts_screen.dart';
import 'package:mpos/screens/home/tabs/attendance/attendance_screen.dart';
import 'package:mpos/screens/home/tabs/cashier/cashier_screen.dart';
import 'package:mpos/screens/home/tabs/dashboard/dashboard_screen.dart';
import 'package:mpos/screens/home/tabs/inventory/inventory_screen.dart';
import 'package:mpos/screens/home/tabs/notification_screen.dart';
import 'package:mpos/screens/home/tabs/settings_screen.dart';
import 'package:mpos/screens/home/tabs/time_in_time_out_screen.dart';
import 'package:mpos/screens/home/tabs/transactions/transactions_screen.dart';
import 'package:mpos/screens/home/tabs/discounts/discounts_screen.dart';
import 'package:mpos/utils/utils.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Account? currentAccount;

  late TabController _tabController;
  static final now = DateTime.now();

  final List<ExpirationDate> _expiringNotifications = [];
  final List<ExpirationDate> _expiredNotifications = [];

  @override
  void initState() {
    super.initState();
    currentAccount = Utils().getCurrentAccount(objectBox);
    _tabController = TabController(length: currentAccount!.isAdmin ? 10 : 4, vsync: this);
    getExpiringNotifications();
    getExpiredNotifications();
    setState(() {});
  }

  void getExpiringNotifications() {
    final expirationsNotificationQueryBuilder =
        objectBox.expirationDateBox.query(
      ExpirationDate_.date.between(now.millisecondsSinceEpoch,
          DateTime(now.year, now.month, now.day + 14).millisecondsSinceEpoch),
    );
    final expirationsNotificationQuery =
        expirationsNotificationQueryBuilder.build();
    final expirationsNotification = expirationsNotificationQuery.find();

    for (var exp in expirationsNotification) {
      if (exp.quantity != exp.sold + exp.expired) {
        setState(() {
          _expiringNotifications.add(exp);
        });
      }
    }
  }

  void getExpiredNotifications() {
    final expirationsNotificationQueryBuilder =
        objectBox.expirationDateBox.query(
      ExpirationDate_.date.lessOrEqual(now.millisecondsSinceEpoch),
    );
    final expirationsNotificationQuery =
        expirationsNotificationQueryBuilder.build();
    final expirationsNotification = expirationsNotificationQuery.find();

    for (var exp in expirationsNotification) {
      if (exp.quantity != exp.sold + exp.expired) {
        setState(() {
          _expiredNotifications.add(exp);
        });
      }
    }
  }

  Tab _notificationTab() {
    return Tab(
      child: Stack(
        children: <Widget>[
          const Icon(Icons.notifications, size: 24,),
          _expiringNotifications.isNotEmpty
              ? Positioned(
                  top: 3,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${_expiringNotifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Positioned(
                  top: 3,
                  right: 0,
                  child: Container(),
                ),
        ],
      ),
    );
  }

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
                      'Log',
                      style: TextStyle(color: Colors.black),
                    )
                  ),
                  const Tab(
                    child: Text(
                      'Inventory',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const Tab(
                    child: Text(
                      'Discounts',
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
                      'Transactions',
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
                  _notificationTab(),
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
                      'Log',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const Tab(
                    child: Text(
                      'Settings',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  _notificationTab(),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: currentAccount!.isAdmin
            ? [
                const CashierScreen(),
                TimeInTimeOutScreen(
                  tabController: _tabController,
                ),
                const InventoryScreen(),
                const DiscountsScreen(),
                const AccountsScreen(),
                const AttendanceScreen(),
                const TransactionsScreen(),
                const DashboardScreen(),
                const SettingsScreen(),
                NotificationScreen(
                  expiredNotifications: _expiredNotifications,
                  expiringNotifications: _expiringNotifications,
                ),
              ]
            : [
                const CashierScreen(),
                TimeInTimeOutScreen(
                  tabController: _tabController,
                ),
                const SettingsScreen(),
                NotificationScreen(
                  expiredNotifications: _expiredNotifications,
                  expiringNotifications: _expiringNotifications,
                ),
              ],
      ),
    );
  }
}
