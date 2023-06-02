// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charging_preferences.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChargingPreferencesAdapter extends TypeAdapter<ChargingPreferences> {
  @override
  final int typeId = 0;

  @override
  ChargingPreferences read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChargingPreferences(
      chargePercentage: fields[0] == null ? 0 : fields[0] as int,
      chargePercentageTurnOn: fields[2] == null ? 0 : fields[2] as int,
      selectedDevices: fields[1] == null
          ? []
          : (fields[1] as List?)?.cast<DevicePreferences>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChargingPreferences obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.chargePercentage)
      ..writeByte(1)
      ..write(obj.selectedDevices)
      ..writeByte(2)
      ..write(obj.chargePercentageTurnOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChargingPreferencesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
