import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mpos/components/copyright.dart';
import 'package:mpos/routes/routes.dart';
import 'package:mpos/screens/home/components/dashboard/dashboard_summary.dart';
import 'package:mpos/screens/home/components/home_screen_card/card_data.dart';
import 'package:mpos/screens/home/components/home_screen_card/home_screen_card.dart';
import 'package:mpos/screens/home/tabs/cashier/cashier_screen.dart';
import 'package:mpos/screens/home/tabs/discounts/discounts_screen.dart';
import 'package:mpos/screens/home/tabs/inventory/inventory_screen.dart';
import 'package:mpos/screens/home/tabs/transactions/transactions_screen.dart';
import 'package:mpos/services/shared_preferences_service.dart';

class HomeScreenTwo extends StatefulWidget {
  const HomeScreenTwo({Key? key}) : super(key: key);

  @override
  State<HomeScreenTwo> createState() => _HomeScreenTwoState();
}

final homeScreenCardData = [
  CardData(Icons.money, "Cashier", const CashierScreen()),
  CardData(Icons.inventory, "Inventory", const InventoryScreen()),
  CardData(Icons.discount, "Discounts", const DiscountsScreen()),
  CardData(Icons.receipt, "Sales", const TransactionsScreen()),
  // CardData(Icons.dashboard, "Dashboard", const DashboardScreen()),
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

class _HomeScreenTwoState extends State<HomeScreenTwo> with SingleTickerProviderStateMixin {
  String? posDeviceName;
  String? location;
  String? businessName;

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                            height: MediaQuery.of(context).size.height * 0.70, 
                            child: Expanded(
                              child: Center(
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 2, mainAxisSpacing: 2),
                                  itemBuilder: (context, index) {
                                    final data = homeScreenCardData;
                                    final indexedData = data[index];
                                    return HomeScreenCard(cardData: indexedData!);
                                  },
                                  itemCount: homeScreenCardData.length,
                                ),
                              )
                            ),
                          ),
                        ]
                      ),
                    ),

                    // Dashboard Component
                    Expanded(
                      child: const DashboardSummary() 
                    )
                  ],
                ),
              ),
              const Copyright(),
            ],
          ),
        ),
      ),
    );
  }
}
