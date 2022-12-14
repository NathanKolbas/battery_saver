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
    required Map others,
  }) : super(others: others..addAll({'type': type})) {
    switchState = extractProperty(propDef: DeviceProps.powerState(), others: others);
    // _switch_state_timer = super.extractAttribute("switch_state_timer", others);
    statusLight = extractProperty(propDef: PlugProps.statusLight(), others:  others);
    awayMode = extractProperty(propDef: PlugProps.awayMode(), others:  others);
    // show_unknown_key_warning(others);
  }
}
