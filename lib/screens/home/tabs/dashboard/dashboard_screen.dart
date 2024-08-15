import 'package:flutter/material.dart';
import 'package:mpos/components/header_one.dart';
// import 'package:mpos/main.dart';
import 'package:mpos/screens/home/tabs/dashboard/components/fast_moving_products.dart';
import 'package:mpos/screens/home/tabs/dashboard/components/revenue_chart.dart';
import 'package:mpos/screens/home/tabs/dashboard/components/revenue_figures.dart';
import 'package:mpos/screens/home/tabs/dashboard/components/total_revenue_today.dart';

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
                  minHeight: MediaQuery.of(context).size.height * 0.75,
                  maxHeight: MediaQuery.of(context).size.height * 1,
                ),
                child: const Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: <Widget>[
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
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              HeaderOne(padding: EdgeInsets.all(0), text: 'Dashboard'),
            ],
          ),
        ),
      ],
    );
  }
}
