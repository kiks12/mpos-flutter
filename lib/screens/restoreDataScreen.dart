import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/storeDetails.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

const serverRestoreDataAPIEndpoint =
    'https://mpos-data-center.herokuapp.com/backup/restore/';
const loginAPIEndpoint =
    'https://mpos-data-center.herokuapp.com/login/callback/';
//const serverRestoreDataAPIEndpoint = 'http://localhost:3000/backup/download';
//const loginAPIEndpoint = 'http://localhost:3000/login/callback';

const files = [
  'STORE_DETAILS',
  'ACCOUNTS',
  'INVENTORY',
  'ATTENDANCE',
  'TRANSACTIONS',
  'EXPIRATION_DATES',
];

final httpClient = HttpClient();

class RestoreDataScreen extends StatefulWidget {
  const RestoreDataScreen({Key? key}) : super(key: key);

  @override
  State<RestoreDataScreen> createState() => _RestoreDataScreenState();
}

class _RestoreDataScreenState extends State<RestoreDataScreen> {
  bool isLoading = false;
  bool loggedIn = false;
  double progress = 0;
  String error = '';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  Future<void> restoreData(BuildContext context) async {
    await clearData();
    final downloadedFiles = await downloadFiles();
    await encodeDownloadedFilesToDB(downloadedFiles);
    GetStorage().remove('id');
    GetStorage().remove('email');

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
  }

  Future<void> clearData() async {
    objectBox.storeDetailsBox.removeAll();
    objectBox.accountBox.removeAll();
    objectBox.attendanceBox.removeAll();
    objectBox.transactionBox.removeAll();
    objectBox.ingredientBox.removeAll();
    objectBox.productBox.removeAll();
    objectBox.expirationDateBox.removeAll();
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> encodeDownloadedFilesToDB(List<File> downloadedFiles) async {
    for (int i = 0; i < downloadedFiles.length; i++) {
      final fileString = downloadedFiles[i].openRead();
      final fields = await fileString
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();
      if (files[i] == 'STORE_DETAILS') addStoreDetailsRow(fields);
      if (files[i] == 'ACCOUNTS') addAccountRow(fields);
      if (files[i] == 'INVENTORY') addInventoryRow(fields);
      if (files[i] == 'ATTENDANCE') addAttendanceRow(fields);
      if (files[i] == 'TRANSACTIONS') addTransactionsRow(fields);
      if (files[i] == 'EXPIRATION_DATES') addExpirationDateRow(fields);
      progress = ((i + 1) * 2 / downloadedFiles.length * 2);
      setState(() {});
    }
  }

  addStoreDetailsRow(List<List<dynamic>> fields) {
    for (int i = 0; i < fields.length; i++) {
      if (i == 0) continue;
      objectBox.storeDetailsBox.put(
        StoreDetails(
          name: fields[i][1],
          contactNumber: fields[i][2],
          contactPerson: fields[i][3],
        ),
      );
    }
  }

  addAccountRow(List<List<dynamic>> fields) {
    for (int i = 0; i < fields.length; i++) {
      if (i == 0) continue;
      objectBox.accountBox.put(
        Account(
          firstName: fields[i][1],
          middleName: fields[i][2],
          lastName: fields[i][3],
          isAdmin: (fields[i][4] == 'true') ? true : false,
          emailAddress: fields[i][5],
          contactNumber: fields[i][6].toString(),
          password: fields[i][7],
        ),
      );
    }
  }

  addInventoryRow(List<List<dynamic>> fields) {
    for (int i = 0; i < fields.length; i++) {
      if (i == 0) continue;
      objectBox.productBox.put(
        Product(
          name: fields[i][1],
          barcode: fields[i][2],
          category: fields[i][3],
          unitPrice: fields[i][4],
          quantity: fields[i][5],
          totalPrice: fields[i][6],
        ),
      );
    }
  }

  addAttendanceRow(List<List<dynamic>> fields) {
    for (int i = 0; i < fields.length; i++) {
      if (i == 0) continue;

      final user = objectBox.accountBox
          .query(Account_.emailAddress.equals(fields[i][1]))
          .build()
          .findFirst();
      final attendance = Attendance(
        date: DateTime.parse(fields[i][2]),
        timeIn: DateTime.parse(fields[i][3]),
        timeOut: DateTime.parse(fields[i][4]),
      );

      attendance.user.target = user;
      user!.attendance.add(attendance);

      objectBox.attendanceBox.put(attendance);
    }
  }

  addTransactionsRow(List<List<dynamic>> fields) {
    for (int i = 0; i < fields.length; i++) {
      if (i == 0) continue;
      final product = objectBox.productBox
          .query(Product_.barcode.equals(fields[i][2]))
          .build()
          .findFirst();
      final user = objectBox.accountBox
          .query(Account_.emailAddress.equals(fields[i][3]))
          .build()
          .findFirst();

      final transaction = Transaction(
        transactionID: fields[i][1],
        quantity: fields[i][4],
        paymentMethod: fields[i][5],
        totalAmount: fields[i][6],
        date: DateTime.parse(fields[i][7]),
        time: DateTime.parse(fields[i][8]),
      );

      transaction.product.target = product;
      transaction.user.target = user;

      objectBox.transactionBox.put(transaction);

      // product?.transation.add(transaction);
      // user?.transactions.add(transaction);

      // objectBox.productBox.put(product!);
      // objectBox.accountBox.put(user!);
    }
  }

  addExpirationDateRow(List<List<dynamic>> fields) {
    for (int i = 0; i < fields.length; i++) {
      if (i == 0) continue;

      final product = objectBox.productBox
          .query(Product_.barcode.equals(fields[i][1]))
          .build()
          .findFirst();

      final expirationDate = ExpirationDate(
        date: DateTime.parse(fields[i][2]),
        quantity: fields[i][3],
        sold: fields[i][4],
        expired: fields[i][5],
      );

      expirationDate.productExp.target = product;
      objectBox.expirationDateBox.put(expirationDate);

      product?.expirationDates.add(expirationDate);
      objectBox.productBox.put(product!);
    }
  }

  Future<File> downloadSpecificFile(String file) async {
    final request = await httpClient.getUrl(
      Uri.parse('$serverRestoreDataAPIEndpoint?type=$file'),
    );
    request.headers.add('Authorization', "Bearer ${GetStorage().read('uuid')}");
    final response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File finalFile = File('$dir/${DateTime.now().toString()}-$file.csv');
    finalFile.writeAsBytes(bytes);
    return Future.value(finalFile);
  }

  Future<List<File>> downloadFiles() async {
    final List<File> downloadedFiles = [];
    for (int i = 0; i < files.length; i++) {
      final file = await downloadSpecificFile(files[i]);
      downloadedFiles.add(file);
      progress = (i + 1 / files.length * 2);
      setState(() {});
    }
    return downloadedFiles;
  }

  void loginThenBackupData(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    await login();
    if (!loggedIn) return;
    restoreData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore Data'),
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
                                      text: 'Restore Data from Cloud',
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
                                  onPressed: () => loginThenBackupData(context),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 35,
                                    ),
                                    child: Text('Restore'),
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
