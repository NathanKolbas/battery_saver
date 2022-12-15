import 'dart:convert';

import 'package:battery_saver/wyze/api/base_client.dart';
import 'package:battery_saver/wyze/models/modles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/devices/base.dart';
import '../../models/devices/plugs.dart';
import '../../service/api_service.dart';

/// A plug usage record that assumes data represents duration of usage.
class PlugUsageRecord extends JsonObject {
  @override
  Set<String> attributes = {
    "hourly_data",
    "total_usage",
  };

  Map<DateTime, int>? hourlyData;

  PlugUsageRecord({
    Map<DateTime, int>? hourlyData,
    Map? others,
  }) {
    others ??= {};
    if (hourlyData != null) {
      this.hourlyData = hourlyData;
    } else {
      var startDatetime = extractAttribute('date_ts', others);
      if (startDatetime is int) {
        // Convert to DateTime
        startDatetime = DateTime.fromMillisecondsSinceEpoch(startDatetime);
      }
      var hourlyData2 = extractAttribute('data', others);
      if (hourlyData2 is String) {
        hourlyData2 = jsonDecode(hourlyData2);
      }
      if (hourlyData2 is! List) {
        hourlyData2 = [hourlyData2];
      }
      this.hourlyData = {};
      for (int i=0; i < hourlyData2.length; i++) {
        final data = hourlyData2[i];
        final hour = (startDatetime as DateTime).add(Duration(hours: i));
        if (data is int) {
          this.hourlyData![hour] = data;
        } else {
          try {
            this.hourlyData![hour] = int.parse(data);
          } catch (e) {
            debugPrint("invalid usage record data '$data'");
            this.hourlyData![hour] = 0;
          }
        }
      }
    }
  }

  double? get totalUsage => hourlyData == null ? null : hourlyData!.values.reduce((value, element) => value + element) * 1.0;
}

class PlugElectricityConsumptionRecord extends PlugUsageRecord {
  PlugElectricityConsumptionRecord({
    Map<DateTime, int>? hourlyData,
    Map? others,
  }) : super(hourlyData: hourlyData, others: others);

  @override
  double? get totalUsage => super.totalUsage == null ? null : super.totalUsage! / 1000.0;
}

/// A Client that services Wyze plugs/outlets.
class PlugsClient extends BaseClient {
  PlugsClient({
    String? token,
    String? baseUrl,
  }) : super(token: token, baseUrl: baseUrl);

  Future<List<Map>> listPlugs() async {
    return (await super.listDevices()).where((device) => DeviceModels.plug.contains(device['product_model'])).toList();
  }

  /// Lists all plugs available to a Wyze account.
  /// :rtype: Sequence[Plug]
  Future<List<Plug>> list() async {
    return (await listPlugs()).map((device) => Plug(others: device['others'], type: device['type'])).toList();
  }

  /// Retrieves details of a plug.
  /// :param str device_mac: The device mac. e.g. ``ABCDEF1234567890``
  /// :rtype: Optional[Plug]
  Future<Plug?> info({required String deviceMac}) async {
    final plugs = (await listPlugs()).where((plug) => plug['mac'] == deviceMac);
    if (plugs.isEmpty) return null;
    
    final plug = plugs.first;
    var response = await super.apiClient().getDevicePropertyList(plug['mac'], plug['product_model'], []);
    final decodedResponse = jsonDecode(response.body) as Map;
    plug.addAll(decodedResponse["data"]);

    response = await super.apiClient().getDeviceTimer(deviceMac, 1);
    final switchStateTimer = jsonDecode(response.body) as Map;
    if (switchStateTimer.containsKey('data') && switchStateTimer['data'] != null) {
      plug.addAll({'switch_state_timer': switchStateTimer['data']});
    }

    return Plug.parse(plug);
  }

  /// Turns off a plug.
  /// :param str device_mac: The device mac. e.g. ``ABCDEF1234567890``
  /// :param str device_model: The device model. e.g. ``WLPP1``
  /// :param Optional[timedelta] after: The delay before performing the action.
  /// :rtype: WyzeResponse
  Future<http.Response> turnOn({required String deviceMac, required String deviceModel, Duration? after}) {
    final propDef = DeviceProps.powerState();

    if (after == null) {
      return super.apiClient().setDeviceProperty(deviceMac, deviceModel, propDef.pid, 1);
    }

    return super.apiClient().setDeviceTimer(deviceMac, after.inSeconds, 1, {'action_type': 1});
  }

  /// Turns on a plug.
  /// :param str device_mac: The device mac. e.g. ``ABCDEF1234567890``
  /// :param str device_model: The device model. e.g. ``WLPP1``
  /// :param Optional[timedelta] after: The delay before performing the action.
  /// :rtype: WyzeResponse
  Future<http.Response> turnOff({required String deviceMac, required String deviceModel, Duration? after}) {
    final propDef = DeviceProps.powerState();

    if (after == null) {
      return super.apiClient().setDeviceProperty(deviceMac, deviceModel, propDef.pid, 0);
    }

    return super.apiClient().setDeviceTimer(deviceMac, after.inSeconds, 0, {'action_type': 1});
  }

  /// Clears any existing power state timer on the plug.
  /// :param str device_mac: The device mac. e.g. ``ABCDEF1234567890``
  Future<http.Response> clearTimer(String deviceMac) {
    return super.apiClient().cancelDeviceTimer(deviceMac, 1);
  }

  /// Sets away/vacation mode for a plug.
  /// :param str device_mac: The device mac. e.g. ``ABCDEF1234567890``
  /// :param str device_model: The device model. e.g. ``WLPP1``
  /// :param bool away_mode: The new away mode. e.g. ``True``
  Future<http.Response> setAwayMode(String deviceMac, String deviceModel, bool awayMode) {
    final propDef = PlugProps.awayMode();

    if (awayMode) {
      return super.apiClient().runAction(deviceMac, "switch_rule", deviceModel, actionParams: {"rule": AwayModeGenerator().value});
    }

    return super.apiClient().setDeviceProperty(deviceMac, deviceModel, propDef.pid, '0');
  }

  /// Gets usage records for a plug.
  /// Note: For outdoor or multi-socket plugs, you must use the parent (combined) device id.
  /// :param str device_mac: The device mac. e.g. ``ABCDEF1234567890``
  /// :param str device_model: The device model. e.g. ``WLPP1``
  /// :param datetime start_time: The ending datetime of the query i.e., the oldest allowed datetime for returned records
  /// :param datetime end_time: The starting datetime of the query i.e., the most recent datetime for returned records. This parameter is optional and defaults to ``None``
  /// :rtype: WyzeResponse
  Future<List<PlugUsageRecord>> getUsageRecords(String deviceMac, String deviceModel, DateTime startTime, [DateTime? endTime]) async {
    endTime ??= DateTime.now();
    final records = await super.apiClient().getPlugUsageRecordList(deviceMac, startTime, endTime);
    final decodedRecords = jsonDecode(records.body) as Map;

    if (decodedRecords.containsKey('data') && decodedRecords['data'].containsKey('usage_record_list')) {
      return decodedRecords["data"]["usage_record_list"].map((record) => DeviceModels.outdoorPlug.contains(deviceModel) ? PlugElectricityConsumptionRecord() : PlugUsageRecord());
    }

    return [];
  }
}
