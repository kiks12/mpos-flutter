import 'package:flutter/material.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/screens/home/tabs/dashboard/components/totalRevenueToday.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: const [
              DashboardScreenHeader(),
              TotalRevenueToday(),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreenHeader extends StatefulWidget {
  const DashboardScreenHeader({
    Key? key,
    // required this.searchController,
    // required this.onPressed,
    // required this.refresh,
    // required this.deleteAll,
    // required this.addProduct,
    // required this.inventoryValue,
    // required this.showProductWithLessThan,
  }) : super(key: key);

  // final TextEditingController searchController;
  // final void Function() onPressed;
  // final void Function() refresh;
  // final void Function() deleteAll;
  // final void Function() addProduct;
  // final void Function(int) showProductWithLessThan;
  // final String inventoryValue;

  @override
  State<DashboardScreenHeader> createState() => _DashboardScreenHeaderState();
}

class _DashboardScreenHeaderState extends State<DashboardScreenHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const HeaderOne(padding: EdgeInsets.all(0), text: 'Dashboard'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.blueGrey,
                      ),
                      onPressed: () {},
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                        child: Text('Less than 10'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          onPrimary: Colors.blueGrey,
                        ),
                        onPressed: () {},
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          child: Text('Less than 5'),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.blueGrey,
                      ),
                      onPressed: () {},
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                        child: Text('Refresh'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
