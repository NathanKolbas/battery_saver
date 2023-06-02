import 'package:hive/hive.dart';

import '../../globals.dart';
import 'device_preference.dart';

part 'charging_preferences.g.dart';

@HiveType(typeId: 0)
class ChargingPreferences extends HiveObject {
  /// What percentage to charge the device up to
  @HiveField(0, defaultValue: chargePercentageDefault)
  int chargePercentage;
  static const chargePercentageDefault = 0;

  bool get chargeOff => chargePercentage == 0;

  /// The devices to activate when reaching the charge
  @HiveField(1, defaultValue: <DevicePreferences>[])
  late List<DevicePreferences> selectedDevices;
  final selectedDevicesDefault = <DevicePreferences>[];

  /// What percentage to turn back on charging
  @HiveField(2, defaultValue: chargePercentageTurnOnDefault)
  int chargePercentageTurnOn;
  static const chargePercentageTurnOnDefault = 0;

  ChargingPreferences({
    this.chargePercentage = chargePercentageDefault,
    this.chargePercentageTurnOn = chargePercentageTurnOnDefault,
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
