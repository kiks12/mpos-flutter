
import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/models/discounts.dart';
import 'package:mpos/models/expiration_dates.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/store_details.dart';
import 'package:mpos/models/transaction.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalRestoreDataScreen extends StatefulWidget {
  const LocalRestoreDataScreen({Key? key}) : super(key: key);

  @override
  State<LocalRestoreDataScreen> createState() => _LocalRestoreDataScreenState();
}

class _LocalRestoreDataScreenState extends State<LocalRestoreDataScreen> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  String message = "Start Restoring Data";
  bool doneRestoring = false;

  @override
  void initState() {
    super.initState();
  }

  Future<List<dynamic>> readFileString(File file) async {
    final jsonString = await file.readAsString();
    return jsonDecode(jsonString);
  }

  Future<void> importProductData() async {
    final path = await _getFile("products.json");

    if (path == null) {
      Fluttertoast.showToast(msg: "No File Selected");
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      objectBox.productBox.removeAll();
      final List<dynamic> jsonList = await readFileString(file);
      final List<dynamic> entities = jsonList.map((e) => Product.fromJsonSerial(e)).toList();
      final List<Product> products = entities.map((e) {
        final product = e as Product;
        product.id = 0;
        return product;
      }).toList();
      objectBox.productBox.putMany(products);
      Fluttertoast.showToast(msg: "Uploaded product data into database");
      return;
    }

    Fluttertoast.showToast(msg: "File does not exist");
  }

  Future<void> importPackageData() async {
    final path = await _getFile("packages.json");

    if (path == null) {
      Fluttertoast.showToast(msg: "No File Selected");
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      objectBox.packagedProductBox.removeAll();
      final List<dynamic> jsonList = await readFileString(file);
      final List<dynamic> entities = jsonList.map((e) => PackagedProduct.fromJsonSerial(e)).toList();
      final List<PackagedProduct> packages = entities.map((e) {
        final package = e as PackagedProduct;
        package.id = 0;
        return package;
      }).toList();
      objectBox.packagedProductBox.putMany(packages);
      Fluttertoast.showToast(msg: "Uploaded package data into database");
      return;
    }

    Fluttertoast.showToast(msg: "File does not exist");
  }

  Future<void> importExpirationDateData() async {
    final path = await _getFile("expiration-dates.json");

    if (path == null) {
      Fluttertoast.showToast(msg: "No File Selected");
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      objectBox.expirationDateBox.removeAll();

      String csv = await file.readAsString();
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csv);
      final List<ExpirationDate> expirationDates = [];

      for (var i=1; i<csvData.length; i++) {
        final row = csvData[i];
        final expirationDateJson = {
          'id': row[0],
          'date': row[1],
          'quantity': row[2],
          'sold': row[3],
          'expired': row[4],
        };
        final expirationDate = ExpirationDate.fromJson(expirationDateJson);
        final product = objectBox.productBox.get(row[5]);
        expirationDate.productExp.target = product;
        expirationDate.id = 0;
        product?.expirationDates.add(expirationDate);
        expirationDates.add(expirationDate);
      }
      objectBox.expirationDateBox.putMany(expirationDates);
      Fluttertoast.showToast(msg: "Uploaded expiration date data into database");
      return;
    }

    Fluttertoast.showToast(msg: "File does not exist");
  }

  Future<void> importStoreDetailsData() async {
    final path = await _getFile("store-details.json");

    if (path == null) {
      Fluttertoast.showToast(msg: "No File Selected");
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      objectBox.storeDetailsBox.removeAll();
      final List<dynamic> jsonList = await readFileString(file);
      final List<dynamic> entities = jsonList.map((e) => StoreDetails.fromJson(e)).toList();
      final List<StoreDetails> storeDetails = entities.map((e) {
        final storeDetail = e as StoreDetails;
        storeDetail.id = 0;
        return storeDetail;
      }).toList();
      objectBox.storeDetailsBox.putMany(storeDetails);
      Fluttertoast.showToast(msg: "Uploaded store details data into database");
      return;
    }

    Fluttertoast.showToast(msg: "File does not exist");
  }

  Future<void> importDiscountsData() async {
    final path = await _getFile("discounts.json");

    if (path == null) {
      Fluttertoast.showToast(msg: "No File Selected");
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      objectBox.discountBox.removeAll();
      final List<dynamic> jsonList = await readFileString(file);
      final List<dynamic> entities = jsonList.map((e) => Discount.fromJson(e)).toList();
      final List<Discount> discounts = entities.map((e) {
        final discount = e as Discount;
        discount.id = 0;
        return discount;
      }).toList();
      objectBox.discountBox.putMany(discounts);
      Fluttertoast.showToast(msg: "Uploaded discount data into database");
      return;
    }

    Fluttertoast.showToast(msg: "File does not exist");
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
  Future<void> importTransactionData() async {
    final path = await _getFile("transactions.json");

    if (path == null) {
      Fluttertoast.showToast(msg: "No File Selected");
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      objectBox.transactionBox.removeAll();

      String csv = await file.readAsString();
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csv);
      final List<Transaction> transactions = [];

      for (var i=1; i<csvData.length; i++) {
        final row = csvData[i];
        final transactionJson = {
          'id': row[0],
          'transactionID': row[1],
          'packagesJson': row[2],
          'productsJson': row[3],
          'paymentMethod': row[4],
          'referenceNumber': row[5],
          'subTotal': row[6],
          'discount': row[7],
          'totalAmount': row[8],
          'payment': row[9],
          'change': row[10],
          'date': row[11],
          'time': row[12]
        };
        final transaction = Transaction.fromJson(transactionJson);
        if (row[13] != 0) {
          final user = objectBox.accountBox.get(row[13]);
          transaction.user.target = user;
          user?.transactions.add(transaction);
        }
        transaction.id = 0;
        transactions.add(transaction);
      }
      objectBox.transactionBox.putMany(transactions);
      Fluttertoast.showToast(msg: "Uploaded transaction data into database");
      return;
    }

    Fluttertoast.showToast(msg: "File does not exist");
  }

  Future<void> importAccountData() async {
    final path = await _getFile("accounts.json");

    if (path == null) {
      Fluttertoast.showToast(msg: "No File Selected");
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      objectBox.accountBox.removeAll();
      final List<dynamic> jsonList = await readFileString(file);
      final List<dynamic> entities = jsonList.map((e) =>
          Account.fromJson(e))
          .toList();
      final List<Account> accounts = entities.map((e) {
        final account = e as Account;
        account.id = 0;
        return account;
      }).toList();
      objectBox.accountBox.putMany(accounts);
      Fluttertoast.showToast(msg: "Uploaded account data into database");
      return;
    }

    Fluttertoast.showToast(msg: "File does not exist");
  }

  Future<void> importAttendanceData() async {
    final path = await _getFile("attendance.json");

    if (path == null) {
      Fluttertoast.showToast(msg: "No File Selected");
      return;
    }

    final file = File(path);
    if (await file.exists()) {
      objectBox.attendanceBox.removeAll();

      String csv = await file.readAsString();
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(csv);
      final List<Attendance> attendances = [];

      for (var i=1; i<csvData.length; i++) {
        final row = csvData[i];
        final attendanceJson = {
          'id': row[0],
          'date': row[1],
          'timeIn': row[2],
          'timeOut': row[3],
        };
        final attendance = Attendance.fromJson(attendanceJson);
        if (row[4] != 0) {
          final user = objectBox.accountBox.get(row[4]);
          attendance.user.target = user;
          user?.attendance.add(attendance);
        }
        attendance.id = 0;
        attendances.add(attendance);
      }
      objectBox.attendanceBox.putMany(attendances);
      Fluttertoast.showToast(msg: "Uploaded attendance data into database");
      return;
    }

    Fluttertoast.showToast(msg: "File does not exist");
  }

  Future<String?> _getFile(String filename) async {
    Directory? directory = await getExternalStorageDirectory();
    String filePath = path.join(directory!.path, filename);
    return filePath;
  }

  void restoreData() async {
    // STORE-DETAILS
    // ACCOUNTS
    // ATTENDANCE
    // DISCOUNTS
    // PRODUCTS
    // PACKAGES
    // EXPIRATION DATE
    // TRANSACTIONS
    isLoading = true;
    message = "Setting up database...";
    setState(() {});
    message = "Importing store details data...";
    setState(() {});
    await importStoreDetailsData();
    message = "Importing account data...";
    setState(() {});
    await importAccountData();
    message = "Importing attendance data...";
    setState(() {});
    await importAttendanceData();
    message = "Importing discount data...";
    setState(() {});
    await importDiscountsData();
    message = "Importing product data...";
    setState(() {});
    await importProductData();
    message = "Importing package data...";
    setState(() {});
    await importPackageData();
    message = "Importing expiration date data...";
    setState(() {});
    await importExpirationDateData();
    message = "Importing transaction data...";
    setState(() {});
    await importTransactionData();
    isLoading = false;
    message = "Successfully restored data";
    doneRestoring = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore Data'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) const CircularProgressIndicator(),
              Text(message),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FilledButton(onPressed: restoreData, child: const Text("Restore Data")),
              ),
              if (doneRestoring) FilledButton.tonal(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyApp()));
              }, child: const Text("Restart System"))
            ],
          ),
        ),
      ),
    );
  }
}
