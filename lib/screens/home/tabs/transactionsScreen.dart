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

  @override
  void initState() {
    super.initState();
    initializeAttendanceStream();
  }

  @override
  void dispose() {
    _listController.close();
    super.dispose();
  }

  void initializeAttendanceStream() {
    final attendanceQueryBuilder = objectBox.transactionBox.query()
      ..order(Transaction_.transactionID, flags: Order.descending);
    attendanceStream = attendanceQueryBuilder.watch(triggerImmediately: true);

    _listController.addStream(attendanceStream.map((query) => query.find()));
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
    // final attendanceQueryBuilder = objectBox.attendanceBox.query(
    //   Attendance_.date.equals(DateTime.parse(
    //     DateFormat('yyyy-MM-dd').format(_selectedDate as DateTime),
    //   ).millisecondsSinceEpoch),
    // )..order(
    //     Attendance_.date,
    //     flags: Order.descending,
    //   );
    // final attendanceQuery =
    //     attendanceQueryBuilder.watch(triggerImmediately: true);

    // setState(() {
    //   _listController = StreamController(sync: true);
    //   _listController.addStream(attendanceQuery.map((query) => query.find()));
    // });
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

  void _dropdownOnChange(String newValue) {
    setState(() {
      _dropDownValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TransactionScreenHeader(
              searchController: searchController,
              onPressed: search,
              selectDate: _selectDate,
              date: _selectedDate,
              refresh: refresh,
              deleteAll: showDeleteAllConfirmationDialog,
              dropdownValue: _dropDownValue,
              dropdownOnChange: _dropdownOnChange,
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
  }) : super(key: key);

  final TextEditingController searchController;
  final void Function() onPressed;
  final void Function() refresh;
  final void Function() deleteAll;
  final dynamic Function(BuildContext context) selectDate;
  final DateTime? date;
  final String dropdownValue;
  final void Function(String str) dropdownOnChange;

  @override
  State<TransactionScreenHeader> createState() =>
      _TransactionScreenHeaderState();
}

class _TransactionScreenHeaderState extends State<TransactionScreenHeader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const HeaderOne(padding: EdgeInsets.all(0), text: 'Transactions'),
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
                  // DropdownButton<String>(
                  //   value: widget.dropdownValue,
                  //   elevation: 16,
                  //   style: const TextStyle(color: Colors.deepPurple),
                  //   onChanged: (String? newValue) {
                  //     widget.dropdownOnChange(newValue as String);
                  //   },
                  //   items: <String>['One', 'Two', 'Free', 'Four']
                  //       .map<DropdownMenuItem<String>>((String value) {
                  //     return DropdownMenuItem<String>(
                  //       value: value,
                  //       child: Text(value),
                  //     );
                  //   }).toList(),
                  // ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.blueGrey,
                    ),
                    onPressed: () => widget.selectDate(context),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      child: Text('Select Date'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      widget.date != null
                          ? "Selected Date: ${DateFormat('yyyy-MM-dd').format(widget.date as DateTime)}"
                          : 'Selected Date: No Date Selected',
                    ),
                  ),
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
                  '${widget.transaction.user.target!.lastName}, ${widget.transaction.user.target!.firstName}',
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
