import '../hive/preferences/charging_preferences.dart';
import '../pigeon/battery_changed_pigeon.g.dart';
import '../providers/wyze_client_provider.dart';

class DartBatteryChangedPigeon extends NBatteryChangedPigeon {
  factory DartBatteryChangedPigeon() => _getInstance();

  static DartBatteryChangedPigeon get instance => _getInstance();

  static DartBatteryChangedPigeon? _instance;

  static DartBatteryChangedPigeon _getInstance() {
    _instance ??= DartBatteryChangedPigeon._internal();
    NBatteryChangedPigeon.setup(_instance);
    return _instance!;
  }

  DartBatteryChangedPigeon._internal();

  @override
  void sendBatteryInfo(NativeBatteryInfo info) async {
    final wyzeClientProvider = await WyzeClientProvider().initialize();
    final ChargingPreferences chargingPreferences = await ChargingPreferences.loadReopen();

    if (info.batteryStatus == 'Charging') {
      if ((info.batteryLevel ?? 0) >= chargingPreferences.chargePercentage) {
        wyzeClientProvider.refreshTokenIfExpired();

        // Turn off all the plugs since we reached the charge
        turnOffAllPlugs(wyzeClientProvider, chargingPreferences);
      }
    } else {
      if ((info.batteryLevel ?? 0) <= chargingPreferences.chargePercentageTurnOn) {
        wyzeClientProvider.refreshTokenIfExpired();

        // Turn on all the plugs since we reached to min charge
        turnOnAllPlugs(wyzeClientProvider, chargingPreferences);
      }
    }
  }

  @override
  void turnOnAllPlugs([
    WyzeClientProvider? wyzeClientProvider,
    ChargingPreferences? chargingPreferences,
  ]) async {
    wyzeClientProvider ??= await WyzeClientProvider().initialize();
    chargingPreferences ??= await ChargingPreferences.loadReopen();

    for (final device in chargingPreferences.selectedDevices) {
      wyzeClientProvider.turnOnPlug(device.mac, device.model);
    }
  }

  @override
  void turnOffAllPlugs([
    WyzeClientProvider? wyzeClientProvider,
    ChargingPreferences? chargingPreferences,
  ]) async {
    wyzeClientProvider ??= await WyzeClientProvider().initialize();
    chargingPreferences ??= await ChargingPreferences.loadReopen();

    for (final device in chargingPreferences.selectedDevices) {
      wyzeClientProvider.turnOffPlug(device.mac, device.model);
    }
  }
}
