import 'package:hive/hive.dart';

import '../preferences/device_preference.dart';

class DeviceAdapter extends TypeAdapter<DevicePreferences> {
  @override
  final typeId = 1;

  @override
  DevicePreferences read(BinaryReader reader) {
    return DevicePreferences()
      ..mac = reader.read()
      ..model = reader.read();
  }

  @override
  void write(BinaryWriter writer, DevicePreferences obj) {
    writer
      ..write(obj.mac)
      ..write(obj.model);
  }
}
