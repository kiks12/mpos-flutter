
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
  int _totalRevenueTodayCash = 0;
  int _totalRevenueTodayGCash = 0;
  int _totalRevenueTodayFoodpanda = 0;
  int _totalRevenueTodayGrab = 0;
  double _salesGrowth = 0;
  final NumberFormat currencyFormatter = NumberFormat.currency(symbol: "₱");
  final NumberFormat percentFormatter = NumberFormat.percentPattern();
  List<String> items = ["Now", "Specific"];
  String _dropdownValue = "Now";
  DateTime _selectedDate = DateTime.now();

  List<Sales> threeDaySpanDataSource = [];

  @override
  void initState() {
    super.initState();
    initializeRevenueData();
    initializeSalesGrowthData();
    initializeThreeDayData();
  }

  void initializeRevenueData() {
    final transactionQueryBuilder = objectBox.transactionBox.query(Transaction_.date
        .equals(DateTime.parse(DateFormat('yyyy-MM-dd').format(_selectedDate))
            .millisecondsSinceEpoch));
    final transactionQuery = transactionQueryBuilder.build();
    final transactions = transactionQuery.find();
    _totalRevenueTodayCash = transactions.where((element) => element.paymentMethod == "Cash").fold(0, (previousValue, element) => previousValue + element.totalAmount);
    _totalRevenueTodayGCash = transactions.where((element) => element.paymentMethod == "GCash").fold(0, (previousValue, element) => previousValue + element.totalAmount);
    _totalRevenueTodayFoodpanda = transactions.where((element) => element.paymentMethod == "Foodpanda").fold(0, (previousValue, element) => previousValue + element.totalAmount);
    _totalRevenueTodayGrab = transactions.where((element) => element.paymentMethod == "Grab").fold(0, (previousValue, element) => previousValue + element.totalAmount);
    _totalRevenueToday =
        transactionQuery.property(Transaction_.totalAmount).sum();
    setState(() {});
  }

  void initializeSalesGrowthData() {
    final transactionYesterdayQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.equals(DateTime.parse(DateFormat('yyyy-MM-dd').format(
                DateTime(_selectedDate.year, _selectedDate.month,
                    _selectedDate.day - 1)))
            .millisecondsSinceEpoch));
    final transactionYesterdayQuery = transactionYesterdayQueryBuilder.build();

    _totalRevenueYesterday =
        transactionYesterdayQuery.property(Transaction_.totalAmount).sum();
    _salesGrowth = _totalRevenueYesterday == 0
        ? 0
        : ((_totalRevenueToday - _totalRevenueYesterday) /
            _totalRevenueYesterday);
    setState(() {});
  }

  void initializeThreeDayData() {
    threeDaySpanDataSource = [];
    final transactionLastTwoDaysAgoQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.equals(DateTime.parse(DateFormat('yyyy-MM-dd').format(
                DateTime(_selectedDate.year, _selectedDate.month,
                    _selectedDate.day - 2)))
            .millisecondsSinceEpoch));
    final transactionLastTwoDaysAgoQuery =
        transactionLastTwoDaysAgoQueryBuilder.build();
    final revenueLastTwoDaysAgo =
        transactionLastTwoDaysAgoQuery.property(Transaction_.totalAmount).sum();
    final selectedDate = _selectedDate;

    threeDaySpanDataSource.add(
      Sales(
          DateFormat('yyyy-MM-dd')
              .format(DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 2)),
          revenueLastTwoDaysAgo),
    );
    threeDaySpanDataSource.add(
      Sales(
          DateFormat('yyyy-MM-dd')
              .format(DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 1)),
          _totalRevenueYesterday),
    );
    threeDaySpanDataSource.add(
      Sales(DateFormat('yyyy-MM-dd').format(selectedDate), _totalRevenueToday),
    );
    setState(() {});
  }

  void dropdownOnChange(String newValue) {
    _dropdownValue = newValue;
    setState(() {});

    if (newValue == "Now") {
      _selectedDate = DateTime.now();
      initializeRevenueData();
      initializeSalesGrowthData();
      initializeThreeDayData();
      setState(() {});
      return;
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );

    if (selected != null && selected != _selectedDate) {
      _selectedDate = selected;
      setState(() {});
    }

    initializeRevenueData();
    initializeSalesGrowthData();
    initializeThreeDayData();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.05,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Date Type"),
                                SizedBox(
                                  width: 150,
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _dropdownValue,
                                    onChanged: (String? newValue) {
                                      dropdownOnChange(newValue as String);
                                    },
                                    items: items.map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_selectedDate.toString()),
                                FilledButton.tonalIcon(
                                  icon: const Icon(Icons.date_range),
                                  onPressed: (_dropdownValue == "Specific") ? () => _selectDate(context) : null,
                                  label: const Text('Select Date'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.18,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        // boxShadow: const <BoxShadow>[
                        //   BoxShadow(
                        //     blurRadius: 7,
                        //     color: Color.fromARGB(255, 216, 216, 216),
                        //     offset: Offset(0, 10),
                        //   )
                        // ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Today'),
                            Text(currencyFormatter.format(_totalRevenueToday),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.18,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        // boxShadow: const <BoxShadow>[
                        //   BoxShadow(
                        //     blurRadius: 7,
                        //     color: Color.fromARGB(255, 216, 216, 216),
                        //     offset: Offset(0, 10),
                        //   )
                        // ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daily Sales Growth'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  percentFormatter.format(_salesGrowth),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 40,
                                    color: _salesGrowth == 0
                                        ? const Color.fromARGB(255, 176, 158, 0)
                                        : _salesGrowth > 0
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
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
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.10,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              width: 5,
                              color: Theme.of(context).colorScheme.primary
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          // boxShadow: const <BoxShadow>[
                          //   BoxShadow(
                          //     blurRadius: 7,
                          //     color: Color.fromARGB(255, 216, 216, 216),
                          //     offset: Offset(0, 10),
                          //   )
                          // ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cash'),
                              Text(currencyFormatter.format(_totalRevenueTodayCash),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.10,
                        ),
                        decoration: BoxDecoration(
                          border: const Border(
                            left: BorderSide(
                                width: 5,
                                color: Colors.blue
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          // boxShadow: const <BoxShadow>[
                          //   BoxShadow(
                          //     blurRadius: 7,
                          //     color: Color.fromARGB(255, 216, 216, 216),
                          //     offset: Offset(0, 10),
                          //   )
                          // ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('GCash'),
                              Text(currencyFormatter.format(_totalRevenueTodayGCash),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.10,
                        ),
                        decoration: BoxDecoration(
                          border: const Border(
                            left: BorderSide(
                                width: 5,
                                color: Colors.pink
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          // boxShadow: const <BoxShadow>[
                          //   BoxShadow(
                          //     blurRadius: 7,
                          //     color: Color.fromARGB(255, 216, 216, 216),
                          //     offset: Offset(0, 10),
                          //   )
                          // ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Foodpanda'),
                              Text(currencyFormatter.format(_totalRevenueTodayFoodpanda),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.10,
                        ),
                        decoration: BoxDecoration(
                          border: const Border(
                            left: BorderSide(
                                width: 5,
                                color: Colors.green
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          // boxShadow: const <BoxShadow>[
                          //   BoxShadow(
                          //     blurRadius: 7,
                          //     color: Color.fromARGB(255, 216, 216, 216),
                          //     offset: Offset(0, 10),
                          //   )
                          // ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Grab'),
                              Text(currencyFormatter.format(_totalRevenueTodayGrab),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    // boxShadow: const <BoxShadow>[
                    //   BoxShadow(
                    //     blurRadius: 7,
                    //     color: Color.fromARGB(255, 216, 216, 216),
                    //     offset: Offset(0, 10),
                    //   )
                    // ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text('Three Day Span'),
                        ),
                        SfCartesianChart(
                          primaryXAxis: const CategoryAxis(),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <LineSeries<Sales, String>>[
                            LineSeries<Sales, String>(
                              name: "Revenue",
                              // Bind data source
                              dataSource: threeDaySpanDataSource,
                              xValueMapper: (Sales sales, _) =>
                                  sales.identifier,
                              yValueMapper: (Sales sales, _) => sales.sales
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
