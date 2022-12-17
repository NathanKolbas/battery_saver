import 'package:flutter/material.dart';

import '../hive/preferences/charging_preferences.dart';

class ChargingProvider with ChangeNotifier {
  /// Singleton
  static final ChargingProvider _instance = ChargingProvider._internal();
  ChargingProvider._internal() {
    // This is init now
  }
  factory ChargingProvider() => _instance;

  final ChargingPreferences chargingPreferences = ChargingPreferences.load();

  save() {
    chargingPreferences.save();
    notifyListeners();
  }
}
