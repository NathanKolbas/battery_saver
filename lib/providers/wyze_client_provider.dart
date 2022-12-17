import 'dart:convert';

import 'package:flutter/material.dart';

import '../wyze/api/client.dart';
import '../wyze/service/auth_service.dart';
import '../wyze/wyze_secure_storage.dart';

class WyzeClientProvider with ChangeNotifier {
  /// Singleton
  static final WyzeClientProvider _instance = WyzeClientProvider._internal();
  WyzeClientProvider._internal() {
    // This is init now
  }
  factory WyzeClientProvider() => _instance;

  // Finals
  final WyzeSecureStorage wyzeSecureStorage = WyzeSecureStorage();
  final client = Client();

  // Properties
  late bool _loggedIn;

  // Gets and sets
  bool get loggedIn => _loggedIn;
  set loggedIn(bool val) {
    _loggedIn = val;
    notifyListeners();
  }

  Future<bool> get _signedIn async => await wyzeSecureStorage.isSet();

  /// Call first to setup
  Future<WyzeClientProvider> initialize() async {
    _loggedIn = await _signedIn;

    if (_loggedIn) {
      // Setup tokens on the Wyze client
      final creds = await wyzeSecureStorage.get();
      // These should not be null since we checked if they are stored already in [signedIn]
      assert(creds.accessToken != null);
      assert(creds.refreshToken != null);
      assert(creds.userId != null);

      client.token = creds.accessToken;
      client.refreshToken = creds.refreshToken;
      client.userId = creds.userId;
    }
    return this;
  }

  /// Login to Wyze
  Future<bool> login(String email, String password, Future<String?> Function(TotpCallbackType type)? totpCallback) async {
    final response = await client.login(email, password, totpCallback);
    final decodedResponse = jsonDecode(response.body) as Map;
    final accessToken = decodedResponse['access_token'];
    final refreshToken = decodedResponse['refresh_token'];
    final userId = decodedResponse['user_id'];
    // Some checks for the tokens
    if (accessToken == null || accessToken is! String || accessToken.isEmpty) return false;
    if (refreshToken == null || refreshToken is! String || refreshToken.isEmpty) return false;
    if (userId == null || userId is! String || userId.isEmpty) return false;

    wyzeSecureStorage.set(accessToken: accessToken, refreshToken: refreshToken, userId: userId);

    _loggedIn = true;
    notifyListeners();
    return true;
  }

  /// Logout of Wyze
  logout() async {
    await wyzeSecureStorage.clear();
    client.logout();
    _loggedIn = false;
    notifyListeners();
  }

  Future<bool> refreshToken() async {
    final response = await client.refreshTokenFn();
    final decodedResponse = jsonDecode(response.body) as Map;
    final accessToken = decodedResponse['data']['access_token'];
    final refreshToken = decodedResponse['data']['refresh_token'];
    // Some checks for the tokens
    if (accessToken == null || accessToken is! String || accessToken.isEmpty) return false;
    if (refreshToken == null || refreshToken is! String || refreshToken.isEmpty) return false;

    wyzeSecureStorage.set(accessToken: accessToken, refreshToken: refreshToken);

    return true;
  }

  turnOffPlug(String mac, String model) => client.plugs.turnOff(deviceMac: mac, deviceModel: model);
  turnOnPlug(String mac, String model) => client.plugs.turnOn(deviceMac: mac, deviceModel: model);
}
