import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/storeDetails.dart';
import 'package:mpos/screens/home/homeScreen.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

// const serverUploadAPIEndpoint =
//     'https://mpos-data-center.herokuapp.com/backup/restore/';
// const loginAPIEndpoint =
//     'https://mpos-data-center.herokuapp.com/login/callback/';
const serverRestoreDataAPIEndpoint = 'http://localhost:3000/backup/restore';
const loginAPIEndpoint = 'http://localhost:3000/login/callback';

const files = [
  'Store-Details',
  'Accounts',
  'Inventory',
  'Attendance',
  'Transactions',
  'Expiration-Dates',
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

  Future<void> restoreData() async {
    await clearData();
    final downloadedFiles = await downloadFiles();
    await encodeDownloadedFilesToDB(downloadedFiles);
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => const HomeScreen())));
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
      if (files[i] == 'Store-Details') addStoreDetailsRow(fields);
      if (files[i] == 'Accounts') addAccountRow(fields);
      if (files[i] == 'Inventory') addInventoryRow(fields);
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

  // addStoreDetailsRow(List<List<dynamic>> fields) {
  //   for (int i = 0; i < fields.length; i++) {
  //     objectBox.storeDetailsBox.put(
  //       StoreDetails(
  //         name: fields[i][1],
  //         contactNumber: fields[i][2],
  //         contactPerson: fields[i][3],
  //       ),
  //     );
  //   }
  // }

  // addStoreDetailsRow(List<List<dynamic>> fields) {
  //   for (int i = 0; i < fields.length; i++) {
  //     objectBox.storeDetailsBox.put(
  //       StoreDetails(
  //         name: fields[i][1],
  //         contactNumber: fields[i][2],
  //         contactPerson: fields[i][3],
  //       ),
  //     );
  //   }
  // }

  // addStoreDetailsRow(List<List<dynamic>> fields) {
  //   for (int i = 0; i < fields.length; i++) {
  //     objectBox.storeDetailsBox.put(
  //       StoreDetails(
  //         name: fields[i][1],
  //         contactNumber: fields[i][2],
  //         contactPerson: fields[i][3],
  //       ),
  //     );
  //   }
  // }

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
    }
    return downloadedFiles;
  }

  void loginThenBackupData() async {
    if (!formKey.currentState!.validate()) return;
    await login();
    if (!loggedIn) return;
    restoreData();
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
