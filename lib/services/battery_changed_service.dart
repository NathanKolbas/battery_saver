import '../hive/preferences/charging_preferences.dart';
import '../pigeon/battery_changed_pigeon.g.dart';
import '../providers/wyze_client_provider.dart';

class DartBatteryChangedPigeon extends BatteryChangedPigeon {
  factory DartBatteryChangedPigeon() => _getInstance();

  static DartBatteryChangedPigeon get instance => _getInstance();

  static DartBatteryChangedPigeon? _instance;

  static DartBatteryChangedPigeon _getInstance() {
    _instance ??= DartBatteryChangedPigeon._internal();
    BatteryChangedPigeon.setup(_instance);
    return _instance!;
  }

  DartBatteryChangedPigeon._internal();

  @override
  void nativeSendMessage(NativeBatteryInfo info) async {
    final wyzeClientProvider = await WyzeClientProvider().initialize();
    final ChargingPreferences chargingPreferences = await ChargingPreferences.loadReopen();

    if (info.batteryStatus == 'Charging') {
      if ((info.batteryLevel ?? 0) >= chargingPreferences.chargePercentage) {
        // Turn off all the plugs since we reached the charge
        for (final device in chargingPreferences.selectedDevices) {
          wyzeClientProvider.turnOffPlug(device.mac, device.model);
        }
      }
    } else {
      if ((info.batteryLevel ?? 0) <= chargingPreferences.chargePercentageTurnOn) {
        // Turn on all the plugs since we reached to min charge
        for (final device in chargingPreferences.selectedDevices) {
          wyzeClientProvider.turnOnPlug(device.mac, device.model);
        }
      }
    }
  }
}
