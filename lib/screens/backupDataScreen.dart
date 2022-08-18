import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/storeDetails.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/screens/home/homeScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

const serverUploadAPIEndpoint =
    'https://mpos-data-center.herokuapp.com/backup/upload/';
const loginAPIEndpoint =
    'https://mpos-data-center.herokuapp.com/login/callback/';

class BackupDataScreen extends StatefulWidget {
  const BackupDataScreen({Key? key}) : super(key: key);

  @override
  State<BackupDataScreen> createState() => _BackupDataScreenState();
}

class _BackupDataScreenState extends State<BackupDataScreen> {
  bool isLoading = false;
  bool loggedIn = false;
  String error = 'sadfs';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  static final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> login() async {
    try {
      isLoading = true;
      setState(() {});
      final http.Response response = await http.post(
        Uri.parse(loginAPIEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          <String, String>{
            'email': emailController.value.text,
            'password': passwordController.value.text,
          },
        ),
      );
      final jsonBody = jsonDecode(response.body);

      if (response.statusCode != 200) {
        error = jsonBody['msg'];
        loggedIn = false;
        isLoading = false;
        setState(() {});
        return;
      }

      GetStorage().write('uuid', jsonBody['uuid']);

      error = '';
      loggedIn = true;
      setState(() {});
      return;
    } catch (e) {
      print(e);
    }
  }

  Future<void> backupData() async {
    final csvs = await _generateCSVs();
    await uploadCSVFilesToServer(
      csvs['StoreDetails']!,
      csvs['Accounts']!,
      csvs['Attendance']!,
      csvs['Inventory']!,
      csvs['ExpirationDates']!,
      csvs['Transactions']!,
    );
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => const HomeScreen())));
  }

  Future<Map<String, File>> _generateCSVs() async {
    final File storeDetailsCSVFile = await generateCSVofStoreDetails();
    final File accountsCSVFile = await generateCSVofAccounts();
    final File attendanceCSVFile = await generateCSVofAttendance();
    final File inventoryCSVFile = await generateCSVofInventory();
    final File expirationDatesCSVFile = await generateCSVofExpirationDate();
    final File transactionsCSVFile = await generateCSVofTransactions();

    return Future.value({
      'StoreDetails': storeDetailsCSVFile,
      'Accounts': accountsCSVFile,
      'Attendance': attendanceCSVFile,
      'Inventory': inventoryCSVFile,
      'ExpirationDates': expirationDatesCSVFile,
      'Transactions': transactionsCSVFile,
    });
  }

  Future<void> uploadCSVFilesToServer(
    File storeDetails,
    File accounts,
    File attendance,
    File inventory,
    File expirationDates,
    File transactions,
  ) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(serverUploadAPIEndpoint));
      request.headers.addAll({
        'Authorization': 'Bearer ${GetStorage().read('uuid')}',
      });
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          await storeDetails.readAsBytes(),
          contentType: MediaType('application', 'CSV'),
        ),
      );

      final response = await request.send();

      if (response.statusCode != 200) {
        error = 'Error Backing Up database. Please try again later.';
        isLoading = false;
        setState(() {});
        return;
      }

      error = 'Redirecting...';
      isLoading = false;
      setState(() {});
      return Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print(e);
    }
  }

  Future<File> generateCSVofInventory() async {
    List<List<dynamic>> inventoryValues = [
      [
        'id',
        'name',
        'barcode',
        'category',
        'unitPrice',
        'quantity',
        'totalPrice',
      ],
    ];
    final inventory = objectBox.productBox.getAll();
    inventory.forEach((Product product) {
      inventoryValues.add([
        product.id,
        product.name,
        product.barcode,
        product.category,
        product.unitPrice,
        product.quantity,
        product.totalPrice,
      ]);
    });

    final csvData = const ListToCsvConverter().convert(inventoryValues);

    final directory = (await getApplicationSupportDirectory()).path;
    final path = '$directory/$now-inventory.csv';

    final File file = File(path);
    await file.writeAsString(csvData);
    return Future.value(file);
  }

  Future<File> generateCSVofStoreDetails() async {
    List<List<dynamic>> storeDetailsValues = [
      ['id', 'name', 'contactNumber', 'contactPerson'],
    ];
    final storeDetails = objectBox.storeDetailsBox.getAll();
    storeDetails.forEach((StoreDetails store) {
      storeDetailsValues.add([
        store.id,
        store.name,
        store.contactNumber,
        store.contactPerson,
      ]);
    });

    final csvData = const ListToCsvConverter().convert(storeDetailsValues);

    final directory = (await getApplicationSupportDirectory()).path;
    final path = '$directory/$now-store-details.csv';

    final File file = File(path);
    await file.writeAsString(csvData);
    return Future.value(file);
  }

  Future<File> generateCSVofAccounts() async {
    List<List<dynamic>> accountValues = [
      [
        'id',
        'firstName',
        'middleName',
        'lastName',
        'isAdmin',
        'emailAddress',
        'contactNumber',
        'password',
      ],
    ];
    final accounts = objectBox.accountBox.getAll();
    accounts.forEach((Account account) {
      accountValues.add([
        account.id,
        account.firstName,
        account.middleName,
        account.lastName,
        account.isAdmin,
        account.emailAddress,
        account.contactNumber,
        account.password,
      ]);
    });

    final csvData = const ListToCsvConverter().convert(accountValues);

    final directory = (await getApplicationSupportDirectory()).path;
    final path = '$directory/$now-accounts.csv';

    final File file = File(path);
    await file.writeAsString(csvData);
    return Future.value(file);
  }

  Future<File> generateCSVofAttendance() async {
    List<List<dynamic>> attendanceValues = [
      [
        'id',
        'user',
        'date',
        'timeIn',
        'timeOut',
      ],
    ];
    final attendances = objectBox.attendanceBox.getAll();
    attendances.forEach((Attendance attendance) {
      attendanceValues.add([
        attendance.id,
        attendance.user.target!.emailAddress,
        attendance.date,
        attendance.timeIn,
        attendance.timeOut,
      ]);
    });

    final csvData = const ListToCsvConverter().convert(attendanceValues);

    final directory = (await getApplicationSupportDirectory()).path;
    final path = '$directory/$now-attendance.csv';

    final File file = File(path);
    await file.writeAsString(csvData);
    return Future.value(file);
  }

  Future<File> generateCSVofExpirationDate() async {
    List<List<dynamic>> expirationDateValues = [
      [
        'id',
        'product',
        'date',
        'quantity',
        'sold',
        'expired',
      ],
    ];
    final expirationsDates = objectBox.expirationDateBox.getAll();
    expirationsDates.forEach((ExpirationDate expirationDate) {
      expirationDateValues.add([
        expirationDate.id,
        expirationDate.productExp.target!.barcode,
        expirationDate.date,
        expirationDate.quantity,
        expirationDate.sold,
        expirationDate.expired,
      ]);
    });

    final csvData = const ListToCsvConverter().convert(expirationDateValues);

    final directory = (await getApplicationSupportDirectory()).path;
    final path = '$directory/$now-expirationDates.csv';

    final File file = File(path);
    await file.writeAsString(csvData);
    return Future.value(file);
  }

  Future<File> generateCSVofTransactions() async {
    List<List<dynamic>> transactionsValues = [
      [
        'id',
        'transactionID',
        'product',
        'user',
        'quantity',
        'paymentMethod',
        'totalAmount',
        'date',
        'time',
      ],
    ];
    final transactions = objectBox.transactionBox.getAll();
    transactions.forEach((Transaction transaction) {
      transactionsValues.add([
        transaction.id,
        transaction.transactionID,
        transaction.product.target!.barcode,
        transaction.user.target!.emailAddress,
        transaction.quantity,
        transaction.paymentMethod,
        transaction.totalAmount,
        transaction.date,
        transaction.time,
      ]);
    });

    final csvData = const ListToCsvConverter().convert(transactionsValues);

    final directory = (await getApplicationSupportDirectory()).path;
    final path = '$directory/$now-transactions.csv';

    final File file = File(path);
    await file.writeAsString(csvData);
    return Future.value(file);
  }

  void loginThenBackupData() async {
    if (!formKey.currentState!.validate()) return;
    await login();
    if (!loggedIn) return;
    backupData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: (isLoading)
                      ? const <Widget>[
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        ]
                      : <Widget>[
                          Row(
                            children: const <Widget>[
                              HeaderOne(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                text: 'Login',
                              ),
                            ],
                          ),
                          TextFormFieldWithLabel(
                            label: 'Email',
                            controller: emailController,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            isPassword: false,
                          ),
                          TextFormFieldWithLabel(
                            label: 'Password',
                            controller: passwordController,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            isPassword: true,
                          ),
                          Row(
                            children: [
                              Text(
                                error,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: ElevatedButton(
                                  onPressed: loginThenBackupData,
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 35,
                                    ),
                                    child: Text('Login & Backup'),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
