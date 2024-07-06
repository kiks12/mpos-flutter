import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/main.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' as p;

class LocalBackupDataScreen extends StatefulWidget {
  const LocalBackupDataScreen({Key? key}) : super(key: key);

  @override
  State<LocalBackupDataScreen> createState() => _LocalBackupDataScreenState();
}

class _LocalBackupDataScreenState extends State<LocalBackupDataScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  // static final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
  }

  Future<void> backupData() async {
    _isLoading = true;
    setState(() {});
    final csv = await _generateCSVs();
    for (var element in csv.values) {
      Fluttertoast.showToast(msg: element.path);
    }
    _isLoading = false;
    setState(() {});
  }

  Future<Map<String, File>> _generateCSVs() async {
    final File storeDetailsCSVFile = await generateCSVofStoreDetails();
    final File accountsCSVFile = await generateCSVofAccounts();
    final File attendanceCSVFile = await generateCSVofAttendance();
    final File productsCSVFile = await generateCSVofProducts();
    final File packagesCSVFile = await generateCSVofPackages();
    final File expirationDatesCSVFile = await generateCSVofExpirationDate();
    final File transactionsCSVFile = await generateCSVofTransactions();
    final File discountsCSVFile = await generateCSVofDiscounts();

    return Future.value({
      'STORE_DETAILS': storeDetailsCSVFile,
      'ACCOUNTS': accountsCSVFile,
      'ATTENDANCE': attendanceCSVFile,
      'PRODUCTS': productsCSVFile,
      'PACKAGES': packagesCSVFile,
      'EXPIRATION_DATES': expirationDatesCSVFile,
      'TRANSACTIONS': transactionsCSVFile,
      'DISCOUNTS': discountsCSVFile
    });
  }

  Future<File> generateCSVofProducts() async {
    final products = objectBox.productBox.getAll();
    final List<Map<String, dynamic>> jsonList = products.map((e) => e.toJsonSerial()).toList();
    final jsonString = jsonEncode(jsonList);
    final directory = await getExternalStorageDirectory();
    final filePath = p.join(directory!.path, 'products.json');
    final file = File(filePath);
    await file.writeAsString(jsonString);
    return Future.value(file);
  }

  Future<File> generateCSVofPackages() async {
    final packages = objectBox.packagedProductBox.getAll();
    final List<Map<String, dynamic>> jsonList = packages.map((e) => e.toJsonSerial()).toList();
    final jsonString = jsonEncode(jsonList);
    final directory = await getExternalStorageDirectory();
    final filePath = p.join(directory!.path, 'packages.json');
    final file = File(filePath);
    await file.writeAsString(jsonString);
    return Future.value(file);
  }

  Future<File> generateCSVofDiscounts() async {
    final discounts = objectBox.discountBox.getAll();
    final List<Map<String, dynamic>> jsonList = discounts.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    final directory = await getExternalStorageDirectory();
    final filePath = p.join(directory!.path, 'discounts.json');
    final file = File(filePath);
    await file.writeAsString(jsonString);
    return Future.value(file);
  }

  Future<File> generateCSVofStoreDetails() async {
    final storeDetails = objectBox.storeDetailsBox.getAll();
    final List<Map<String, dynamic>> jsonList = storeDetails.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    final directory = await getExternalStorageDirectory();
    final filePath = p.join(directory!.path, 'store-details.json');
    final file = File(filePath);
    await file.writeAsString(jsonString);
    return Future.value(file);
  }

  Future<File> generateCSVofAccounts() async {
    final accounts = objectBox.accountBox.getAll();
    final List<Map<String, dynamic>> jsonList = accounts.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    final directory = await getExternalStorageDirectory();
    final filePath = p.join(directory!.path, 'accounts.json');
    final file = File(filePath);
    await file.writeAsString(jsonString);
    return Future.value(file);
  }

  Future<File> generateCSVofAttendance() async {
    final List<List<String>> csvData = [
      ["id", "date", "timeIn", "timeOut", "userId"]
    ];
    final attendances = objectBox.attendanceBox.getAll();
    for (var attendance in attendances) {
      final List<String> transactionData = [
        attendance.id.toString(),
        attendance.date.toString(),
        attendance.timeIn.toString(),
        attendance.timeOut.toString(),
        attendance.user.target != null ? attendance.user.target!.id.toString() : "0"
      ];
      csvData.add(transactionData);
    }
    final csv = const ListToCsvConverter().convert(csvData);
    final directory = await getExternalStorageDirectory();
    final filePath = p.join(directory!.path, 'attendance.json');
    final file = File(filePath);
    await file.writeAsString(csv);
    return Future.value(file);
  }

  Future<File> generateCSVofExpirationDate() async {
    final List<List<String>> csvData = [
      ["id", "date", "quantity", "sold", "expired", "productId"]
    ];
    final expirationDates = objectBox.expirationDateBox.getAll();
    for (var expirationDate in expirationDates) {
      final List<String> expirationDateData = [
        expirationDate.id.toString(),
        expirationDate.date.toString(),
        expirationDate.quantity.toString(),
        expirationDate.sold.toString(),
        expirationDate.expired.toString(),
        expirationDate.productExp.target!.id.toString(),
      ];
      csvData.add(expirationDateData);
    }
    final csv = const ListToCsvConverter().convert(csvData);
    final directory = await getExternalStorageDirectory();
    final filePath = p.join(directory!.path, 'expiration-dates.json');
    final file = File(filePath);
    await file.writeAsString(csv);
    return Future.value(file);
  }

  // [
  // {id: 15,
  // transactionID: 1,
  // packagesJson: [],
  // productsJson: [
  //    {"id":63,"name":"Choco Pops (6pcs)","image":"","category":"Others","unitPrice":150,"quantity":1,"totalPrice":150}
  // ],
  // paymentMethod: Cash,
  // referenceNumber: ,
  // subTotal: 150,
  // discount: 0,
  // totalAmount: 150,
  // payment: 150,
  // change: 0,
  // date: 2024-06-24T00:00:00.000,
  // time: 2024-06-24T17:30:13.773
  // }]
  Future<File> generateCSVofTransactions() async {
    final List<List<String>> csvData = [
      ["id", "transactionID", "packagesJson", "productsJson", "paymentMethod", "referenceNumber", "subTotal", "discount", "totalAmount", "payment", "change", "date", "time", "userId"]
    ];
    final transactions = objectBox.transactionBox.getAll();
    for (var transaction in transactions) {
      final List<String> transactionData = [
        transaction.id.toString(),
        transaction.transactionID.toString(),
        transaction.packagesJson,
        transaction.productsJson,
        transaction.paymentMethod,
        transaction.referenceNumber,
        transaction.subTotal.toString(),
        transaction.discount.toString(),
        transaction.totalAmount.toString(),
        transaction.payment.toString(),
        transaction.change.toString(),
        transaction.date.toString(),
        transaction.time.toString(),
        transaction.user.target != null ? transaction.user.target!.id.toString() : "0"
      ];
      csvData.add(transactionData);
    }
    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getExternalStorageDirectory();
    final filePath = p.join(directory!.path, 'transactions.json');
    final file = File(filePath);
    await file.writeAsString(csv);
    return Future.value(file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup Data"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading ? const Column(
                  children: [
                    Text("Creating Database backup..."),
                  ],
                ): Container(),
                FilledButton(onPressed: backupData, child: const Text("Backup Data")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
