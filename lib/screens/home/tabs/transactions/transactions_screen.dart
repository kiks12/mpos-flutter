import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/home/tabs/transactions/components/transactions_header.dart';
import 'package:mpos/screens/home/tabs/transactions/components/transactions_list_header.dart';
import 'package:mpos/screens/home/tabs/transactions/components/transactions_list_item.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Stream<Query<Transaction>> attendanceStream;
  List<Transaction> _transactionList = [];
  List<Transaction> _backupTransactionList = [];

  final TextEditingController searchController = TextEditingController();
  DateTime? _selectedDate;
  String _dropDownValue = 'Today';
  String _whichQuarter = 'First Quarter';
  String _whichHalf = 'First Half';
  String _whichYear = DateFormat('yyyy').format(DateTime.now());
  String _paymentMethodValue = 'All';
  int _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    initializeTransactionStream();
    calculateTotalRevenue();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeTransactionStream() {
    _dropdownOnChange('Today');
  }

  TransactionListTile transactionListItemBuilder(int index, Transaction transaction) {
    return TransactionListTile(transaction: transaction, index: index);
  }

  void refresh() {
    initializeTransactionStream();
    _selectedDate = null;
    _dropDownValue = 'Today';
    setState(() {});
  }

  void search() {
    String strToSearch = searchController.text;
    final transactionQueryBuilder = objectBox.transactionBox.query(
      Transaction_.referenceNumber.contains(strToSearch, caseSensitive: false)
        .or(Transaction_.productsJson.contains(strToSearch, caseSensitive: false))
        .or(Transaction_.packagesJson.contains(strToSearch, caseSensitive: false))
    );
    final transactionQuery = transactionQueryBuilder.watch(triggerImmediately: true);
    setTransactionListData(transactionQuery);
  }

  void calculateTotalRevenue() {
    _totalRevenue = _transactionList.fold(0, (previousValue, element) => previousValue + element.totalAmount);
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
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
    setTransactionListData(transactionQuery);
  }

  void addQuantityToProduct(Product product) {
    final productToUpdate = objectBox.productBox.get(product.id);
    if (productToUpdate == null) {
      Fluttertoast.showToast(msg: "Product not found");
      return;
    }
    productToUpdate.quantity = productToUpdate.quantity + product.quantity;
    objectBox.productBox.put(productToUpdate);
  }

  void deleteAll() {
    final transactions = objectBox.transactionBox.getAll();
    for (var transaction in transactions) {
      for (var package in transaction.packages) {
        for (var product in package.productsList) {
          addQuantityToProduct(product);
        }
      }
      for (var product in transaction.products) {
        addQuantityToProduct(product);
      }
    }
    objectBox.transactionBox.removeAll();
    Fluttertoast.showToast(msg: "Successfully deleted all transactions");
  }

  Future<void> showDeleteAllConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Records'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
            FilledButton(
              onPressed: deleteAll,
              child: const Text('Confirm'),
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
    setTransactionListData(transactionQuery);
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
    setTransactionListData(transactionQuery);
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
    setTransactionListData(transactionQuery);
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
        setTransactionListData(transactionQuery);
        break;

      case 'Second Quarter':
        final firstDate = DateTime(now.year, 4, 1);
        final secondDate = DateTime(now.year, 6, 30);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setTransactionListData(transactionQuery);
        break;

      case 'Third Quarter':
        final firstDate = DateTime(now.year, 7, 1);
        final secondDate = DateTime(now.year, 9, 30);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setTransactionListData(transactionQuery);
        break;

      case 'Fourth Quarter':
        final firstDate = DateTime(now.year, 10, 1);
        final secondDate = DateTime(now.year, 12, 31);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setTransactionListData(transactionQuery);
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
        setTransactionListData(transactionQuery);
        break;

      case 'Second Half':
        final firstDate = DateTime(now.year, 7, 1);
        final secondDate = DateTime(now.year, 12, 31);
        final transactionQueryBuilder = objectBox.transactionBox.query(
            Transaction_.date.between(firstDate.millisecondsSinceEpoch,
                secondDate.millisecondsSinceEpoch));
        final transactionQuery =
            transactionQueryBuilder.watch(triggerImmediately: true);
        setTransactionListData(transactionQuery);
        break;
    }
  }

  void _onYearChange(String newValue) {
    _whichYear = newValue;
    setState(() {});
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
    setTransactionListData(transactionQuery);
  }

  void setTransactionListData(Stream<Query<Transaction>> transactionQuery) {
    transactionQuery.listen((event) {
      _transactionList = event.find();
      _backupTransactionList = _transactionList;
      calculateTotalRevenue();
      setState(() {});
    });
  }

  void _fetchAllTransactions() {
    final transactionQueryBuilder = objectBox.transactionBox.query();
    final transactionQuery =
        transactionQueryBuilder.watch(triggerImmediately: true);

    setTransactionListData(transactionQuery);
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

  void onPaymentMethodValueChange(String str) {
    _paymentMethodValue = str;
    if (str != "All") {
      _transactionList = _backupTransactionList.where((element) => element.paymentMethod == str).toList();
      calculateTotalRevenue();
      setState(() {});
      return;
    }
    _transactionList = _backupTransactionList;
    calculateTotalRevenue();
    setState(() {});
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
              paymentMethodValue: _paymentMethodValue,
              onPaymentMethodValueChange: onPaymentMethodValueChange,
            ),
            const TransactionsListHeader(),
            Expanded(
              child:
                ListView.builder(
                  itemBuilder: (context, index) => transactionListItemBuilder(index, _transactionList[index]),
                  shrinkWrap: true,
                  itemCount: _transactionList.length,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                ),
            ),
          ],
        ),
      ),
    );
  }
}

