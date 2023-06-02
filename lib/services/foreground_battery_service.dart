import 'dart:async';
import 'dart:ui';

import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../hive/hive_helper.dart';
import '../hive/preferences/charging_preferences.dart';
import '../providers/charging_provider.dart';
import '../providers/wyze_client_provider.dart';

const notificationTitle = 'Battery Saver';
const notificationChannelName = 'Batter Info Listener';
const notificationChannelId = 'foreground_battery_service';
const foregroundServiceNotificationId = 1;
const notificationIcon = 'ic_bg_service_small';

const turnOnActionId = 'turn_on';
const turnOffActionId = 'turn_off';

final service = FlutterBackgroundService();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const notChargingTimerSeconds = 10;
Timer? notChargingTimer;

String microAmpsString(int microAmps) {
  final milliAmps = (microAmps / 1000).round();
  if (milliAmps < 1000) return "$milliAmps mA";

  final amps = (milliAmps / 1000).round();
  return "$amps A";
}

String chargeTimeRemainingString(int timeRemaining) {
  final minutes = timeRemaining / 1000 / 60;
  final hours = minutes / 60;
  return "${hours.round()}h ${minutes.round()}m";
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    print('stopService');
    service.stopSelf();
  });

  /// Check if the service should be running
  try {
    await setupHive();
  } catch (e) {
    // TODO: fix
  }
  final ChargingPreferences chargingPreferences = ChargingPreferences.load();
  if (chargingPreferences.chargeOff) service.stopSelf();

  BatteryInfoPlugin().androidBatteryInfoStream.listen((AndroidBatteryInfo? batteryInfo) async {
    if (batteryInfo == null) return;

    if (service is! AndroidServiceInstance) return;

    try {
      await setupHive();
    } catch (e) {
      // TODO: fix
    }
    final wyzeClientProvider = await WyzeClientProvider().initialize();
    final ChargingPreferences chargingPreferences = await ChargingPreferences.loadReopen();

    // Check if the service should be running
    if (chargingPreferences.chargeOff) {
      service.stopSelf();
      return;
    }

    notChargingTimer?.cancel();
    String title = notificationTitle;
    String body = '';
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        notificationChannelName,
        icon: notificationIcon,
        ongoing: true,
        playSound: false,
        enableLights: false,
        enableVibration: false,
        actions: [
          AndroidNotificationAction(
            turnOnActionId,
            'On',
          ),
          AndroidNotificationAction(
            turnOffActionId,
            'Off',
          ),
        ],
      ),
    );

    if (batteryInfo.chargingStatus == ChargingStatus.Charging) {
      /// Handle the charger
      if ((batteryInfo.batteryLevel?.toInt() ?? 0) >= chargingPreferences.chargePercentage) {
        // Turn off all the plugs since we reached the charge
        for (final device in chargingPreferences.selectedDevices) {
          wyzeClientProvider.turnOffPlug(device.mac, device.model);
        }
      }

      /// Notification
      final chargeTimeRemaining = batteryInfo.chargeTimeRemaining;
      if (chargeTimeRemaining != null && chargeTimeRemaining != -1) {
        title = "$notificationTitle (${chargeTimeRemainingString(chargeTimeRemaining)} to full)";
      }
      final currentNow = microAmpsString(batteryInfo.currentNow ?? 0);
      body = "Charging ${batteryInfo.batteryLevel}% • $currentNow • ${batteryInfo.temperature}°C • ${((batteryInfo.voltage ?? 0) / 1000).toStringAsFixed(2)}V";
    } else {
      /// Handle charger
      if ((batteryInfo.batteryLevel?.toInt() ?? 0) <= chargingPreferences.chargePercentageTurnOn) {
        // Turn on all the plugs since we reached to min charge
        for (final device in chargingPreferences.selectedDevices) {
          wyzeClientProvider.turnOnPlug(device.mac, device.model);
        }
      }

      /// Notification
      chargingFunction([_]) async {
        final newBatteryInfo = (await BatteryInfoPlugin().androidBatteryInfo);
        if (newBatteryInfo == null) return;

        final currentNow = microAmpsString(newBatteryInfo.currentNow ?? 0);
        body = "${newBatteryInfo.batteryLevel}% • $currentNow • ${newBatteryInfo.temperature}°C • ${((newBatteryInfo.voltage ?? 0) / 1000).toStringAsFixed(2)}V";
        flutterLocalNotificationsPlugin.show(
          foregroundServiceNotificationId,
          title,
          body,
          notificationDetails,
        );
      }
      // Need to call it right away to update notification content for the first time
      chargingFunction();
      notChargingTimer = Timer.periodic(const Duration(seconds: notChargingTimerSeconds), chargingFunction);
    }

    flutterLocalNotificationsPlugin.show(
      foregroundServiceNotificationId,
      title,
      body,
      notificationDetails,
    );
  });
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  try {
    await setupHive();
  } catch (e) {
    // TODO: fix
  }
  final wyzeClientProvider = await WyzeClientProvider().initialize();
  final ChargingPreferences chargingPreferences = ChargingPreferences.load();

  // Remember to add `@pragma('vm:entry-point')` to the functions
  switch (response.notificationResponseType) {
    case NotificationResponseType.selectedNotification:
    // Handle notification tap
      print('Hey, you tapped');
      break;
    case NotificationResponseType.selectedNotificationAction:
      if (response.actionId == turnOnActionId) {
        // handle on
        print('On');
        for (final device in chargingPreferences.selectedDevices) {
          wyzeClientProvider.turnOnPlug(device.mac, device.model);
        }
      } else if (response.actionId == turnOffActionId) {
        // Handle off
        print('Off');
        for (final device in chargingPreferences.selectedDevices) {
          wyzeClientProvider.turnOffPlug(device.mac, device.model);
        }
      }
      break;
  }
}

Future<void> initializeBatteryService() async {
  if (await service.isRunning()) return;

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    notificationChannelName,
    description: 'This channel is used to listen for battery changes.',
    importance: Importance.low,
    enableVibration: false,
    playSound: false,
    enableLights: false,
  );

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings(notificationIcon);
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Remember to add `@pragma('vm:entry-point')` to the functions
      switch (response.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          // Handle notification tap
        print('Hey, you tapped');
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (response.actionId == turnOnActionId) {
            // handle on
            print('On');
          } else if (response.actionId == turnOffActionId) {
            // Handle off
            print('Off');
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      autoStartOnBoot: true,

      notificationChannelId: notificationChannelId,
      initialNotificationTitle: notificationTitle,
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: foregroundServiceNotificationId,
    ),
    // Not yet supported
    iosConfiguration: IosConfiguration(autoStart: false),
  );
}

startBatteryService() async {
  if ((await service.isRunning())) return;
  final off = ChargingProvider().chargingPreferences.chargeOff;
  if (!off) service.startService();
}

stopBatteryService() async {
  service.invoke('stopService');
}
