import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/objectbox.g.dart';

class RevenueFigures extends StatefulWidget {
  const RevenueFigures({Key? key}) : super(key: key);

  @override
  State<RevenueFigures> createState() => _RevenueFiguresState();
}

class _RevenueFiguresState extends State<RevenueFigures> {
  int _revenueThisMonth = 0;
  int _revenueThisQuarter = 0;
  int _revenueThisYear = 0;
  static final now = DateTime.now();

  // static final quarters = [1, 3, 4, 6, 7, 9, 10, 12];

  @override
  void initState() {
    super.initState();
    initializeThisMonthData();
    initializeThisYearData();
    initializeThisQuarterData();
  }

  void initializeThisMonthData() {
    final revenueQueryBuilder = objectBox.transactionBox.query(
      Transaction_.date.between(
          DateTime(now.year, now.month, 1).millisecondsSinceEpoch,
          DateTime(now.year, now.month, 31).millisecondsSinceEpoch),
    );
    final revenueQuery =
        revenueQueryBuilder.build().property(Transaction_.totalAmount).sum();
    setState(() {
      _revenueThisMonth = revenueQuery;
    });
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
    final revenueQueryBuilder = objectBox.transactionBox.query(
      Transaction_.date.between(
          firstDate.millisecondsSinceEpoch, secondDate.millisecondsSinceEpoch),
    );
    final revenueQuery =
        revenueQueryBuilder.build().property(Transaction_.totalAmount).sum();

    setState(() {
      _revenueThisQuarter = revenueQuery;
    });
  }

  void initializeThisYearData() {
    final revenueQueryBuilder = objectBox.transactionBox.query(
      Transaction_.date.between(DateTime(now.year, 1, 1).millisecondsSinceEpoch,
          DateTime(now.year, 12, 31).millisecondsSinceEpoch),
    );
    final revenueQuery =
        revenueQueryBuilder.build().property(Transaction_.totalAmount).sum();
    setState(() {
      _revenueThisYear = revenueQuery;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
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
                    Text(
                      NumberFormat.currency(symbol: '₱')
                          .format(_revenueThisMonth),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 44,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
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
                    Text(
                      NumberFormat.currency(symbol: '₱')
                          .format(_revenueThisQuarter),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 44,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
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
                  Text(
                    NumberFormat.currency(symbol: '₱').format(_revenueThisYear),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 44,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
