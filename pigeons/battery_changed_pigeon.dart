/// Run to generate:
/// flutter pub run pigeon --input pigeons/battery_changed_pigeon.dart

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

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/pigeon/battery_changed_pigeon.g.dart',
  kotlinOut: 'android/app/src/main/kotlin/com/nathan/batter_saver/battery_saver/BatteryChangedPigeon.g.kt',
))
@FlutterApi()
abstract class BatteryChangedPigeon {
  void nativeSendMessage(NativeBatteryInfo info);
}
