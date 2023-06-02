package com.nathan.batter_saver.battery_saver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat


class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            ContextCompat.startForegroundService(
                context,
                Intent(context, ForegroundService::class.java)
            )
        }
    }
}
