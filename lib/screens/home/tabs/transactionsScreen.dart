import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/objectbox.g.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Stream<Query<Transaction>> attendanceStream;

  StreamController<List<Transaction>> _listController =
      StreamController<List<Transaction>>(sync: true);

  final TextEditingController searchController = TextEditingController();
  DateTime? _selectedDate;
  String _dropDownValue = 'Today';
  String _whichQuarter = 'First Quarter';
  String _whichHalf = 'First Half';
  String _whichYear = DateFormat('yyyy').format(DateTime.now());
  final int _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    initializeAttendanceStream();
    // _calculateTotalRevenue();
  }

  @override
  void dispose() {
    _listController.close();
    super.dispose();
  }

  void initializeAttendanceStream() {
    _dropdownOnChange('Today');
  }

  TransactionListTile Function(BuildContext, int) _itemBuilder(
      List<Transaction> transactions) {
    return (BuildContext context, int index) {
      return TransactionListTile(
        index: index,
        transaction: transactions[index],
      );
    };
  }

  void refresh() {
    setState(() {
      _listController = StreamController(sync: true);
      initializeAttendanceStream();
      _selectedDate = null;
      _dropDownValue = 'Today';
    });
  }

  void search() {
    String strToSearch = searchController.text;
    final transactionQueryBuilder = objectBox.transactionBox.query()
      ..link(
          Transaction_.product,
          Product_.barcode.contains(strToSearch) |
              Product_.name.contains(strToSearch));
    final attendanceQuery =
        transactionQueryBuilder.watch(triggerImmediately: true);

    setState(() {
      _listController = StreamController(sync: true);
      _listController.addStream(attendanceQuery.map((query) => query.find()));
      searchController.text = '';
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != _selectedDate) {
      setState(() {
        _selectedDate = selected;
      });
    }

    _filter();
  }

  void _filter() {
    final transactionQueryBuilder = objectBox.transactionBox.query(
      Transaction_.date.equals(DateTime.parse(
        DateFormat('yyyy-MM-dd').format(_selectedDate as DateTime),
      ).millisecondsSinceEpoch),
    )..order(
        Transaction_.date,
        flags: Order.descending,
      );
    final transactionQuery =
        transactionQueryBuilder.watch(triggerImmediately: true);

    setState(() {
      _listController = StreamController(sync: true);
      _listController.addStream(transactionQuery.map((query) => query.find()));
    });
  }

  void deleteAll() {
    objectBox.transactionBox.removeAll();
    Navigator.of(context).pop();
  }

  Future<void> showDeleteAllConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Records'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text('Are you sure you want to delete all Transaction Records?')
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Confirm'),
              onPressed: deleteAll,
            ),
          ],
        );
      },
    );
  }

  void _filterForToday() {
    final transactionQueryBuilder = objectBox.transactionBox.query(Transaction_
        .date
        .equals(DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()))
            .millisecondsSinceEpoch));
    final transactionQuery =
        transactionQueryBuilder.watch(triggerImmediately: true);
    setListControllerData(transactionQuery);
  }

  void _filterForLast7Days() {
    final dateToday = DateTime.now();
    final dateSevenDaysAgo =
        DateTime(dateToday.year, dateToday.month, dateToday.day - 7);
    final transactionQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(dateToday.millisecondsSinceEpoch,
            dateSevenDaysAgo.millisecondsSinceEpoch));
    final transactionQuery =
        transactionQueryBuilder.watch(triggerImmediately: true);
    setListControllerData(transactionQuery);
  }

  void _filterForLast30Days() {
    final dateToday = DateTime.now();
    final dateSevenDaysAgo =
        DateTime(dateToday.year, dateToday.month - 1, dateToday.day);
    final transactionQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(dateToday.millisecondsSinceEpoch,
            dateSevenDaysAgo.millisecondsSinceEpoch));
    final transactionQuery =
        transactionQueryBuilder.watch(triggerImmediately: true);
    setListControllerData(transactionQuery);
  }

  void _onQuarterChange(String newValue) {
    setState(() {
      _whichQuarter = newValue;
    });
    _filterForQuarterly();
  }

  void _filterForQuarterly() {
    final now = DateTime.now();
    switch (_whichQuarter) {
      case 'First Quarter':
        final firstDate = DateTime(now.year, 1, 1);
        final secondDate = DateTime(now.year, 3, 31);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setListControllerData(transactionQuery);
        break;

      case 'Second Quarter':
        final firstDate = DateTime(now.year, 4, 1);
        final secondDate = DateTime(now.year, 6, 30);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setListControllerData(transactionQuery);
        break;

      case 'Third Quarter':
        final firstDate = DateTime(now.year, 7, 1);
        final secondDate = DateTime(now.year, 9, 30);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setListControllerData(transactionQuery);
        break;

      case 'Fourth Quarter':
        final firstDate = DateTime(now.year, 10, 1);
        final secondDate = DateTime(now.year, 12, 31);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setListControllerData(transactionQuery);
        break;
    }
  }

  void _onHalfChange(String newValue) {
    setState(() {
      _whichHalf = newValue;
    });
    _filterForSemiAnnually();
  }

  void _filterForSemiAnnually() {
    final now = DateTime.now();
    switch (_whichHalf) {
      case 'First Half':
        final firstDate = DateTime(now.year, 1, 1);
        final secondDate = DateTime(now.year, 6, 30);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setListControllerData(transactionQuery);
        break;

      case 'Second Half':
        final firstDate = DateTime(now.year, 7, 1);
        final secondDate = DateTime(now.year, 12, 31);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setListControllerData(transactionQuery);
        break;
    }
  }

  void _onYearChange(String newValue) {
    setState(() {
      _whichYear = newValue;
    });
    _filterForAnnually(int.parse(_whichYear));
  }

  void _filterForAnnually(int year) {
    final firstDate = DateTime(year, 1, 1);
    final secondDate = DateTime(year, 12, 31);
    final transactionQueryBuilder = objectBox.transactionBox.query(
        Transaction_.date.between(firstDate.millisecondsSinceEpoch,
            secondDate.millisecondsSinceEpoch));
    final transactionQuery =
        transactionQueryBuilder.watch(triggerImmediately: true);
    setListControllerData(transactionQuery);
  }

  void setListControllerData(Stream<Query<Transaction>> transactionQuery) {
    setState(() {
      _listController = StreamController();
      _listController.addStream(transactionQuery.map((query) => query.find()));
    });
  }

  void _fetchAllTransactions() {
    final transactionQueryBuilder = objectBox.transactionBox.query();
    final transactionQuery =
        transactionQueryBuilder.watch(triggerImmediately: true);

    setListControllerData(transactionQuery);
  }

  void _dropdownOnChange(String newValue) {
    setState(() {
      _dropDownValue = newValue;
    });

    switch (newValue) {
      case 'Today':
        _filterForToday();
        break;

      case 'Last 7 Days':
        _filterForLast7Days();
        break;

      case 'Last 30 Days':
        _filterForLast30Days();
        break;

      case 'Quarterly':
        _filterForQuarterly();
        break;

      case 'Semi Annually':
        _filterForSemiAnnually();
        break;

      case 'Annually':
        _filterForAnnually(int.parse(_whichYear));
        break;

      default:
        _fetchAllTransactions();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TransactionScreenHeader(
              totalRevenue: _totalRevenue,
              whichQuarter: _whichQuarter,
              whichHalf: _whichHalf,
              whichYear: _whichYear,
              searchController: searchController,
              onPressed: search,
              selectDate: _selectDate,
              date: _selectedDate,
              refresh: refresh,
              deleteAll: showDeleteAllConfirmationDialog,
              dropdownValue: _dropDownValue,
              dropdownOnChange: _dropdownOnChange,
              onQuarterChange: _onQuarterChange,
              onHalfChange: _onHalfChange,
              onYearChange: _onYearChange,
            ),
            const ListHeader(),
            Expanded(
              child: StreamBuilder<List<Transaction>>(
                stream: _listController.stream,
                builder: ((context, snapshot) => ListView.builder(
                      itemBuilder: _itemBuilder(snapshot.data ?? []),
                      shrinkWrap: true,
                      itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionScreenHeader extends StatefulWidget {
  const TransactionScreenHeader({
    Key? key,
    required this.searchController,
    required this.onPressed,
    required this.selectDate,
    required this.date,
    required this.refresh,
    required this.deleteAll,
    required this.dropdownValue,
    required this.dropdownOnChange,
    required this.whichQuarter,
    required this.whichHalf,
    required this.whichYear,
    required this.onQuarterChange,
    required this.onHalfChange,
    required this.onYearChange,
    required this.totalRevenue,
  }) : super(key: key);

  final int totalRevenue;
  final TextEditingController searchController;
  final void Function() onPressed;
  final void Function() refresh;
  final void Function() deleteAll;
  final dynamic Function(BuildContext context) selectDate;
  final DateTime? date;
  final String dropdownValue;
  final void Function(String str) dropdownOnChange;
  final void Function(String str) onQuarterChange;
  final void Function(String str) onHalfChange;
  final void Function(String str) onYearChange;
  final String whichQuarter;
  final String whichHalf;
  final String whichYear;

  @override
  State<TransactionScreenHeader> createState() =>
      _TransactionScreenHeaderState();
}

class _TransactionScreenHeaderState extends State<TransactionScreenHeader> {
  static const items = [
    'Today',
    'Last 7 Days',
    'Last 30 Days',
    'Quarterly',
    'Semi Annually',
    'Annually',
    'Specific Date',
    'All',
  ];

  static const quarters = [
    'First Quarter',
    'Second Quarter',
    'Third Quarter',
    'Fourth Quarter',
  ];

  static const halves = [
    'First Half',
    'Second Half',
  ];

  static const years = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const HeaderOne(
                  padding: EdgeInsets.all(0), text: 'Transactions  |  '),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: TextField(
                        controller: widget.searchController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: widget.onPressed,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      child: Text('Search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 1, 10, 1),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.blueGrey,
                      ),
                      onPressed: () {},
                      child: DropdownButton<String>(
                        value: widget.dropdownValue,
                        underline: Container(
                          width: 0,
                          color: Colors.transparent,
                        ),
                        style: const TextStyle(color: Colors.blueGrey),
                        onChanged: (String? newValue) {
                          widget.dropdownOnChange(newValue as String);
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
                  ),
                  widget.dropdownValue == 'Quarterly'
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 10, 1),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.blueGrey,
                            ),
                            onPressed: () {},
                            child: DropdownButton<String>(
                              value: widget.whichQuarter,
                              underline: Container(
                                width: 0,
                                color: Colors.transparent,
                              ),
                              style: const TextStyle(color: Colors.blueGrey),
                              onChanged: (String? newValue) {
                                widget.onQuarterChange(newValue as String);
                              },
                              items: quarters.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Container(),
                  widget.dropdownValue == 'Semi Annually'
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 10, 1),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.blueGrey,
                            ),
                            onPressed: () {},
                            child: DropdownButton<String>(
                              value: widget.whichHalf,
                              underline: Container(
                                width: 0,
                                color: Colors.transparent,
                              ),
                              style: const TextStyle(color: Colors.blueGrey),
                              onChanged: (String? newValue) {
                                widget.onHalfChange(newValue as String);
                              },
                              items: halves.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Container(),
                  widget.dropdownValue == 'Annually'
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(0, 1, 10, 1),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.blueGrey,
                            ),
                            onPressed: () {},
                            child: DropdownButton<String>(
                              value: widget.whichYear,
                              underline: Container(
                                width: 0,
                                color: Colors.transparent,
                              ),
                              style: const TextStyle(color: Colors.blueGrey),
                              onChanged: (String? newValue) {
                                widget.onYearChange(newValue as String);
                              },
                              items: years.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        )
                      : Container(),
                  widget.dropdownValue == 'Specific Date'
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            onPrimary: Colors.blueGrey,
                          ),
                          onPressed: () => widget.selectDate(context),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            child: Text('Select Date'),
                          ),
                        )
                      : Container(),
                  widget.dropdownValue == 'Specific Date'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            widget.date != null
                                ? "Selected Date: ${DateFormat('yyyy-MM-dd').format(widget.date as DateTime)}"
                                : 'Selected Date: No Date Selected',
                          ),
                        )
                      : Container(),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        onPrimary: Colors.blueGrey,
                      ),
                      onPressed: widget.refresh,
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                        child: Text('Refresh'),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                    onPressed: widget.deleteAll,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      child: Text('Delete All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TransactionListTile extends StatefulWidget {
  const TransactionListTile({
    Key? key,
    required this.index,
    required this.transaction,
  }) : super(key: key);

  final Transaction transaction;
  final int index;

  @override
  State<TransactionListTile> createState() => _TransactionListTileState();
}

class _TransactionListTileState extends State<TransactionListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.index % 2 == 0
            ? Colors.transparent
            : const Color.fromARGB(255, 239, 239, 239),
        border: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 232, 232, 232),
            width: 0.7,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(widget.transaction.transactionID.toString()),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(widget.transaction.product.target!.name),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  NumberFormat.currency(symbol: '₱')
                      .format(widget.transaction.product.target!.unitPrice),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(widget.transaction.quantity.toString()),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  NumberFormat.currency(symbol: '₱')
                      .format(widget.transaction.totalAmount),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  NumberFormat.currency(symbol: '₱')
                      .format(widget.transaction.totalAmount),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${widget.transaction.user.target!.lastName}, ${widget.transaction.user.target!.firstName}',
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  DateFormat('yyyy-MM-dd').format(widget.transaction.date),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child:
                    Text(DateFormat('HH:mm a').format(widget.transaction.time)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListHeader extends StatelessWidget {
  const ListHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
      // padding: const EdgeInsets.5
      child: Row(
        children: const <Widget>[
          Expanded(
            child: Center(
              child: Text(
                'ID',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Product',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Unit Price',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'QTY',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Total Price',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Cashier',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Date',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Time',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
