import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/objectBox.dart';
import 'package:mpos/models/storeDetails.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/adminRegistrationScreen.dart';
import 'package:mpos/screens/splashScreen.dart';
import 'package:mpos/screens/storeDetailsRegistrationScreen.dart';

late ObjectBox objectBox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  objectBox = await ObjectBox.create();
  await GetStorage.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _storeName = '';

  @override
  void initState() {
    super.initState();
    // print(objectBox.accountBox.getAll());
    // objectBox.productBox.removeAll();
    // objectBox.accountBox.removeAll();
    // objectBox.ingredientBox.removeAll();
    // objectBox.attendanceBox.removeAll();
    // objectBox.transactionBox.removeAll();
    // objectBox.storeDetailsBox.removeAll();
    // objectBox.expirationDateBox.removeAll();
  }

  bool noAdminAccount() {
    Query<Account> adminQuery =
        objectBox.accountBox.query(Account_.isAdmin.equals(true)).build();
    List<Account> admin = adminQuery.find();
    return admin.isEmpty;
  }

  bool noStoreDetails() {
    List<StoreDetails> storeDetailsQuery = objectBox.storeDetailsBox.getAll();
    return storeDetailsQuery.isEmpty;
  }

  dynamic screenToShow() {
    if (noAdminAccount()) {
      return AdminRegistrationScreen(
        accountBox: objectBox.accountBox,
      );
    }

    if (noStoreDetails()) {
      return StoreDetailsRegistrationScreen(
        storeDetailsBox: objectBox.storeDetailsBox,
      );
    }

    setState(() {
      _storeName = objectBox.storeDetailsBox.getAll()[0].name;
    });

    return SplashScreen(
      storeName: _storeName,
      objectBox: objectBox,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile POS',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: screenToShow(),
    );
  }
}
