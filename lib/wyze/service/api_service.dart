import 'dart:math';

import 'package:battery_saver/wyze/service/base.dart';
import 'package:battery_saver/wyze/signature/signature.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Wyze api client is the wrapper on the requests to https://api.wyzecam.com
class ApiServiceClient extends BaseServiceClient {
  static const SC = "a626948714654991afd3c0dbd7cdb901";
  static const wyzeApiUrl = "https://api.wyzecam.com/";
  static const wyzeAppName = "com.hualai";

  String? sc;
  late String appVer;

  ApiServiceClient({
    String? token,
    String? baseUrl = ApiServiceClient.wyzeApiUrl,
    String appName = ApiServiceClient.wyzeAppName,
    this.sc = ApiServiceClient.SC,
  }) : super(token: token, baseUrl: baseUrl, appName: appName, requestVerifier: RequestVerifier(signingSecret: null)) {
    appVer = "${appName}___$appVersion";
  }

  @override
  Map<String, String> getHeaders({Map? headers, String? signature, String? signature2, bool hasJson = false, Map<String, String>? requestSpecificHeaders}) {
    return super.getHeaders(headers: null, hasJson: true, requestSpecificHeaders: requestSpecificHeaders);
  }

  @override
  Future<http.Response> apiCall({
    required String apiEndpoint,
    String httpVerb = "POST",
    Map? data,
    Map? params,
    Map? json,
    Map<String, String>? headers,
    Map? auth,
  }) {
    json ??= {};
    json['access_token'] = token;
    json['app_name'] = appName;
    json['app_ver'] = appVer;
    json['app_version'] = appVersion;
    json['phone_id'] = phoneId;
    json['phone_system_type'] = phoneType.toString();
    json['sc'] = sc;
    json['ts'] = requestVerifier!.clock.nonce();

    headers = getHeaders(
      requestSpecificHeaders: {
        'Connection': 'keep-alive',
      }
    );

    return super.apiCall(apiEndpoint: apiEndpoint, httpVerb: httpVerb, data: null, params: null, json: json, headers: headers, auth: null);
  }

  Future<http.Response> refreshToken({required String refreshToken, Map? args}) {
    args ??= {};
    const svRefreshToken = 'd91914dd28b7492ab9dd17f7707d35a3';

    args.addAll({"refresh_token": refreshToken, "sv": svRefreshToken});
    return apiCall(apiEndpoint: '/app/user/refresh_token', json: args);
  }

  Future<http.Response> setDeviceProperty(String mac, String model, String pid, dynamic value, [Map? args]) {
    args ??= {};
    const svSetDeviceProperty = '44b6d5640c4d4978baba65c8ab9a6d6e';

    args.addAll({"device_mac": mac, "device_model": model, "pid": pid, "pvalue": value.toString(), "sv": svSetDeviceProperty});
    return apiCall(apiEndpoint: '/app/v2/device/set_property', json: args);
  }

  /// props = DeviceProp, List[DeviceProp]
  Future<http.Response> setDevicePropertyList(String mac, String model, dynamic props, Map? args) {
    args ??= {};
    const svSetDevicePropertyList = 'a8290b86080a481982b97045b8710611';

    args.addAll({
      "device_mac": mac,
      "device_model": model,
      "property_list": [],
      "sv": svSetDevicePropertyList
    });

    if (props is! Iterable) props = [props];
    for (final prop in props) {
      args["property_list"].add({
        "pid": prop.definition.pid,
        "pvalue": prop.apiValue,
      });
    }

    return apiCall(apiEndpoint: '/app/v2/device/set_property_list', json: args);
  }

  Future<http.Response> getDeviceListPropertyList(List<String> deviceIds, List<String> targetPids, Map? args) {
    args ??= {};
    const svGetDeviceListPropertyList = 'be9e90755d3445d0a4a583c8314972b6';

    args.addAll({"device_list": deviceIds, "target_pid_list": targetPids, "sv": svGetDeviceListPropertyList});
    return apiCall(apiEndpoint: '/app/v2/device_list/get_property_list', json: args);
  }

  Future<http.Response> getDevicePropertyList(String mac, String model, List<String>? targetPids, [Map? args]) {
    args ??= {};
    const svGetDevicePropertyList = '1df2807c63254e16a06213323fe8dec8';

    args.addAll({"device_mac": mac, "device_model": model, "sv": svGetDevicePropertyList});
    if (targetPids != null) args.addAll({"target_pid_list": targetPids});

    return apiCall(apiEndpoint: '/app/v2/device/get_property_list', json: args);
  }

  Future<http.Response> getV1DeviceInfo(String mac, Map? args) {
    args ??= {};
    const svGetDeviceInfo = '90fea740c4c045f9a3084c17cee71d46';

    args.addAll({"device_mac": mac, "sv": svGetDeviceInfo});
    return apiCall(apiEndpoint: '/app/device/get_device_info', json: args);
  }

  Future<http.Response> getUserInfo(Map? args) {
    args ??= {};
    const svGetUserInfo = '6e054e04b7144c90af3b1281b6533492';

    args.addAll({"sv": svGetUserInfo});
    return apiCall(apiEndpoint: '/app/user/get_user_info', json: args);
  }

  Future<http.Response> logout(Map? args) {
    args ??= {};
    const svLogout = '759245b61abd49128585e95f30e61add';

    args.addAll({"sv": svLogout});
    return apiCall(apiEndpoint: '/app/user/logout', json: args);
  }

  Future<http.Response> getDeviceInfo(String mac, String model, Map? args) {
    args ??= {};
    const svGetDeviceInfo = '81d1abc794ba45a39fdd21233d621e84';

    args.addAll({"device_mac": mac, "device_model": model, "sv": svGetDeviceInfo});
    return apiCall(apiEndpoint: '/app/v2/device/get_device_Info', json: args);
  }

  Future<http.Response> getObjectList([Map? args]) {
    args ??= {};
    const svGetDeviceList = 'c417b62d72ee44bf933054bdca183e77';

    args.addAll({"sv": svGetDeviceList});
    return apiCall(apiEndpoint: '/app/v2/home_page/get_object_list', json: args);
  }

  /// "data": {
  ///     "action_value": "1",
  ///     "delay_time": 10800,
  ///     "plan_execute_ts": 1618169169544
  /// },
  Future<http.Response> getDeviceTimer(String mac, int actionType, [Map? args]) {
    args ??= {};
    const svGetDeviceTimer = 'ddd49252f61944dc9c46d1a770a5980f';

    args.addAll({"device_mac": mac, "action_type": actionType, "sv": svGetDeviceTimer});
    return apiCall(apiEndpoint: '/app/v2/device/timer/get', json: args);
  }

  /// action_value: 0=off, 1=on
  /// See: com.HLApi.CloudAPI.CloudProtocol.deviceTimerSet
  Future<http.Response> setDeviceTimer(String mac, int delayTime, int actionValue, Map? args) {
    args ??= {};
    const svSetDeviceTimer = '1b3e8bfc7f654e1eaddf8db22090034f';

    args.addAll({
      "device_mac": mac,
      "action_type": 1,
      "action_value": actionValue,
      "delay_time": delayTime,
      "plan_execute_ts": DateTime.now().add(Duration(seconds: delayTime)).millisecondsSinceEpoch,
      "sv": svSetDeviceTimer,
    });
    return apiCall(apiEndpoint: '/app/v2/device/timer/set', json: args);
  }

  /// "data": {
  ///    "action_value": "1",
  ///    "delay_time": 10800,
  ///    "plan_execute_ts": 1618169169544
  /// },
  Future<http.Response> setDeviceGroupTimer(int id, int actionType, Map? args) {
    args ??= {};
    const svGetDeviceGroupTImer = 'bf55bbf1db0e4fa18cc7a13022de33a3';

    args.addAll({"group_id": id.toString(), "action_type": actionType, "sv": svGetDeviceGroupTImer});
    return apiCall(apiEndpoint: '/app/v2/device_group/timer/get', json: args);
  }

  Future<http.Response> cancelDeviceTimer(String mac, int actionType, [Map? args]) {
    args ??= {};
    const svCancelDeviceTImer = '8670b7ddb88845468b77ef4d383bfd59';

    args.addAll({"device_mac": mac, "action_type": actionType, "sv": svCancelDeviceTImer});
    return apiCall(apiEndpoint: '/app/v2/device/timer/cancel', json: args);
  }

  Future<http.Response> getPlugUsageRecordList(String mac, DateTime startTime, DateTime endTime, [Map? args]) {
    args ??= {};
    const svGetPlugUsageRecordList = '17eff072fba0469a800502cab514412e';

    args.addAll({
      "device_mac": mac,
      "date_begin": startTime.millisecondsSinceEpoch,
      "date_end": endTime.millisecondsSinceEpoch,
      "sv": svGetPlugUsageRecordList,
    });
    return apiCall(apiEndpoint: '/app/v2/plug/usage_record_list', json: args);
  }

  getSmokeEventList(List<String>? deviceIds, DateTime? begin, DateTime? end, int? limit, int? orderBy, Map? args) {
    deviceIds ??= [];
    limit ??= 20;
    orderBy ??= 2;
    args ??= {};

    // TODO
    throw Exception('Not yet implemented');
  }

  getSoundEventList(List<String>? deviceIds, DateTime? begin, DateTime? end, int? limit, int? orderBy, Map? args) {
    deviceIds ??= [];
    limit ??= 20;
    orderBy ??= 2;
    args ??= {};

    // TODO
    throw Exception('Not yet implemented');
  }

  getCoEventList(List<String>? deviceIds, DateTime? begin, DateTime? end, int? limit, int? orderBy, Map? args) {
    deviceIds ??= [];
    limit ??= 20;
    orderBy ??= 2;
    args ??= {};

    // TODO
    throw Exception('Not yet implemented');
  }

  getMotionEventList(List<String>? deviceIds, DateTime? begin, DateTime? end, int? limit, int? orderBy, Map? args) {
    deviceIds ??= [];
    limit ??= 20;
    orderBy ??= 2;
    args ??= {};

    // TODO
    throw Exception('Not yet implemented');
  }

  // TODO
  // Future<http.Response> getEventList(String mac, DateTime startTime, DateTime endTime, Map? args) {
  //   args ??= {};
  //   const svGetPlugUsageRecordList = '17eff072fba0469a800502cab514412e';
  //
  //   args.addAll({
  //     "device_mac": mac,
  //     "date_begin": startTime.millisecondsSinceEpoch,
  //     "date_end": endTime.millisecondsSinceEpoch,
  //     "sv": svGetPlugUsageRecordList,
  //   });
  //   return apiCall(apiEndpoint: '/app/v2/plug/usage_record_list', json: args);
  // }

  /// TODO: Not sure if I got this translation right
  Future<http.Response> setReadStateList(Map<String, List<dynamic>> events, bool? readState, Map? args) {
    readState ??= true;
    args ??= {};
    const svSetReadStateList = '1e9a7d77786f4751b490277dc3cfa7b5';

    args.addAll({
      "event_list": events.entries.map((e) => {
        "device_mac": e.key,
        "event_id_list": e.value.map((e) => e.id),
        "event_type": 1
      }).toList(),
      "read_state": readState ? 1 : 0,
      "sv": svSetReadStateList,
    });
    return apiCall(apiEndpoint: '/app/v2/device_event/set_read_state_list', json: args);
  }

  Future<http.Response> runAction(String mac, String actionKey, String providerKey, {Map? actionParams, String? customString, Map? args}) {
    actionParams ??= {};
    args ??= {};
    const svRunAction = '011a6b42d80a4f32b4cc24bb721c9c96';

    args.addAll({
      "instance_id": mac,
      "action_key": actionKey,
      "provider_key": providerKey,
      "sv": svRunAction
    });
    args.addAll({"action_params": actionParams});
    if (customString != null) args.addAll({"custom_string": customString});
    return apiCall(apiEndpoint: '/app/v2/auto/run_action', json: args);
  }

  Future<http.Response> runActionList(dynamic actions, String? customString, Map? args) {
    args ??= {};
    const svRunActionList = '5e02224ae0c64d328154737602d28833';

    args.addAll({
      "action_list": [],
      "sv": svRunActionList
    });
    if (actions is! List) actions = [actions];
    for (final action in actions) {
      final newAction = {
        "action_key": action["key"],
        "action_params": {
          "list": [
            {
              "mac": action["device_mac"],
              "plist": []
            }
          ]
        },
        "instance_id": action["device_mac"],
        "provider_key": action["provider_key"],
      };
      if (action.containsKey('prop')) {
        if (action['prop'] is! List) action['prop'] = [action['prop']];
        for (final prop in action['prop']) {
          newAction["action_params"]["list"][0]["plist"].add({
            "pid": prop.definition.pid,
            "pvalue": prop.apiValue.toString(),
          });
        }
      }
      args["action_list"].add(newAction);
    }

    if (customString != null) args.addAll({"custom_string": customString});
    return apiCall(apiEndpoint: '/app/v2/auto/run_action_list', json: args);
  }
}

class AwayModeGenerator {
  double? cursorTime;
  double? remainTime;

  List<String> get value {
    final List<double> values = [];

    final localAmStart = DateTime(1970, 1, 1, 6, 0, 0);
    final localAmEnd = DateTime(1970, 1, 1, 9, 0, 0);
    final localPmStart = DateTime(1970, 1, 1, 18, 0, 0);
    final localPmEnd = DateTime(1970, 1, 1, 23, 0, 0);

    _calculateAwayMode(values, localAmStart, localAmEnd);
    _removeUnreasonableData(values, localAmEnd);
    _calculateAwayMode(values, localPmStart, localPmEnd);
    _removeUnreasonableData(values, localPmEnd);

    final List<String> valueList = [];
    var i2 = 1;
    for (final value in values) {
      final datetime = DateTime.fromMillisecondsSinceEpoch((value * 1000).round()).toUtc();
      valueList.add("${datetime.hour.toString().padLeft(2, '0')}${datetime.minute.toString().padLeft(2, '0')}$i2");
      i2 ^= 1;  // adds the on/off bit
    }

    debugPrint("value returning=$valueList");
    return valueList;
  }

  /// See: com.hualai.wlpp1.u2.b
  List<double> _calculateAwayMode(List<double> arrayList, DateTime localStart, DateTime localEnd) {
    final gmtStartTime = localStart.millisecondsSinceEpoch / 1000;
    final gmtEndTime = localEnd.millisecondsSinceEpoch / 1000;
    remainTime = gmtEndTime - gmtStartTime;
    cursorTime = gmtStartTime;
    var z = false;
    while (true) {
      if (z) {
        arrayList.add(_randomize(3600, 60, gmtEndTime));
        z = !z;
      } else if (remainTime! <= 900) {
        return arrayList;
      } else {
        arrayList.add(_randomize(3600, 60, gmtEndTime));
        z = !z;
      }
    }
  }

  _removeUnreasonableData(List<double>? arrayList, DateTime localEnd) {
    if (arrayList != null && arrayList.length >= 2) {
      final lastData = arrayList.last + _localTimezoneInSeconds;
      debugPrint("remove_unreasonable_data last_data=$lastData local_end=$localEnd");
      if (lastData > localEnd.millisecondsSinceEpoch / 1000) {
        debugPrint("remove_unreasonable_data item ${arrayList.last}");
        arrayList.removeLast();
        arrayList.removeLast();
      }
    }
  }

  int get _localTimezoneInSeconds => DateTime.now().timeZoneOffset.inSeconds;

  double _randomize(double secondsPerHour, double secondsPerMinute, double endTime) {
    debugPrint("_randomize remain_time=$remainTime");
    debugPrint("_randomize cursor_time=$cursorTime");
    final minutesRemaining = (remainTime! - secondsPerHour) >= 0 ? 60.0 : (remainTime! % secondsPerHour) / secondsPerMinute;
    debugPrint("_randomize minutes_remaining=$minutesRemaining");
    final random = cursorTime! + (((Random().nextDouble() * (minutesRemaining - 5)) + 5.0) * secondsPerMinute);
    cursorTime = random;
    remainTime = endTime - (random + secondsPerMinute);
    return cursorTime!;
  }
}
