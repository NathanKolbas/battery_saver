import 'package:battery_saver/hive/preferences/charging_preferences.dart';
import 'package:battery_saver/hive/preferences/device_preference.dart';
import 'package:hive_flutter/adapters.dart';

import '../globals.dart';

/// Setup Hive, get boxes, and any adapters.
Future setupHive() async {
  await Hive.initFlutter();

  // Register adapters here
  Hive.registerAdapter<ChargingPreferences>(ChargingPreferencesAdapter());
  Hive.registerAdapter<DevicePreferences>(DevicePreferencesAdapter());

  // Open boxes here
  boxChargingPrefs = await Hive.openBox('boxChargingPrefs');
}
