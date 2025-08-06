
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpos/models/object_box.dart';
import 'package:mpos/routes/routes.dart';
import 'package:mpos/screens/home/home_screen_two.dart';
import 'package:mpos/screens/home/tabs/settings_screen.dart';
import 'package:mpos/screens/pos_device_selection_screen.dart';
import 'package:mpos/screens/splash_screen.dart';
import 'package:mpos/screens/supabase_login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

late ObjectBox objectBox;
ColorScheme appColors = ColorScheme.fromSeed(seedColor: Colors.blue);
// const posTier = "FREE_TRIAL";
// const posTier = "BASIC";
// const posTier = "PRO";
const posTier = "PREMIUM";
const freeTrialInventoryLimit = 5;
const basicInventoryLimit = 15;
const proInventoryLimit = 30;
const premiumInventoryLimit = 1000;

Future<void> deleteObjectBoxStore() async {
  final dir = await getApplicationDocumentsDirectory();
  final storeDir = Directory('${dir.path}/objectbox');
  if (await storeDir.exists()) {
    await storeDir.delete(recursive: true);
    print('✅ ObjectBox store deleted');
  }
}

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
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

  @override
  void initState() {
    // deleteApkFiles();
    super.initState();
  }

  // static const platform = MethodChannel('com.example.mpos/downloads');

  // Future<String?> getDownloadsPath() async {
  //   try {
  //     final String? path = await platform.invokeMethod('getDownloadsDir');
  //     return path;
  //   } on PlatformException catch (e) {
  //     Fluttertoast.showToast(msg: "Failed to get downloads directory: '${e.message}'.");
  //     return null;
  //   }
  // }

  // Future<void> deleteApkFiles() async {
  //   final storageGranted = await Permission.storage.request().isGranted;
  //   if (!storageGranted) {
  //     Fluttertoast.showToast(msg: "Storage permission not granted");
  //     return;
  //   }

  //   try {
  //     String? downloadsDirPath = await getDownloadsPath();

  //     if (downloadsDirPath == null) {
  //       Fluttertoast.showToast(msg: "Cannot access downloads directory");
  //       return;
  //     }

  //     final downloadsDir = Directory(downloadsDirPath);
  //     List<FileSystemEntity> files = downloadsDir.listSync();
  //     for (FileSystemEntity file in files) {
  //       if (file is File && file.path.endsWith('.apk')) {
  //         try {
  //           await file.delete();
  //         } catch (e) {
  //           Fluttertoast.showToast(msg: "Error deleting file");
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Error accessing the Downloads directory");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile POS',
      theme: ThemeData(
        colorScheme: appColors,
        useMaterial3: true,
      ),
      initialRoute: splashScreenRoute,
      routes: {
        splashScreenRoute: (context) => SplashScreen(),
        supabaseLoginScreenRoute: (context) => SupabaseLoginScreen(),
        posDeviceSelectionScreenRoute: (context) => PosDeviceSelectionScreen(), 
        homeScreenRoute: (context) => HomeScreenTwo(),
        settingsScreenRoute: (context) => SettingsScreen()
      },
    );
  }
}


/**
 * STORED IN PREFS
 * device_name
 * device_id
 * device_token
 * location_id
 * location_name
 * user_id
 * access_token
 * access_token_expiry
 * refresh_token
 * name
 * business_name
*/