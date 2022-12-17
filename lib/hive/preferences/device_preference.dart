import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class DevicePreferences extends HiveObject {
  @HiveField(0)
  String mac;
  static const macDefault = '';

  @HiveField(1)
  String model;
  static const modelDefault = '';

  DevicePreferences({
    this.mac = macDefault,
    this.model = modelDefault,
  });
}
