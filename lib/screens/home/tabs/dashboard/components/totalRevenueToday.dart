import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/dashboard/model/sales.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TotalRevenueToday extends StatefulWidget {
  const TotalRevenueToday({Key? key}) : super(key: key);

  @override
  State<TotalRevenueToday> createState() => _TotalRevenueTodayState();
}

class _TotalRevenueTodayState extends State<TotalRevenueToday> {
  int _totalRevenueYesterday = 0;
  int _totalRevenueToday = 0;
  double _salesGrowth = 0;
  final NumberFormat percentFormatter = NumberFormat.percentPattern();

  List<int> revenues = [];

  @override
  void initState() {
    super.initState();
    initializeRevenueData();
    initializeSalesGrowthData();
    initializeRevenues();
  }

  void initializeRevenueData() {
    final revenueQueryBuilder = objectBox.transactionBox.query(Transaction_.date
        .equals(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()))
            .millisecondsSinceEpoch));
    final revenueQuery = revenueQueryBuilder.build();
    setState(() {
      _totalRevenueToday =
          revenueQuery.property(Transaction_.totalAmount).sum();
    });
  }

  void initializeSalesGrowthData() {
    final revenueYesterdayQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.equals(DateTime.parse(DateFormat('yyyy-MM-dd').format(
                DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day - 1)))
            .millisecondsSinceEpoch));
    final revenueYesturdayQuery = revenueYesterdayQueryBuilder.build();

    setState(() {
      _totalRevenueYesterday =
          revenueYesturdayQuery.property(Transaction_.totalAmount).sum();
      _salesGrowth = _totalRevenueYesterday == 0
          ? 0
          : ((_totalRevenueToday - _totalRevenueYesterday) /
                  _totalRevenueYesterday) *
              100;
    });
  }

  void initializeRevenues() {
    final revenueLastTwoDaysAgoQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.equals(DateTime.parse(DateFormat('yyyy-MM-dd').format(
                DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day - 2)))
            .millisecondsSinceEpoch));
    final revenueLastTwoDaysAgoQuery =
        revenueLastTwoDaysAgoQueryBuilder.build();
    final revenueLastTwoDaysAgo =
        revenueLastTwoDaysAgoQuery.property(Transaction_.totalAmount).sum();
    setState(() {
      revenues.add(revenueLastTwoDaysAgo);
      revenues.add(_totalRevenueYesterday);
      revenues.add(_totalRevenueToday);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.18,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  blurRadius: 7,
                  color: Color.fromARGB(255, 216, 216, 216),
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Today'),
                  Text(
                    NumberFormat.currency(symbol: '₱')
                        .format(_totalRevenueToday),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.18,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    blurRadius: 7,
                    color: Color.fromARGB(255, 216, 216, 216),
                    offset: Offset(0, 10),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daily Sales Growth'),
                    Row(
                      children: [
                        Icon(
                          _salesGrowth == 0
                              ? Icons.horizontal_rule_rounded
                              : _salesGrowth > 0
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                          color: _salesGrowth == 0
                              ? const Color.fromARGB(255, 176, 158, 0)
                              : _salesGrowth > 0
                                  ? Colors.green
                                  : Colors.red,
                        ),
                        Text(
                          percentFormatter.format(_salesGrowth),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.525,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.18,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  blurRadius: 7,
                  color: Color.fromARGB(255, 216, 216, 216),
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Sales Growth'),
                  Expanded(
                    child: Container(
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <LineSeries<Sales, String>>[
                          LineSeries<Sales, String>(
                              // Bind data source
                              dataSource: <Sales>[
                                Sales('Jan', 35),
                                Sales('Feb', 28),
                                Sales('Mar', 34),
                                Sales('Apr', 32),
                                Sales('May', 40)
                              ],
                              xValueMapper: (Sales sales, _) =>
                                  sales.identifier,
                              yValueMapper: (Sales sales, _) => sales.sales)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
