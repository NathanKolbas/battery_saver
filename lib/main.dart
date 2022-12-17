import 'package:battery_saver/hive/hive_helper.dart';
import 'package:battery_saver/pages/home/home_page.dart';
import 'package:battery_saver/pages/login/login_page.dart';
import 'package:battery_saver/providers/charging_provider.dart';
import 'package:battery_saver/providers/wyze_client_provider.dart';
import 'package:battery_saver/services/foreground_battery_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'helpers/updater.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Setup Hive
  await setupHive();
  // Setup Wyze
  await WyzeClientProvider().initialize();
  // Setup foreground service
  await initializeBatteryService();
  startBatteryService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WyzeClientProvider>(create: (context) => WyzeClientProvider(),),
        ChangeNotifierProvider<ChargingProvider>(create: (context) => ChargingProvider(),),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batter Saver',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    // Request permissions
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

    // Check for update
    GitHubUpdater().updateSnackBar(context, mounted);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<WyzeClientProvider>(context).loggedIn ? const HomePage() : const LoginPage();
  }
}
