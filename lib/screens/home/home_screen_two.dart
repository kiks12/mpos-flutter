import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/components/copyright.dart';
import 'package:mpos/components/header_one.dart';
import 'package:mpos/main.dart';
import 'package:mpos/routes/routes.dart';
import 'package:mpos/screens/home/components/home_screen_card/card_data.dart';
import 'package:mpos/screens/home/components/home_screen_card/home_screen_card.dart';
import 'package:mpos/screens/home/tabs/cashier/cashier_screen.dart';
import 'package:mpos/screens/home/tabs/dashboard/dashboard_screen.dart';
import 'package:mpos/screens/home/tabs/discounts/discounts_screen.dart';
import 'package:mpos/screens/home/tabs/inventory/inventory_screen.dart';
import 'package:mpos/screens/home/tabs/transactions/transactions_screen.dart';
import 'package:mpos/services/shared_preferences_service.dart';
import 'package:mpos/utils/utils.dart';

class HomeScreenTwo extends StatefulWidget {
  const HomeScreenTwo({Key? key}) : super(key: key);

  @override
  State<HomeScreenTwo> createState() => _HomeScreenTwoState();
}

final cardDataFreeTrial = [
  CardData(Icons.money, "Cashier", const CashierScreen()),
  CardData(Icons.inventory, "Inventory", const InventoryScreen()),
  CardData(Icons.receipt, "Sales", const TransactionsScreen()),
  // CardData(Icons.settings, "Settings", const SettingsScreen()),
];

final cardDataBasic = [
  CardData(Icons.money, "Cashier", const CashierScreen()),
  CardData(Icons.inventory, "Inventory", const InventoryScreen()),
  CardData(Icons.discount, "Discounts", const DiscountsScreen()),
  CardData(Icons.receipt, "Sales", const TransactionsScreen()),
  // CardData(Icons.settings, "Settings", const SettingsScreen()),
];

final cardDataPro = [
  CardData(Icons.money, "Cashier", const CashierScreen()),
  CardData(Icons.inventory, "Inventory", const InventoryScreen()),
  CardData(Icons.discount, "Discounts", const DiscountsScreen()),
  CardData(Icons.receipt, "Sales", const TransactionsScreen()),
  // CardData(Icons.manage_accounts, "Accounts", const AccountsScreen()),
  // CardData(Icons.supervisor_account, "Attendance", const AttendanceScreen()),
  // CardData(Icons.punch_clock, "Log", const TimeInTimeOutScreen()),
  // CardData(Icons.settings, "Settings", const SettingsScreen()),
];

final cardDataPremium = [
  CardData(Icons.money, "Cashier", const CashierScreen()),
  CardData(Icons.inventory, "Inventory", const InventoryScreen()),
  CardData(Icons.discount, "Discounts", const DiscountsScreen()),
  CardData(Icons.receipt, "Sales", const TransactionsScreen()),
  CardData(Icons.dashboard, "Dashboard", const DashboardScreen()),
  // CardData(Icons.manage_accounts, "Accounts", const AccountsScreen()),
  // CardData(Icons.supervisor_account, "Attendance", const AttendanceScreen()),
  // CardData(Icons.punch_clock, "Log", const TimeInTimeOutScreen()),
  // CardData(Icons.settings, "Settings", const SettingsScreen()),
];

class CardDataMap {
  List<CardData> data;
  int length;

  CardDataMap(this.data, this.length);
}

final Map<String, CardDataMap> cardDataMap = {
  "FREE_TRIAL": CardDataMap(cardDataFreeTrial, cardDataFreeTrial.length),
  "BASIC": CardDataMap(cardDataBasic, cardDataBasic.length),
  "PRO": CardDataMap(cardDataPro, cardDataPro.length),
  "PREMIUM": CardDataMap(cardDataPremium, cardDataPremium.length),
};

class _HomeScreenTwoState extends State<HomeScreenTwo> with SingleTickerProviderStateMixin {
  String? posDeviceName;
  String? location;
  String? businessName;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    getSharedPreferencesValues();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  Future<void> getSharedPreferencesValues() async {
    posDeviceName = await SharedPreferencesService.get("device_name");
    location = await SharedPreferencesService.get("location_name");
    businessName = await SharedPreferencesService.get("business_name");
    setState(() {});
  }


  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: e.message!);
      return;
    }

    if (!mounted) return Future.value(null);

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _connectionStatus = result;
    setState(() {});
  }

  void logoutServerAccount() {
    FirebaseAuth.instance.signOut();
    Utils().removeServerAccount();
    Fluttertoast.showToast(msg: "Server Account Logged out");
    initConnectivity();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dataMap = cardDataMap[posTier];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
          children: ((_connectionStatus.last != ConnectivityResult.none)) ? [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(businessName ?? "No Business Name", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.point_of_sale,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${posDeviceName ?? "No Device Name"} MPOS", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),),
                              Text(location ?? "No Location", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey),),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: (){
                      Navigator.of(context).pushNamed(settingsScreenRoute);
                    },
                    icon: const Icon(Icons.settings, size: 20),
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45, 
                child: Expanded(
                  child: Center(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 2, mainAxisSpacing: 2),
                      itemBuilder: (context, index) {
                        final data = dataMap?.data;
                        final indexedData = data?[index];
                        return HomeScreenCard(cardData: indexedData!);
                      },
                      itemCount: dataMap?.length,
                    ),
                  )
                ),
              ),
              const SizedBox(height: 70),
              const Copyright(),
            ] : [
              const HeaderOne(padding: EdgeInsets.zero, text: "Internet not Available"),
              Text("Connection Result: $_connectionStatus"),
              const Text("Logout your server account to continue without internet connection"),
              const Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              FilledButton(onPressed: logoutServerAccount, child: const Text("Logout")),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12)),
              const Copyright(),
            ],
          ),
        ),
      ),
    );
  }
}
