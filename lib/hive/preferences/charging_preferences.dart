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
  late List<DevicePreferences> selectedDevices;
  final selectedDevicesDefault = <DevicePreferences>[];

  ChargingPreferences({
    this.chargePercentage = chargePercentageDefault,
    List<DevicePreferences>? selectedDevices,
  }) {
    // If you use a const list then that list can not be modified which prevents adding
    this.selectedDevices = selectedDevices ?? selectedDevicesDefault;
  }

  static ChargingPreferences load() {
    return boxChargingPrefs?.get('ChargingPreferences', defaultValue: ChargingPreferences());
  }

  static Future<ChargingPreferences> loadReopen() async {
    await boxChargingPrefs?.close();
    boxChargingPrefs = await Hive.openBox('boxChargingPrefs');
    return load();
  }
}
