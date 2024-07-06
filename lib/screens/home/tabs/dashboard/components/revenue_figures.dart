import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/dashboard/components/revenue_split_figures.dart';

class RevenueFigures extends StatefulWidget {
  const RevenueFigures({Key? key}) : super(key: key);

  @override
  State<RevenueFigures> createState() => _RevenueFiguresState();
}

class _RevenueFiguresState extends State<RevenueFigures> {
  List<int> _revenueThisMonth = [];
  List<int> _revenueThisQuarter = [];
  List<int> _revenueThisYear = [];
  static final now = DateTime.now();
  final currencyFormatter = NumberFormat.currency(symbol: "₱");

  @override
  void initState() {
    super.initState();
    initializeThisMonthData();
    initializeThisYearData();
    initializeThisQuarterData();
  }

  @override
  void dispose() {
    super.dispose();
    _revenueThisYear = [];
    _revenueThisMonth = [];
    _revenueThisQuarter = [];
  }

  List<int> createRevenueSplit(Query<Transaction> transactionQuery) {
    final List<int> splits = [];
    final transactions = transactionQuery.find();
    splits.add(transactions.where((element) => element.paymentMethod == "Cash").fold(0, (previousValue, element) => previousValue + element.totalAmount));
    splits.add(transactions.where((element) => element.paymentMethod == "GCash").fold(0, (previousValue, element) => previousValue + element.totalAmount));
    splits.add(transactions.where((element) => element.paymentMethod == "Foodpanda").fold(0, (previousValue, element) => previousValue + element.totalAmount));
    splits.add(transactions.where((element) => element.paymentMethod == "Grab").fold(0, (previousValue, element) => previousValue + element.totalAmount));

    return splits;
  }

  void initializeThisMonthData() {
    final transactionQueryBuilder = objectBox.transactionBox.query(
      Transaction_.date.between(
          DateTime(now.year, now.month, 1).millisecondsSinceEpoch,
          DateTime(now.year, now.month, 31).millisecondsSinceEpoch),
    ).build();
    final totalRevenue = transactionQueryBuilder.property(Transaction_.totalAmount).sum();
    final revenueSplits = createRevenueSplit(transactionQueryBuilder);

    _revenueThisMonth.add(totalRevenue);
    _revenueThisMonth.add(revenueSplits[0]);
    _revenueThisMonth.add(revenueSplits[1]);
    _revenueThisMonth.add(revenueSplits[2]);
    _revenueThisMonth.add(revenueSplits[3]);
    setState(() {});
  }

  int getQuarter() {
    if (now.month >= 1 && now.month <= 3) return 1;
    if (now.month >= 4 && now.month <= 6) return 4;
    if (now.month >= 7 && now.month <= 9) return 7;
    return 9;
  }

  void initializeThisQuarterData() {
    int quarter = getQuarter();
    final firstDate = DateTime(now.year, quarter, 1);
    final secondDate = DateTime(now.year, quarter + 2, 31);
    final transactionQueryBuilder = objectBox.transactionBox.query(
      Transaction_.date.between(
          firstDate.millisecondsSinceEpoch, secondDate.millisecondsSinceEpoch),
    ).build();
    final totalRevenue = transactionQueryBuilder.property(Transaction_.totalAmount).sum();
    final revenueSplits = createRevenueSplit(transactionQueryBuilder);

    _revenueThisQuarter.add(totalRevenue);
    _revenueThisQuarter.add(revenueSplits[0]);
    _revenueThisQuarter.add(revenueSplits[1]);
    _revenueThisQuarter.add(revenueSplits[2]);
    _revenueThisQuarter.add(revenueSplits[3]);
    setState(() {});
  }

  void initializeThisYearData() {
    final transactionQueryBuilder = objectBox.transactionBox.query(
      Transaction_.date.between(DateTime(now.year, 1, 1).millisecondsSinceEpoch,
          DateTime(now.year, 12, 31).millisecondsSinceEpoch),
    ).build();
    final totalRevenue = transactionQueryBuilder.property(Transaction_.totalAmount).sum();
    final revenueSplits = createRevenueSplit(transactionQueryBuilder);

    _revenueThisYear.add(totalRevenue);
    _revenueThisYear.add(revenueSplits[0]);
    _revenueThisYear.add(revenueSplits[1]);
    _revenueThisYear.add(revenueSplits[2]);
    _revenueThisYear.add(revenueSplits[3]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Container(
                padding: const EdgeInsets.all(15),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.20,
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenue This Month'),
                    Text(currencyFormatter.format(_revenueThisMonth[0]),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 44,
                      ),
                    ),
                    RevenueSplitFigures(revenues: _revenueThisMonth),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                padding: const EdgeInsets.all(15),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.20,
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenue This Quarter'),
                    Text(currencyFormatter.format(_revenueThisQuarter[0]),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 44,
                      ),
                    ),
                    RevenueSplitFigures(revenues: _revenueThisQuarter),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Container(
                padding: const EdgeInsets.all(15),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.20,
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenue This Year'),
                    Text(currencyFormatter.format(_revenueThisYear[0]),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 44,
                      ),
                    ),
                    RevenueSplitFigures(revenues: _revenueThisYear),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
