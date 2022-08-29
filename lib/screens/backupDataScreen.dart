import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/screens/home/homeScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

import 'package:http/http.dart' as http;

const serverUploadAPIEndpoint =
    'https://mpos-data-center.herokuapp.com/backup/upload/';
const loginAPIEndpoint =
    'https://mpos-data-center.herokuapp.com/login/callback/';
// const serverUploadAPIEndpoint = 'http://localhost:3000/backup/upload';
// const loginAPIEndpoint = 'http://localhost:3000/login/callback';

class BackupDataScreen extends StatefulWidget {
  const BackupDataScreen({Key? key}) : super(key: key);

  @override
  State<BackupDataScreen> createState() => _BackupDataScreenState();
}

class _BackupDataScreenState extends State<BackupDataScreen> {
  bool isLoading = false;
  bool loggedIn = false;
  double progress = 0;
  String error = '';
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
    await uploadCSVFilesToServer(csvs.values.toList(), csvs.keys.toList());
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
      'STORE_DETAILS': storeDetailsCSVFile,
      'ACCOUNTS': accountsCSVFile,
      'ATTENDANCE': attendanceCSVFile,
      'INVENTORY': inventoryCSVFile,
      'EXPIRATION_DATES': expirationDatesCSVFile,
      'TRANSACTIONS': transactionsCSVFile,
    });
  }

  Future<int?> sendFilesToSpecificDirs(String dir, String filePath) async {
    try {
      final Map<String, String> headers = {
        'Authorization': 'Bearer ${GetStorage().read('uuid')}',
        'Content-Type': 'multipart/form-data',
      };
      final file = await http.MultipartFile.fromPath('file', filePath);
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$serverUploadAPIEndpoint?type=$dir&isDefault=true'),
      );
      request.headers.addAll(headers);
      request.files.add(file);
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);
      return Future.value(response.statusCode);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> uploadCSVFilesToServer(
    List<File> files,
    List<String> fileDirs,
  ) async {
    try {
      for (int i = 0; i < files.length; i++) {
        final status =
            await sendFilesToSpecificDirs(fileDirs[i], files[i].path);
        if (status != 200) {
          error = 'There Seems to be a problem. Please try again later.';
          progress = ((i + 1) / files.length) * 100;
          setState(() {});
          break;
        }
        progress = ((i + 1) / files.length) * 100;
        setState(() {});
        continue;
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
    for (var product in inventory) {
      inventoryValues.add([
        product.id,
        product.name,
        product.barcode,
        product.category,
        product.unitPrice,
        product.quantity,
        product.totalPrice,
      ]);
    }

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
    for (var store in storeDetails) {
      storeDetailsValues.add([
        store.id,
        store.name,
        store.contactNumber,
        store.contactPerson,
      ]);
    }

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
    for (var account in accounts) {
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
    }

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
    for (var attendance in attendances) {
      attendanceValues.add([
        attendance.id,
        attendance.user.target!.emailAddress,
        attendance.date,
        attendance.timeIn,
        attendance.timeOut,
      ]);
    }

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
    for (var expirationDate in expirationsDates) {
      expirationDateValues.add([
        expirationDate.id,
        expirationDate.productExp.target!.barcode,
        expirationDate.date,
        expirationDate.quantity,
        expirationDate.sold,
        expirationDate.expired,
      ]);
    }

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
    for (var transaction in transactions) {
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
    }

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
      appBar: AppBar(
        title: const Text('Backup Data'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: (isLoading)
                      ? <Widget>[
                          Center(
                            child: Column(
                              children: <Widget>[
                                const CircularProgressIndicator(),
                                Text('Loading... ${progress.toString()}%'),
                              ],
                            ),
                          ),
                        ]
                      : <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    HeaderOne(
                                      padding: EdgeInsets.zero,
                                      text: 'Backup Data to Cloud',
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 2),
                                      child: Text(
                                        'Enter Email and Password to Continue',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                    child: Text('Backup'),
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
