package com.nathan.batter_saver.battery_saver

import FBatteryChangedPigeon
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.startActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine


class MainActivity: FlutterActivity() {
    override fun onStart() {
        super.onStart()
        ContextCompat.startForegroundService(
            context,
            Intent(context, ForegroundService::class.java)
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val api = FBatteryChangedPigeonImplementation(context)
        FBatteryChangedPigeon.setUp(flutterEngine.dartExecutor.binaryMessenger, api)
    }
}

private class FBatteryChangedPigeonImplementation(val context: Context): FBatteryChangedPigeon {
    override fun openPersistentNotificationSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.apply {
                val settingsIntent: Intent = Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    .putExtra(Settings.EXTRA_CHANNEL_ID, ForegroundService.NOTIFICATION_CHANNEL_ID)
                startActivity(settingsIntent)
            }
        }
    }
}
