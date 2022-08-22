
import 'package:flutter/material.dart';

import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/objectbox.g.dart';

import 'package:mpos/screens/home/tabs/accounts/accountsScreen.dart';
import 'package:mpos/screens/home/tabs/attendance/attendanceScreen.dart';
import 'package:mpos/screens/home/tabs/cashierScreen.dart';
import 'package:mpos/screens/home/tabs/dashboard/dashboardScreen.dart';
import 'package:mpos/screens/home/tabs/inventory/inventoryScreen.dart';
import 'package:mpos/screens/home/tabs/notificationScreen.dart';
import 'package:mpos/screens/home/tabs/settingsScreen.dart';
import 'package:mpos/screens/home/tabs/timeInTimeOutScreen.dart';
import 'package:mpos/screens/home/tabs/transactionsScreen.dart';
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

  late final _tabController =
      TabController(length: currentAccount!.isAdmin ? 8 : 4, vsync: this);
  static final now = DateTime.now();

  final List<ExpirationDate> _expiringNotifications = [];
  final List<ExpirationDate> _expiredNotifications = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      currentAccount = Utils().getCurrentAccount(objectBox);
    });
    getExpiringNotifications();
    getExpiredNotifications();
    // readCsvFile();
  }

  // void readCsvFile() async {
  //   final directory = (await getApplicationSupportDirectory()).path;
  //   final path = '$directory/csv-try.csv';
  //   final csvFile = File(path).openRead();
  //   final listValues = await csvFile
  //       .transform(utf8.decoder)
  //       .transform(const CsvToListConverter())
  //       .toList();
  //   for (int i = 0; i < listValues.length; i++) {
  //     if (i == 0) continue;
  //     final prod = listValues[i];
  //     objectBox.productBox.put(Product(
  //       name: prod[1],
  //       barcode: prod[2],
  //       category: prod[3],
  //       unitPrice: prod[4],
  //       quantity: prod[5],
  //       totalPrice: prod[6],
  //     ));
  //   }
  // }

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
          IconButton(
            iconSize: 32,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.notifications,
              color: Colors.blueGrey,
            ),
            onPressed: () {},
          ),
          _expiringNotifications.isNotEmpty
              ? Positioned(
                  top: 3,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 15,
                      minHeight: 15,
                    ),
                    child: Text(
                      '${_expiringNotifications.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
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
                  _notificationTab(),
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
                  accountsBox: objectBox.accountBox,
                ),
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
