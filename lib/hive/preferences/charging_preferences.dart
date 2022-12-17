import 'package:hive/hive.dart';

import '../../globals.dart';
import 'device_preference.dart';

@HiveType(typeId: 0)
class ChargingPreferences extends HiveObject {
  @HiveField(0)
  int chargePercentage;
  static const chargePercentageDefault = 0;

  bool get chargeOff => chargePercentage == 0;

  @HiveField(1)
  List<DevicePreferences> selectedDevices;
  static const selectedDevicesDefault = <DevicePreferences>[];

  ChargingPreferences({
    this.chargePercentage = chargePercentageDefault,
    this.selectedDevices = selectedDevicesDefault,
  });

  static ChargingPreferences load() {
    return boxChargingPrefs?.get('ChargingPreferences', defaultValue: ChargingPreferences());
  }

  static Future<ChargingPreferences> loadReopen() async {
    await boxChargingPrefs?.close();
    boxChargingPrefs = await Hive.openBox('boxChargingPrefs');
    return load();
  }
}
