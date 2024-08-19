import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/firebase_options.dart';
import 'package:mpos/models/account.dart';
import 'package:mpos/models/object_box.dart';
import 'package:mpos/models/store_details.dart';
import 'package:mpos/objectbox.g.dart';
import 'package:mpos/screens/splash_screen.dart';
import 'package:mpos/screens/startup_menu_screen.dart';
import 'package:mpos/screens/store_details_registration_screen.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

late ObjectBox objectBox;
ColorScheme appColors = ColorScheme.fromSeed(seedColor: Colors.blue);
const posTier = "FREE_TRIAL";
// const posTier = "BASIC";
// const posTier = "PRO";
// const posTier = "PREMIUM";
const freeTrialInventoryLimit = 5;
const basicInventoryLimit = 15;
const proInventoryLimit = 30;
const premiumInventoryLimit = 1000;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  objectBox = await ObjectBox.create();
  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

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
    deleteApkFiles();
    super.initState();
  }

  static const platform = MethodChannel('com.example.mpos/downloads');

  Future<String?> getDownloadsPath() async {
    try {
      final String? path = await platform.invokeMethod('getDownloadsDir');
      return path;
    } on PlatformException catch (e) {
      Fluttertoast.showToast(msg: "Failed to get downloads directory: '${e.message}'.");
      return null;
    }
  }

  Future<void> deleteApkFiles() async {
    final storageGranted = await Permission.storage.request().isGranted;
    if (!storageGranted) {
      Fluttertoast.showToast(msg: "Storage permission not granted");
      return;
    }

    try {
      String? downloadsDirPath = await getDownloadsPath();

      if (downloadsDirPath == null) {
        Fluttertoast.showToast(msg: "Cannot access downloads directory");
        return;
      }

      final downloadsDir = Directory(downloadsDirPath);
      List<FileSystemEntity> files = downloadsDir.listSync();
      for (FileSystemEntity file in files) {
        if (file is File && file.path.endsWith('.apk')) {
          try {
            await file.delete();
          } catch (e) {
            Fluttertoast.showToast(msg: "Error deleting file");
          }
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error accessing the Downloads directory");
    }
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
