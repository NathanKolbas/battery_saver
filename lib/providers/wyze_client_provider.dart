import 'dart:convert';

import 'package:flutter/foundation.dart';

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
  Future<bool> login(String email, String password, String keyId, String apiKey, Future<String?> Function(TotpCallbackType type)? totpCallback) async {
    final response = await client.login(email, password, keyId, apiKey, totpCallback);
    if (kDebugMode) print(response);

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
    if (response == null) return false;

    final decodedResponse = jsonDecode(response.body) as Map;
    final accessToken = decodedResponse['data']['access_token'];
    final refreshToken = decodedResponse['data']['refresh_token'];
    // Some checks for the tokens
    if (accessToken == null || accessToken is! String || accessToken.isEmpty) return false;
    if (refreshToken == null || refreshToken is! String || refreshToken.isEmpty) return false;

    wyzeSecureStorage.set(accessToken: accessToken, refreshToken: refreshToken, refreshTokenDate: DateTime.now().toIso8601String());

    return true;
  }

  Future<bool> refreshTokenIfExpired() async {
    final creds = await wyzeSecureStorage.get();
    final refreshedOnDateString = creds.refreshTokenDate;
    final refreshedOnDate = refreshedOnDateString != null ? DateTime.parse(refreshedOnDateString) : DateTime(0);
    final now = DateTime.now();

    if (now.difference(refreshedOnDate) > const Duration(days: 1)) {
      refreshToken();
      return true;
    }

    return false;
  }

  turnOffPlug(String mac, String model) => client.plugs.turnOff(deviceMac: mac, deviceModel: model);
  turnOnPlug(String mac, String model) => client.plugs.turnOn(deviceMac: mac, deviceModel: model);
}
