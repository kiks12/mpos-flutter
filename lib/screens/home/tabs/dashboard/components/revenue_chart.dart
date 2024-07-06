import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/header_two.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/transaction.dart';
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
  List<Sales> _cashData = [];
  List<Sales> _gcashData = [];
  List<Sales> _foodpandaData = [];
  List<Sales> _grabData = [];
  String _dropdownValue = 'Last 7 Days';

  static const List<String> items = [
    'Last 7 Days',
    'Last 30 Days',
    'Monthly',
    'Quarterly',
    'Semi Annually',
    'Annually',
  ];

  void dropdownOnChange(String newValue) {
    _dropdownValue = newValue;

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

  void clearRevenueData() {
    _salesData = [];
    _cashData = [];
    _gcashData = [];
    _grabData = [];
    _foodpandaData = [];
  }

  void setRevenueData(String dateString, Query<Transaction> transactionQuery) {
    final transactions = transactionQuery.find();
    int revenue = transactionQuery.property(Transaction_.totalAmount).sum();
    int cashRevenue = transactions.where((element) => element.paymentMethod == "Cash").fold(0, (previousValue, element) => previousValue + element.totalAmount);
    int gcashRevenue = transactions.where((element) => element.paymentMethod == "GCash").fold(0, (previousValue, element) => previousValue + element.totalAmount);
    int foodpandaRevenue = transactions.where((element) => element.paymentMethod == "Foodpanda").fold(0, (previousValue, element) => previousValue + element.totalAmount);
    int grabRevenue = transactions.where((element) => element.paymentMethod == "Grab").fold(0, (previousValue, element) => previousValue + element.totalAmount);

    _salesData.add(Sales(dateString, revenue));
    _cashData.add(Sales(dateString, cashRevenue));
    _gcashData.add(Sales(dateString, gcashRevenue));
    _foodpandaData.add(Sales(dateString, foodpandaRevenue));
    _grabData.add(Sales(dateString, grabRevenue));
  }

  void initializeChartData() {
    clearRevenueData();
    for (var date in _dates) {
      final transactionQueryBuilder = objectBox.transactionBox
          .query(Transaction_.date.equals(date.millisecondsSinceEpoch));
      final transactionQuery = transactionQueryBuilder.build();
      setRevenueData(DateFormat("yyyy-MM-dd").format(date), transactionQuery);
    }
    setState(() {});
  }

  void initializeChartDataForMonthly() {
    clearRevenueData();
    for (var date in _dates) {
      final transactionQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
            date.millisecondsSinceEpoch,
            DateTime(date.year, date.month, date.day - 30)
                .millisecondsSinceEpoch),
      );
      final transactionQuery = transactionQueryBuilder.build();
      setRevenueData(DateFormat("MMM").format(date), transactionQuery);
    }
    setState(() {});
  }

  void initializeChartDataForQuarterly() {
    clearRevenueData();
    for (var date in _dates) {
      final secondDate = DateTime(date.year, date.month + 2, 30);
      final transactionQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
            date.millisecondsSinceEpoch, secondDate.millisecondsSinceEpoch),
      );
      final transactionQuery = transactionQueryBuilder.build();
      setRevenueData('${DateFormat('MMM').format(date)} - ${DateFormat('MMM').format(secondDate)}', transactionQuery);
    }
    setState(() {});
  }

  void initializeChartDataForSemiAnnually() {
    clearRevenueData();
    for (var date in _dates) {
      final secondDate = DateTime(date.year, date.month + 5, 30);
      final transactionQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
            date.millisecondsSinceEpoch, secondDate.millisecondsSinceEpoch),
      );
      final transactionQuery = transactionQueryBuilder.build();
      setRevenueData('${DateFormat('MMM').format(date)} - ${DateFormat('MMM').format(secondDate)}', transactionQuery);
    }
    setState(() {});
  }

  void initializeChartDataForAnnually() {
    clearRevenueData();
    for (var date in _dates) {
      final secondDate = DateTime(date.year, 12, 31);
      final transactionQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(
            date.millisecondsSinceEpoch, secondDate.millisecondsSinceEpoch),
      );
      final transactionQuery = transactionQueryBuilder.build();
      setRevenueData(DateFormat('yyyy').format(date), transactionQuery);
    }
    setState(() {});
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
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
                    DropdownButton<String>(
                      value: _dropdownValue,
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
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              height: MediaQuery.of(context).size.height * 0.5,
              child: SfCartesianChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.right
                ),
                primaryXAxis: CategoryAxis(
                  labelRotation: 45,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
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
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    name: "Total"
                  ),
                  LineSeries<Sales, String>(
                    // Bind data source
                      dataSource: _cashData,
                      xValueMapper: (Sales sales, _) => sales.identifier,
                      yValueMapper: (Sales sales, _) => sales.sales,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      name: "Cash"
                  ),
                  LineSeries<Sales, String>(
                    // Bind data source
                      dataSource: _gcashData,
                      xValueMapper: (Sales sales, _) => sales.identifier,
                      yValueMapper: (Sales sales, _) => sales.sales,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      name: "GCash"
                  ),
                  LineSeries<Sales, String>(
                    // Bind data source
                      dataSource: _foodpandaData,
                      xValueMapper: (Sales sales, _) => sales.identifier,
                      yValueMapper: (Sales sales, _) => sales.sales,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      name: "Foodpanda"
                  ),
                  LineSeries<Sales, String>(
                    // Bind data source
                      dataSource: _grabData,
                      xValueMapper: (Sales sales, _) => sales.identifier,
                      yValueMapper: (Sales sales, _) => sales.sales,
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      name: "Grab"
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
