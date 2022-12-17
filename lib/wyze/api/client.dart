import 'dart:convert';

import 'package:battery_saver/extensions/iterable_extensions.dart';
import 'package:battery_saver/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../errors/wyze_errors.dart';
import '../models/devices/base.dart';
import '../models/devices/devices.dart';
import '../service/api_service.dart';
import '../service/auth_service.dart';
import 'devices/plugs.dart';

class Client {
  /// A string used for API-based requests
  String? token;
  /// A string that can be used to rotate the authentication token
  String? refreshToken;
  /// A string specifying the account email address.
  String? email;
  /// An unencrypted string specifying the account password.
  String? password;
  /// An unencrypted string specifying the TOTP Key for automatic TOTP 2FA verification code generation.
  String? totpKey;
  /// An optional string representing the API base URL. **This should not be used except for when running tests.**
  String? baseUrl;
  /// The maximum number of seconds the client will wait to connect and receive a response from Wyze. Defaults to 30
  late int timeout;
  String? userId;

  PlugsClient get plugs => PlugsClient(token: token, baseUrl: baseUrl);

  Client({
    this.token,
    this.refreshToken,
    this.email,
    this.password,
    this.totpKey,
    this.baseUrl,
    this.timeout = 30,
  }) {
    token = token?.trim();
    refreshToken = refreshToken?.trim();
    email = email?.trim();
    password = password?.trim();
    totpKey = totpKey?.trim();

    if (token.isNullEmpty && email.isNotNullEmpty) {
      login(email, password, null, totpKey);
    }
  }

  /// Exchanges email and password for an ``access_token`` and a ``refresh_token``, which
  /// are stored in this client. The tokens will be used for all subsequent requests
  /// made by this ``Client`` unless ``refresh_token()`` is called.
  /// :rtype: WyzeResponse
  /// :raises WyzeClientConfigurationError: If ``access_token`` is already set or both ``email`` and ``password`` are not set.
  Client.login(String this.email, String this.password, [this.totpKey]) {
    login(email, password, null, totpKey);
  }

  AuthServiceClient _authClient() => baseUrl != null ? AuthServiceClient(token: token, baseUrl: baseUrl) : AuthServiceClient(token: token);

  ApiServiceClient _apiClient() => baseUrl != null ? ApiServiceClient(token: token, baseUrl: baseUrl) : ApiServiceClient(token: token);

  _updateSession({required String accessToken, required String refreshToken, String? userId,}) {
    debugPrint('refreshing session data');
    token = accessToken;
    this.refreshToken = refreshToken;
    if (userId != null) {
      this.userId = userId;
      debugPrint("wyze user : ${this.userId}");
    }
  }

  Future<http.Response> login(String? email, String? password, [Future<String?> Function(TotpCallbackType type)? totpCallback, String? totpKey]) async {
    if (token.isNotNullEmpty) {
      throw const WyzeClientConfigurationError("already logged in");
    }

    // if an email/password is provided, use them. Otherwise, use the ones
    // provided when constructing the client.
    if (email != null) this.email = email.trim();
    if (password != null) this.password = password.trim();
    if (totpKey != null) this.totpKey = totpKey.trim();

    if (this.email.isNullEmpty || this.password.isNullEmpty) {
      throw const WyzeClientConfigurationError("must provide email and password");
    }
    debugPrint('access token not provided, attempting to login as ${this.email}');
    final response = await _authClient().userLogin(email: this.email!, password: this.password!, totpKey: this.totpKey, totpCallback: totpCallback);
    final decodedResponse = jsonDecode(response.body) as Map;
    _updateSession(accessToken: decodedResponse["access_token"], refreshToken: decodedResponse["refresh_token"], userId: decodedResponse["user_id"]);
    return response;
  }

  logout() {
    token = null;
    refreshToken = null;
    email = null;
    password = null;
    totpKey = null;
    baseUrl = null;
  }

  /// Updates ``access_token`` using the previously set ``refresh_token``.
  /// :rtype: WyzeResponse
  /// :raises WyzeClientConfigurationError: If ``refresh_token`` is not already set.
  Future<http.Response> refreshTokenFn() async {
    if (refreshToken == null) throw const WyzeClientConfigurationError("client is not logged in");

    final response = await _apiClient().refreshToken(refreshToken: refreshToken!);
    final decodedResponse = jsonDecode(response.body) as Map;

    _updateSession(accessToken: decodedResponse["data"]["access_token"], refreshToken: decodedResponse["data"]["refresh_token"]);
    return response;
  }

  /// List the devices available to the current user
  /// :rtype: Sequence[Device]
  Future<List<Device>> devicesList() async {
    final response = await _apiClient().getObjectList();
    final decodedResponse = jsonDecode(response.body) as Map;
    return (decodedResponse["data"]["device_list"] as List<dynamic>).mapSkipNull<Device>((device) => DeviceParser.parse(device)).toList();
  }
}
