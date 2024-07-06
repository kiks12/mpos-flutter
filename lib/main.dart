import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/object_box.dart';
import 'package:mpos/models/store_details.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/splash_screen.dart';
import 'package:mpos/screens/startup_menu_screen.dart';
import 'package:mpos/screens/store_details_registration_screen.dart';

late ObjectBox objectBox;
ColorScheme appColors = ColorScheme.fromSeed(seedColor: Colors.pinkAccent);

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
      return const StartUpMenuScreen();
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
        colorScheme: appColors,
        useMaterial3: true,
      ),
      home: screenToShow(),
    );
  }
}
