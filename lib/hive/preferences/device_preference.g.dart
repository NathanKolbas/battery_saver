// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_preference.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DevicePreferencesAdapter extends TypeAdapter<DevicePreferences> {
  @override
  final int typeId = 1;

  @override
  DevicePreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DevicePreferences(
      mac: fields[0] as String,
      model: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DevicePreferences obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.mac)
      ..writeByte(1)
      ..write(obj.model);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevicePreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
