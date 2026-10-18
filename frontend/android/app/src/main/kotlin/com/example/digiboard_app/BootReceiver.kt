package com.example.digiboard_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Opens DigiBoard when the box starts, for boxes where it is not the home
 * screen. Android 10 and later only allow this for apps given "Display over
 * other apps" or managed as a kiosk; see KIOSK_SETUP.md.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        val launch = Intent(context, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            context.startActivity(launch)
        } catch (e: Exception) {
            // Not allowed on this box: the home-screen setting or the kiosk tool starts the app instead.
        }
    }
}
