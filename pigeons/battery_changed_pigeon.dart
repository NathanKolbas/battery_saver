/// Run to generate:
/// flutter pub run pigeon --input pigeons/battery_changed_pigeon.dart
///
/// Some good example code:
/// https://github.com/flutter/packages/blob/main/packages/pigeon/example/app/android/app/src/main/kotlin/dev/flutter/pigeon_example_app/MainActivity.kt
/// https://github.com/39499740/flutter_pigeon_plugin/blob/master/android/src/main/kotlin/com/example/flutter_pigeon_plugin/FlutterPigeonPlugin.kt

import 'package:pigeon/pigeon.dart';

class NativeBatteryInfo {
  int? batteryLevel;
  int? batteryTemperature;
  int? voltage;
  int? currentNow;
  int? avgCurrent;
  bool? batteryLow;
  bool? batteryPresent;
  String? batteryStatus;
  String? chargePlug;
  String? batteryHealth;
}

// This config applies to both HostApi and FlutterApi
@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/pigeon/battery_changed_pigeon.g.dart',
  kotlinOut: 'android/app/src/main/kotlin/com/nathan/batter_saver/battery_saver/BatteryChangedPigeon.g.kt',
))
@FlutterApi()
abstract class NBatteryChangedPigeon {
  void sendBatteryInfo(NativeBatteryInfo info);
  void turnOnAllPlugs();
  void turnOffAllPlugs();
}

@HostApi()
abstract class FBatteryChangedPigeon {
  void openPersistentNotificationSettings();
}
