import 'dart:convert';

import 'package:flutter/material.dart';

import '../modles.dart';

class DeviceModels {
  static const outdoorPlug = ['WLPPO', 'WLPPO-SUB'];
  static final plug = ['WLPP1', 'WLPP1CFH'] + DeviceModels.outdoorPlug;
}

/// The product information for a Wyze-branded device.
class Product {
  final attributes = {
    "type",
    "model",
    "logo_url",
  };

  late String? _type;
  String? get type => _type;

  late String? _model;
  String? get model => _model;

  late String? _logoUrl;
  String? get logoUrl => _logoUrl;

  Product({
    required String? type,
    required String? model,
    required String? logoUrl,
  }) {
    _type = type;
    _model = model;
    _logoUrl = logoUrl;
  }
}

/// The timezone data associated with a device.
class Timezone {
  late double _offset;
  double get offset => _offset;

  late String _name;
  String get name => _name;

  Timezone({
    required double offset,
    required String name,
  }) {
    _offset = offset;
    _name = name;
  }
}

class DeviceProp {
  late PropDef _definition;
  PropDef get definition => _definition;

  DateTime? _ts;
  DateTime? get ts => _ts;

  late dynamic _value;
  dynamic get value => _value;

  DeviceProp({
    required PropDef definition,
    dynamic ts,
    dynamic value,
  }) {
    _definition = definition;

    if (ts is DateTime) {
      _ts = ts;
    } else if (ts != null) {
      _ts = DateTime.fromMillisecondsSinceEpoch(ts);
    } else {
      _ts = null;
    }

    if (value != null && value.runtimeType == _definition.runtimeType) {
      if (value == '') {
        value = null;
      } else {
        try {
          if (_definition is bool) {
            value = value.toString().toLowerCase() == 'true';
          } else if ( _definition is Map) {
            value = jsonDecode(value);
          } else {
            value = _definition.type(value);
          }
        } catch (e) {
          debugPrint("def ${_definition.pid}");
          debugPrint("could not cast value `$value` into expected type ${_definition.type}");
        }
      }
    }
    if (value == '') value = null;
    _value = value;
  }

  get apiValue {
    if (definition.apiType == null) {
      debugPrint("unknown api type, returning $value unchanged");
      return value;
    }
    // TODO: Later
  }

  @override
  String toString() => "Property ${definition.pid}: $value [API value: $apiValue]";

  toJson() {
    final toReturn = {
      'pid': definition.pid,
      'pvalue': jsonEncode(apiValue),
    };
    if (ts != null) {
      toReturn['ts'] = ts!.toIso8601String();
    }
    return toReturn;
  }
}

class DeviceProps {
  static PropDef pushNotificationsEnabled() => PropDef("P1", bool, int, [0, 1]);

  static PropDef powerState() => PropDef("P3", bool, int, [0, 1]);

  static PropDef onlineState() => PropDef("P5", bool, int, [0, 1]);
}

class Device extends JsonObject {
  @override
  Set<String> attributes = {
    "binding_ts",
    "binding_user_nickname",
    "conn_state",
    "conn_state_ts",
    "enr",
    "event_master_switch",
    "firmware_ver",
    "first_activation_ts",
    "first_binding_ts",
    "hardware_ver",
    "is_in_auto",
    "mac",
    "nickname",
    "p2p_id",
    "p2p_type",
    "parent_device_enr",
    "parent_device_mac",
    "product_model",
    "product_type",
    "push_switch",
    "timezone_gmt_offset",
    "timezone_name",
    "type",
    "user_role",
  };

  String? _mac;
  String? _type;
  String? _nickname;
  String? _enr;
  String? _pushSwitch;
  String? _hardwareVersion;
  String? _firmwareVersion;
  Map<String, String>? _parentDevice;
  Product? _product;
  Timezone? _timezone;
  DeviceProp? _isOnline;

  Device(Map dict) {
    _type = dict['type'] ?? extractAttribute('product_type', dict);
    _mac = dict['mac'];
    _nickname = dict['nickname'];
    if (dict['conn_state'] != null && dict['conn_state_ts'] != null) {
      _isOnline = DeviceProp(definition: DeviceProps.onlineState(), value: dict['conn_state'], ts: dict['conn_state_ts']);
    } else {
      _isOnline = extractProperty(propDef: DeviceProps.onlineState(), others: dict);
    }
    _enr = dict['enr'];
    _pushSwitch = dict['push_switch'].toString();
    _firmwareVersion = dict['firmware_ver'] ?? extractAttribute('firmware_ver', dict);
    _hardwareVersion = dict['hardware_ver'] ?? extractAttribute('firmware_ver', dict);
    if (dict['parent_device_mac'] != null) {
      _parentDevice = { "mac": dict['parent_device_mac'], "enr": dict['parent_device_enr'] };
    }
    _product = Product(
      logoUrl: dict['product_model_logo_url'] ?? extractAttribute('product_model_logo_url', dict),
      model: dict['product_model'] ?? extractAttribute('product_model', dict),
      type: dict['product_type'] ?? extractAttribute('product_type', dict),
    );
    _timezone = Timezone(
      offset: dict['timezone_gmt_offset'] ?? extractAttribute('timezone_gmt_offset', dict),
      name: dict['timezone_name'] ?? extractAttribute('timezone_name', dict),
    );
    // _userRole = dict['user_role'];
  }

  String? get mac => _mac;

  String? get type => _type;

  String? get nickname => _nickname;

  String? get enr => _enr;

  String? get pushSwitch => _pushSwitch;

  String? get hardwareVersion => _hardwareVersion;

  String? get firmwareVersion => _firmwareVersion;

  Map<String, String>? get parentDevice => _parentDevice;

  Product? get product => _product;

  Timezone? get timezone => _timezone;

  DeviceProp get isOnline => _isOnline == null ? false : isOnline.value;

  /// Union[str, PropDef]
  /// Union[dict, Sequence[dict]]
  DeviceProp? extractProperty({propDef, others}) {
    if (propDef is String) {
      propDef = PropDef(propDef);
    }

    if (others is Map) {
      debugPrint("extracting property ${propDef.pid} from dict $others");
      for (final x in others.entries) {
        debugPrint("key: ${x.key}, value: ${x.value}");
        if (x.key == propDef.pid) {
          debugPrint("returning new DeviceProp with value ${x.value}");
          return DeviceProp(definition: propDef, value: x.value);
        }
      }
      if (others.containsKey('data') && others['data'].containsKey('property_list')) {
        debugPrint("found non-empty data property_list");
        return extractProperty(propDef: propDef, others: others['data']);
      }
      if (others.containsKey('props') && others['props'] != null) {
        debugPrint("found non-empty props");
        return extractProperty(propDef: propDef, others: others['props']);
      }
      if (others.containsKey('property_list') && others['property_list'] != null) {
        debugPrint("found non-empty property_list");
        return extractProperty(propDef: propDef, others: others['property_list']);
      }
      if (others.containsKey('device_params') && others['device_params'] != null) {
        debugPrint("found non-empty device_params");
        return extractProperty(propDef: propDef, others: others['device_params']);
      }
    } else {
      debugPrint("extracting property ${propDef.pid} from ${(others).toString()} $others");
      for (final value in others) {
        debugPrint("value $value");
        if (value.containsKey('pid') && propDef.pid == value['pid']) {
          debugPrint("returning new DeviceProp with $value");
          return DeviceProp(definition: propDef, ts: value['ts'], value: value['value']);
        }
      }
    }
    return null;
  }
}

class AbstractNetworkedDevice extends Device {
  String? _ip;
  String? get ip => _ip;

  AbstractNetworkedDevice({
    String? type,
    String? ip,
    required Map<String, dynamic> others,
  }) : super(others..addAll({'type': type})) {
    _ip = ip ?? super.extractAttribute('ip', others);
    _ip ??= super.extractAttribute('ipaddr', others);
  }
}

class AbstractWirelessNetworkedDevice extends AbstractNetworkedDevice {
  int? _rssi;
  int? get rssi => _rssi;

  String? _ssid;
  String? get ssid => _ssid;

  AbstractWirelessNetworkedDevice({
    String? type,
    int? rssi,
    String? ssid,
    required Map<String, dynamic> others,
  }) : super(others: others..addAll({'type': type})) {
    _rssi = int.parse(rssi ?? super.extractAttribute('rssi', others));
    _ssid = ssid ?? super.extractAttribute('ssid', others);
  }
}

/// A mixin for devices that can be switched.
class SwitchableMixin {
  DeviceProp? switchState;

  bool get isOn => switchState?.value == 1;
}
