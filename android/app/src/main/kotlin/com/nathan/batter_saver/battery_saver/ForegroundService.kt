package com.nathan.batter_saver.battery_saver

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import java.text.DecimalFormat
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.roundToInt


class ForegroundService : Service() {
    private var isRunning = AtomicBoolean(false)

    private val notificationChannelName: String = "Batter Info Listener"
    private val notificationChannelDescription: String = "This channel is used to listen for battery changes"
    private val notificationChannelId: String = "foreground_battery_service"
    private val notificationId: Int = 1
    private val notificationIcon: Int = R.drawable.ic_baseline_energy_savings_leaf_24

    private var notificationTitle: String = DEFAULT_NOTIFICATION_TITLE
    private var notificationContent: String? = null

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onUnbind(intent: Intent): Boolean {
        return super.onUnbind(intent)
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        notificationContent = "Initializing..."
        updateNotificationInfo()

        val intentFilter = IntentFilter()
        intentFilter.addAction(Intent.ACTION_BATTERY_CHANGED)
        registerReceiver(broadcastReceiver, intentFilter)
    }

    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            stopForeground(true)
        }
        unregisterReceiver(broadcastReceiver)
        isRunning.set(false)
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(notificationChannelId, notificationChannelName, importance)
            channel.description = notificationChannelDescription
            channel.enableVibration(false)
            channel.setSound(null, null)
            channel.enableLights(false)
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun updateNotificationInfo() {
        val packageName = applicationContext.packageName
        val i = packageManager.getLaunchIntentForPackage(packageName)
        var flags = PendingIntent.FLAG_CANCEL_CURRENT
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            flags = flags or PendingIntent.FLAG_MUTABLE
        }
        val pi = PendingIntent.getActivity(this@ForegroundService, 11, i, flags)
        val mBuilder: NotificationCompat.Builder = NotificationCompat.Builder(this, notificationChannelId)
            .setSmallIcon(notificationIcon)
            .setAutoCancel(true)
            .setOngoing(true)
            .setContentTitle(notificationTitle)
            .setContentText(notificationContent)
            .setContentIntent(pi)
        startForeground(notificationId, mBuilder.build())
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        runService()
        return START_STICKY
    }

    private fun runService() {
        try {
            updateNotificationInfo()

            isRunning.set(true)
        } catch (e: UnsatisfiedLinkError) {
            notificationContent = "Error " + e.message
            updateNotificationInfo()
            Log.w(
                TAG,
                "UnsatisfiedLinkError: After a reboot this may happen for a short period and it is ok to ignore then!" + e.message
            )
        }
    }

    private var broadcastReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == Intent.ACTION_BATTERY_CHANGED) {
                try {
                    // https://developer.android.com/reference/android/os/BatteryManager
                    val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
                    val batteryLevel = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, 0)
                    val batteryTemperature = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1)
                    val voltage = intent.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)
                    val currentNow = batteryManager.getLongProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
                    val avgCurrent = batteryManager.getLongProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_AVERAGE)
                    val batteryLow = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        intent.getBooleanExtra(BatteryManager.EXTRA_BATTERY_LOW, false)
                    } else {
                        false
                    }
                    val iconSmall = intent.getIntExtra(BatteryManager.EXTRA_ICON_SMALL, -1)
                    val batteryPresent = intent.getBooleanExtra(BatteryManager.EXTRA_PRESENT, true)
                    val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
                    val batteryStatus = when (status) {
                        BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
                        BatteryManager.BATTERY_STATUS_DISCHARGING -> "Discharging"
                        BatteryManager.BATTERY_STATUS_FULL -> "Full"
                        BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "Not Charging"
                        BatteryManager.BATTERY_STATUS_UNKNOWN -> "Unknown"
                        else -> "Unknown"
                    }
                    val chargePlug = when (intent.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1)) {
                        BatteryManager.BATTERY_PLUGGED_AC -> "AC"
                        BatteryManager.BATTERY_PLUGGED_USB -> "USB"
                        BatteryManager.BATTERY_PLUGGED_DOCK -> "Dock"
                        BatteryManager.BATTERY_PLUGGED_WIRELESS -> "Wireless"
                        else -> "None"
                    }
                    val batteryHealth = when (intent.getIntExtra(BatteryManager.EXTRA_HEALTH, -1)) {
                        BatteryManager.BATTERY_HEALTH_COLD -> "Cold"
                        BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
                        BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
                        BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
                        BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Overvoltage"
                        BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "Unspecified Failure"
                        BatteryManager.BATTERY_HEALTH_UNKNOWN -> "Unknown"
                        else -> "Unknown"
                    }

                    Log.d(TAG, "$batteryLevel | $batteryTemperature | $voltage | $batteryStatus | $batteryStatus | $chargePlug | $batteryHealth")

                    // Update the notification
                    notificationTitle = DEFAULT_NOTIFICATION_TITLE
                    notificationContent = "${batteryLevel}% • ${microAmpsString(currentNow)} • ${batteryTemperature / 10}°C • ${String.format("%.2f", voltage / 1000f)}V"
                    if (status == BatteryManager.BATTERY_STATUS_CHARGING) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                            val chargeTimeRemaining = batteryManager.computeChargeTimeRemaining()
                            notificationTitle = "$DEFAULT_NOTIFICATION_TITLE • ${chargeTimeRemainingString(chargeTimeRemaining)} to full"
                        }
                        notificationContent = "Charging $notificationContent"
                    }
                    updateNotificationInfo()

                    // Send data back to Dart to handle Wyze

                } catch (e: Exception) {
                    Log.d(TAG, "Battery Info Error")
                }
            }
        }
    }

    override fun onTaskRemoved(rootIntent: Intent) {}

    companion object {
        private const val TAG = "ForegroundService"
        private const val DEFAULT_NOTIFICATION_TITLE = "Battery Saver"

        fun microAmpsString(microAmps: Long): String {
            val milliAmps = (microAmps / 1000f).roundToInt()
            if (milliAmps < 1000) return "$milliAmps mA";

            val amps = (milliAmps / 1000f).roundToInt()
            return "$amps A";
        }

        fun chargeTimeRemainingString(timeRemaining: Long): String {
            val minutes = timeRemaining / 1000 / 60
            val hours = minutes / 60
            return "${hours}h ${minutes}m"
        }
    }
}
