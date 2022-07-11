import 'package:flutter/material.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // print(objectBox.accountBox.getAll());
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
    if (noStoreDetails()) return const StoreDetailsRegistrationScreen();
    return const SplashScreen();
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
