import 'package:battery_saver/wyze/errors/wyze_errors.dart';
import 'package:flutter/material.dart';

import '../modles.dart';
import 'base.dart';

class PlugProps {
  static PropDef statusLight() => PropDef("P13", bool);

  static PropDef awayMode() => PropDef("P1614", bool);

  static PropDef rssi() => PropDef("P1612", int);

  static PropDef photosensitiveSwitch() => PropDef("photosensitive_switch", bool);
}

class Plug extends AbstractWirelessNetworkedDevice with SwitchableMixin {
  static const pType = "Plug";

  @override
  Set<String> get attributes => super.attributes.union({
    'switch_state_timer',
  });

  DeviceProp? _awayMode;
  bool get awayMode => _awayMode == null ? false : _awayMode!.value;

  // int, DeviceProp
  set awayMode(dynamic value) {
    if (value is int) {
      value = DeviceProp(definition: PlugProps.awayMode(), value: value);
    }
    _awayMode = value;
  }

  DeviceProp? _statusLight;
  bool get statusLight => _statusLight == null ? false : _statusLight!.value;

  // int, DeviceProp
  set statusLight(dynamic value) {
    if (value is int) {
      value = DeviceProp(definition: PlugProps.statusLight(), value: value);
    }
    _statusLight = value;
  }

  Plug({
    String? type,
    required Map<String, dynamic> others,
  }) : super(others: others..addAll({'type': type})) {
    // TODO: Fix extractProperty and DeviceProps
    // They need to handled correctly in Dart since the translation from Python
    // was really bad by me. For now, I am going to cheat this.
    // switchState = extractProperty(propDef: DeviceProps.powerState(), others: others);
    switchState = extractProperty(propDef: 'switch_state', others: others);
    // _switch_state_timer = super.extractAttribute("switch_state_timer", others);
    statusLight = extractProperty(propDef: PlugProps.statusLight(), others:  others);
    awayMode = extractProperty(propDef: PlugProps.awayMode(), others:  others);
    // show_unknown_key_warning(others);
  }
  
  static Plug? parse(dynamic device) {
    if (device == null) {
      return null;
    } else if (device is Plug) {
      return device;
    } else if (device is Map<String, dynamic>) {
      if (device.containsKey('product_type')) {
        final type = device["product_type"];
        if (type == Plug.pType) {
          return Plug(type: type, others: device);
        } else if (type == OutdoorPlug.pType) {
          return OutdoorPlug(others: device);
        } else {
          debugPrint("Unknown plug detected ($device)");
          return Plug(type: type, others: device);
        }
      }
      return null;
    }
    throw const WyzeObjectFormationError('Device needs to be of type Map or PLug');
  }
}

class OutdoorPlug extends Plug {
  static const pType = "OutdoorPlug";

  OutdoorPlug({required Map<String, dynamic> others}) : super(type: pType, others: others) {
    _photosensitiveSwitch = extractProperty(propDef: PlugProps.photosensitiveSwitch(), others: others);
    // show_unknown_key_warning(others);
  }

  DeviceProp? _photosensitiveSwitch;

  bool get isPhotosensitive => photosensitiveSwitch;

  bool get photosensitiveSwitch => _photosensitiveSwitch == null ? false : _photosensitiveSwitch!.value;

  // int, DeviceProp
  set photosensitiveSwitch(dynamic value) {
    if (value is int) {
      value = DeviceProp(definition: PlugProps.photosensitiveSwitch(), value: value);
    }
    _photosensitiveSwitch = value;
  }
}
