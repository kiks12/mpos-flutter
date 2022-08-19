import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
    await downloadFiles();
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => const HomeScreen())));
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

  Future<void> downloadFiles() async {
    for (int i = 0; i < files.length; i++) {
      final file = await downloadSpecificFile(files[i]);
      print(file.path);
    }
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
