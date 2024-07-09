
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/components/header_one.dart';

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

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  String _serverAccount = "";
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    currentAccount = Utils().getCurrentAccount(objectBox);
    _tabController = TabController(length: currentAccount!.isAdmin ? 10 : 4, vsync: this);
    getExpiringNotifications();
    getExpiredNotifications();

    initConnectivity();
    initServerAccount();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void initServerAccount() {
    _serverAccount = Utils().getServerAccount();
    setState(() {});
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return Future.value(null);

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    initServerAccount();
    _connectionStatus = result;
    setState(() {});
  }

  void logoutServerAccount() {
    FirebaseAuth.instance.signOut();
    Utils().removeServerAccount();
    Fluttertoast.showToast(msg: "Server Account Logged out");
    initConnectivity();
    initServerAccount();
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
        child: ((_serverAccount != "" && _connectionStatus.last != ConnectivityResult.none) || _serverAccount == "") ? TabBar(
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
        ) : Container(),
      ),
      body: ((_serverAccount != "" && _connectionStatus.last != ConnectivityResult.none) || _serverAccount == "") ? TabBarView(
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
      ) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HeaderOne(padding: EdgeInsets.zero, text: "Internet not Available"),
            Text("Connection Result: $_connectionStatus"),
            Text("Server Account: $_serverAccount"),
            const Text("Logout your server account to continue without internet connection"),
            const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
            FilledButton(onPressed: logoutServerAccount, child: const Text("Logout"))
          ],
        ),
      ),
    );
  }
}
