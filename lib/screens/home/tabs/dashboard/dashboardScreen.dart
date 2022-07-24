import 'package:flutter/material.dart';
import 'package:mpos/components/HeaderOne.dart';
// import 'package:mpos/main.dart';
import 'package:mpos/screens/home/tabs/dashboard/components/fastMovingProducts.dart';
import 'package:mpos/screens/home/tabs/dashboard/components/revenueChart.dart';
import 'package:mpos/screens/home/tabs/dashboard/components/revenueFigures.dart';
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
            children: [
              const DashboardScreenHeader(),
              Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.65,
                  maxHeight: MediaQuery.of(context).size.height * 0.78,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: const <Widget>[
                          Expanded(
                            child: TotalRevenueToday(),
                          ),
                          Expanded(
                            child: FastMovingProducts(),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const RevenueFigures(),
              const RevenueChart(),
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
  }) : super(key: key);

  @override
  State<DashboardScreenHeader> createState() => _DashboardScreenHeaderState();
}

class _DashboardScreenHeaderState extends State<DashboardScreenHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const HeaderOne(padding: EdgeInsets.all(0), text: 'Dashboard'),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.blueGrey,
                ),
                onPressed: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  child: Text('Export xlsx'),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 15),
              //   child: Row(
              //     children: [
              //       ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //           primary: Colors.white,
              //           onPrimary: Colors.blueGrey,
              //         ),
              //         onPressed: () {},
              //         child: const Padding(
              //           padding:
              //               EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              //           child: Text('Less than 10'),
              //         ),
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 10),
              //         child: ElevatedButton(
              //           style: ElevatedButton.styleFrom(
              //             primary: Colors.white,
              //             onPrimary: Colors.blueGrey,
              //           ),
              //           onPressed: () {},
              //           child: const Padding(
              //             padding: EdgeInsets.symmetric(
              //                 vertical: 15, horizontal: 25),
              //             child: Text('Less than 5'),
              //           ),
              //         ),
              //       ),
              //       ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //           primary: Colors.white,
              //           onPrimary: Colors.blueGrey,
              //         ),
              //         onPressed: () {},
              //         child: const Padding(
              //           padding:
              //               EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              //           child: Text('Refresh'),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}
