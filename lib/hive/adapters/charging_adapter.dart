import 'package:battery_saver/hive/preferences/charging_preferences.dart';
import 'package:battery_saver/hive/preferences/device_preference.dart';
import 'package:hive/hive.dart';


class ChargingAdapter extends TypeAdapter<ChargingPreferences> {
  @override
  final typeId = 0;

  @override
  ChargingPreferences read(BinaryReader reader) {
    return ChargingPreferences()
      ..chargePercentage = reader.readInt()
      ..selectedDevices = List<DevicePreferences>.from(reader.readList());
  }

  @override
  void write(BinaryWriter writer, ChargingPreferences obj) {
    writer
      ..writeInt(obj.chargePercentage)
      ..writeList(obj.selectedDevices);
  }
}
