import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mpos/components/HeaderOne.dart';
import 'package:mpos/components/HeaderTwo.dart';
import 'package:mpos/components/TextFormFieldWithLabel.dart';
import 'package:mpos/main.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/attendance.dart';
import 'package:mpos/models/expirationDates.dart';
import 'package:mpos/models/inventory.dart';
import 'package:mpos/models/storeDetails.dart';
import 'package:mpos/models/transaction.dart';
import 'package:mpos/screens/home/tabs/accounts/editAccountScreen.dart';
import 'package:mpos/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Account? currentAccount;

  final formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();

  String _error = '';
  bool _isLoading = false;

  static final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    setState(() {
      currentAccount = Utils().getCurrentAccount(objectBox);
    });
  }

  Future<void> _generateCSVs() async {
    setState(() {
      _isLoading = true;
    });
    await generateCSVofStoreDetails();
    await generateCSVofAccounts();
    await generateCSVofAttendance();
    await generateCSVofInventory();
    await generateCSVofExpirationDate();
    await generateCSVofTransactions();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> generateCSVofInventory() async {
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
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> generateCSVofStoreDetails() async {
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
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> generateCSVofAccounts() async {
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
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> generateCSVofAttendance() async {
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
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> generateCSVofExpirationDate() async {
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
    return Future.delayed(const Duration(seconds: 1));
  }

  Future<void> generateCSVofTransactions() async {
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
    return Future.delayed(const Duration(seconds: 1));
  }

  void logout() {
    GetStorage().remove('id');
    GetStorage().remove('email');

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const MyApp()));
  }

  void navigateToEditAccountScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAccountScreen(
          account: currentAccount,
          accountBox: objectBox.accountBox,
        ),
      ),
    );
  }

  void _resetApp() {
    if (!formKey.currentState!.validate()) return;

    if (passwordController.text != currentAccount!.password) {
      setState(() {
        _error = 'Incorrect Password';
      });
      return;
    }

    objectBox.accountBox.removeAll();
    objectBox.attendanceBox.removeAll();
    objectBox.expirationDateBox.removeAll();
    objectBox.transactionBox.removeAll();
    objectBox.ingredientBox.removeAll();
    objectBox.storeDetailsBox.removeAll();
    objectBox.productBox.removeAll();

    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => const MyApp())));
  }

  void _onCancel(void Function(void Function()) setState) {
    passwordController.text = '';
    setState(() {
      _error = '';
    });
    Navigator.pop(context);
  }

  Future<void> _showResetDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: ((context, setState) => AlertDialog(
                title: const Text('Reset System'),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                          'Resetting Mobile Point of Sale System. Please enter your admin password.'),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Form(
                          key: formKey,
                          child: TextFormFieldWithLabel(
                            label: 'Password',
                            controller: passwordController,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            isPassword: true,
                          ),
                        ),
                      ),
                      Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => _onCancel(setState),
                  ),
                  ElevatedButton(
                    child: const Text('Confirm'),
                    onPressed: _resetApp,
                  ),
                ],
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeaderOne(padding: EdgeInsets.all(0), text: 'Settings'),
                  SettingsHeader(
                    currentAccount: currentAccount,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1,
                            color: Color.fromARGB(255, 228, 228, 228)),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                      onPressed: navigateToEditAccountScreen,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Edit Account'),
                      ),
                    ),
                  ),
                  currentAccount!.isAdmin
                      ? Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1,
                                  color: Color.fromARGB(255, 228, 228, 228)),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: TextButton(
                            onPressed: _generateCSVs,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Backup Database'),
                            ),
                          ),
                        )
                      : Container(),
                  currentAccount!.isAdmin
                      ? Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  width: 1,
                                  color: Color.fromARGB(255, 228, 228, 228)),
                            ),
                          ),
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: TextButton(
                            onPressed: _showResetDialog,
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text('Reset System'),
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            width: 1,
                            color: Color.fromARGB(255, 228, 228, 228)),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextButton(
                      onPressed: logout,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('Logout'),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SettingsHeader extends StatefulWidget {
  const SettingsHeader({
    Key? key,
    required this.currentAccount,
  }) : super(key: key);

  final Account? currentAccount;

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              child: Text(widget.currentAccount!.firstName[0].toUpperCase()),
              radius: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderTwo(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    text:
                        '${widget.currentAccount!.lastName}, ${widget.currentAccount!.firstName} ${widget.currentAccount!.middleName[0].toUpperCase()}.',
                  ),
                  Text(widget.currentAccount!.emailAddress),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
