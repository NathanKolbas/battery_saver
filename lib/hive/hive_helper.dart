import 'package:battery_saver/hive/adapters/charging_adapter.dart';
import 'package:battery_saver/hive/adapters/device_adapter.dart';
import 'package:battery_saver/hive/preferences/charging_preferences.dart';
import 'package:battery_saver/hive/preferences/device_preference.dart';
import 'package:hive_flutter/adapters.dart';

import '../globals.dart';

/// Setup Hive, get boxes, and any adapters.
Future setupHive() async {
  await Hive.initFlutter();

  // Register adapters here
  Hive.registerAdapter<ChargingPreferences>(ChargingAdapter());
  Hive.registerAdapter<DevicePreferences>(DeviceAdapter());

  // Open boxes here
  boxChargingPrefs = await Hive.openBox('boxChargingPrefs');
}
