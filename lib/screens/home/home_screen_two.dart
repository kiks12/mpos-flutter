import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
// import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/components/home_screen_card/card_data.dart';
import 'package:mpos/screens/home/components/home_screen_card/home_screen_card.dart';
import 'package:mpos/screens/home/tabs/accounts/accounts_screen.dart';
import 'package:mpos/screens/home/tabs/attendance/attendance_screen.dart';
import 'package:mpos/screens/home/tabs/cashier/cashier_screen.dart';
import 'package:mpos/screens/home/tabs/dashboard/dashboard_screen.dart';
import 'package:mpos/screens/home/tabs/discounts/discounts_screen.dart';
import 'package:mpos/screens/home/tabs/inventory/inventory_screen.dart';
import 'package:mpos/screens/home/tabs/settings_screen.dart';
import 'package:mpos/screens/home/tabs/time_in_time_out_screen.dart';
import 'package:mpos/screens/home/tabs/transactions/transactions_screen.dart';
import 'package:mpos/utils/utils.dart';

// import '../../models/expiration_dates.dart';

class HomeScreenTwo extends StatefulWidget {
  const HomeScreenTwo({Key? key}) : super(key: key);

  @override
  State<HomeScreenTwo> createState() => _HomeScreenTwoState();
}

final cardData = [
  CardData(Icons.money, "Cashier", const CashierScreen()),
  CardData(Icons.inventory, "Inventory", const InventoryScreen()),
  CardData(Icons.discount, "Discounts", const DiscountsScreen()),
  CardData(Icons.receipt, "Transactions", const TransactionsScreen()),
  CardData(Icons.dashboard, "Dashboard", const DashboardScreen()),
  CardData(Icons.manage_accounts, "Accounts", const AccountsScreen()),
  CardData(Icons.supervisor_account, "Attendance", const AttendanceScreen()),
  CardData(Icons.punch_clock, "Log", const TimeInTimeOutScreen()),
  CardData(Icons.settings, "Settings", const SettingsScreen()),
];

final cardDataEmployee = [
  CardData(Icons.money, "Cashier", const CashierScreen()),
  CardData(Icons.inventory, "Inventory", const InventoryScreen()),
  CardData(Icons.discount, "Discounts", const DiscountsScreen()),
  CardData(Icons.receipt, "Transactions", const TransactionsScreen()),
  CardData(Icons.punch_clock, "Log", const TimeInTimeOutScreen()),
  CardData(Icons.settings, "Settings", const SettingsScreen()),
];

class _HomeScreenTwoState extends State<HomeScreenTwo> with SingleTickerProviderStateMixin {
  Account? currentAccount;
  String? storeName;

  // static final now = DateTime.now();

  // final List<ExpirationDate> _expiringNotifications = [];
  // final List<ExpirationDate> _expiredNotifications = [];

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  String _serverAccount = "";
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    currentAccount = Utils().getCurrentAccount(objectBox);
    storeName = objectBox.storeDetailsBox.getAll()[0].name;
    // _tabController = TabController(length: currentAccount!.isAdmin ? 10 : 4, vsync: this);
    // getExpiringNotifications();
    // getExpiredNotifications();

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

  // void getExpiringNotifications() {
  //   final expirationsNotificationQueryBuilder =
  //   objectBox.expirationDateBox.query(
  //     ExpirationDate_.date.between(now.millisecondsSinceEpoch,
  //         DateTime(now.year, now.month, now.day + 14).millisecondsSinceEpoch),
  //   );
  //   final expirationsNotificationQuery =
  //   expirationsNotificationQueryBuilder.build();
  //   final expirationsNotification = expirationsNotificationQuery.find();
  //
  //   for (var exp in expirationsNotification) {
  //     if (exp.quantity != exp.sold + exp.expired) {
  //       setState(() {
  //         _expiringNotifications.add(exp);
  //       });
  //     }
  //   }
  // }

  // void getExpiredNotifications() {
  //   final expirationsNotificationQueryBuilder =
  //   objectBox.expirationDateBox.query(
  //     ExpirationDate_.date.lessOrEqual(now.millisecondsSinceEpoch),
  //   );
  //   final expirationsNotificationQuery =
  //   expirationsNotificationQueryBuilder.build();
  //   final expirationsNotification = expirationsNotificationQuery.find();
  //
  //   for (var exp in expirationsNotification) {
  //     if (exp.quantity != exp.sold + exp.expired) {
  //       setState(() {
  //         _expiredNotifications.add(exp);
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: ((_serverAccount != "" && _connectionStatus.last != ConnectivityResult.none) || _serverAccount == "") ? [
              Text("${storeName!} MPOS", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w600),),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12)),
              Expanded(
                child: (currentAccount!.isAdmin) ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 2, mainAxisSpacing: 2),
                  itemBuilder: (context, index) {
                    final data = cardData[index];
                    return HomeScreenCard(cardData: data);
                  },
                  itemCount: cardData.length,
                ) : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 2, mainAxisSpacing: 2),
                  itemBuilder: (context, index) {
                    final data = cardDataEmployee[index];
                    return HomeScreenCard(cardData: data);
                  },
                  itemCount: cardDataEmployee.length,
                ),
              ),
            ] : [
              const HeaderOne(padding: EdgeInsets.zero, text: "Internet not Available"),
              Text("Connection Result: $_connectionStatus"),
              Text("Server Account: $_serverAccount"),
              const Text("Logout your server account to continue without internet connection"),
              const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              FilledButton(onPressed: logoutServerAccount, child: const Text("Logout"))
            ],
          ),
        ),
      ),
    );
  }
}
