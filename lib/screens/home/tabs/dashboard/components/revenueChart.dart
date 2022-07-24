import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/main.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/dashboard/model/sales.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RevenueChart extends StatefulWidget {
  const RevenueChart({Key? key}) : super(key: key);

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  static final now = DateTime.now();
  List<DateTime> _dates = [];
  List<Sales> _salesData = [];
  String _dropdownValue = 'Last 7 Days';
  List<String> items = [
    'Last 7 Days',
    'Last 30 Days',
    'Monthly',
    'Quarterly',
    'Semi Annually',
    'Annually',
  ];

  void dropdownOnChange(String newValue) {
    setState(() {
      _dropdownValue = newValue;
    });

    switch (_dropdownValue) {
      case 'Last 7 Days':
        getLastSevenDaysDates();
        initializeChartData();
        break;

      case 'Last 30 Days':
        getLastThirtyDaysDates();
        initializeChartData();
        break;

      case 'Monthly':
        getMonthlyDates();
        initializeChartDataForMonthly();
        break;

      case 'Quarterly':
        getQuarterlyDates();
        initializeChartDataForQuarterly();
        break;

      case 'Semi Annually':
        getSemiAnnuallyDates();
        initializeChartDataForSemiAnnually();
        break;

      case 'Annually':
        getAnnuallyDates();
        initializeChartDataForAnnually();
        break;

      default:
        break;
    }
  }

  void getLastSevenDaysDates() {
    _dates = [];
    for (int i = 6; i >= 0; i--) {
      _dates.add(DateTime(now.year, now.month, now.day - i));
    }
  }

  void getLastThirtyDaysDates() {
    _dates = [];
    for (int i = 29; i >= 0; i--) {
      _dates.add(DateTime(now.year, now.month, now.day - i));
    }
  }

  void getMonthlyDates() {
    _dates = [];
    for (int i = 1; i <= 12; i++) {
      _dates.add(DateTime(now.year, i, 1));
    }
  }

  void getQuarterlyDates() {
    _dates = [];
    for (int i = 1; i <= 12; i += 3) {
      _dates.add(DateTime(now.year, i, 1));
    }
  }

  void getSemiAnnuallyDates() {
    _dates = [];
    for (int i = 1; i <= 12; i += 6) {
      _dates.add(DateTime(now.year, i, 1));
    }
  }

  void getAnnuallyDates() {
    _dates = [];
    for (int i = 0; i < 12; i++) {
      _dates.add(DateTime(2020 + i, 1, 1));
    }
  }

  void initializeChartData() {
    setState(() {
      _salesData = [];
    });
    for (var date in _dates) {
      final revenueQueryBuilder = objectBox.transactionBox
          .query(Transaction_.date.equals(date.millisecondsSinceEpoch));
      final revenueQuery = revenueQueryBuilder.build();
      final revenue = revenueQuery.property(Transaction_.totalAmount).sum();

      setState(() {
        _salesData.add(Sales(DateFormat('yyyy-MM-dd').format(date), revenue));
      });
    }
  }

  void initializeChartDataForMonthly() {
    setState(() {
      _salesData = [];
    });
    for (var date in _dates) {
      final revenueQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
            date.millisecondsSinceEpoch,
            DateTime(date.year, date.month, date.day - 30)
                .millisecondsSinceEpoch),
      );
      final revenueQuery = revenueQueryBuilder.build();
      final revenue = revenueQuery.property(Transaction_.totalAmount).sum();

      setState(() {
        _salesData.add(Sales(DateFormat('MMM').format(date), revenue));
      });
    }
  }

  void initializeChartDataForQuarterly() {
    setState(() {
      _salesData = [];
    });
    for (var date in _dates) {
      final secondDate = DateTime(date.year, date.month + 2, 30);
      final revenueQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
            date.millisecondsSinceEpoch, secondDate.millisecondsSinceEpoch),
      );
      final revenueQuery = revenueQueryBuilder.build();
      final revenue = revenueQuery.property(Transaction_.totalAmount).sum();

      setState(() {
        _salesData.add(
          Sales(
              '${DateFormat('MMM').format(date)} - ${DateFormat('MMM').format(secondDate)}',
              revenue),
        );
      });
    }
  }

  void initializeChartDataForSemiAnnually() {
    setState(() {
      _salesData = [];
    });
    for (var date in _dates) {
      final secondDate = DateTime(date.year, date.month + 5, 30);
      final revenueQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
            date.millisecondsSinceEpoch, secondDate.millisecondsSinceEpoch),
      );
      final revenueQuery = revenueQueryBuilder.build();
      final revenue = revenueQuery.property(Transaction_.totalAmount).sum();

      setState(() {
        _salesData.add(
          Sales(
              '${DateFormat('MMM').format(date)} - ${DateFormat('MMM').format(secondDate)}',
              revenue),
        );
      });
    }
  }

  void initializeChartDataForAnnually() {
    setState(() {
      _salesData = [];
    });
    for (var date in _dates) {
      final secondDate = DateTime(date.year, 12, 31);
      final revenueQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
            date.millisecondsSinceEpoch, secondDate.millisecondsSinceEpoch),
      );
      final revenueQuery = revenueQueryBuilder.build();
      final revenue = revenueQuery.property(Transaction_.totalAmount).sum();

      setState(() {
        _salesData.add(
          Sales(DateFormat('yyyy').format(date), revenue),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getLastSevenDaysDates();
    initializeChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.height * 0.62,
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HeaderTwo(
                  padding: EdgeInsets.zero,
                  text: 'Revenue Chart',
                ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                      onPressed: () {},
                      child: DropdownButton<String>(
                        value: _dropdownValue,
                        underline: Container(
                          width: 0,
                          color: Colors.transparent,
                        ),
                        style: const TextStyle(color: Colors.blueGrey),
                        onChanged: (String? newValue) {
                          dropdownOnChange(newValue as String);
                        },
                        items:
                            items.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              height: MediaQuery.of(context).size.height * 0.5,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: 45,
                ),
                trackballBehavior: TrackballBehavior(
                  enable: true,
                ),
                series: <LineSeries<Sales, String>>[
                  LineSeries<Sales, String>(
                    // Bind data source
                    dataSource: _salesData,
                    xValueMapper: (Sales sales, _) => sales.identifier,
                    yValueMapper: (Sales sales, _) => sales.sales,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
