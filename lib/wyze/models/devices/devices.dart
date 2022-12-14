import 'package:battery_saver/wyze/models/devices/plugs.dart';
import 'package:flutter/material.dart';

import 'base.dart';

class DeviceParser {
  static Device? parse(dynamic device) {
    if (device == null) return null;
    if (device is Device) return device;
    if (device is Map && device.containsKey('product_type')) {
      final type = device["product_type"];
      switch (type) {
        case Plug.pType:
          return Plug(type: device["type"], others: device);
      }
    }
    debugPrint("Unknown device detected and skipped ($device)");
    return null;
  }
}
