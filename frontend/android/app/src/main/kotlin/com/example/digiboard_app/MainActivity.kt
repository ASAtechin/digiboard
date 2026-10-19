package com.example.digiboard_app

import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // A classroom screen never sleeps; the TV's own schedule turns it off at night.
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun onResume() {
        super.onResume()
        // Kiosk mode: when the device management tool allows it, pin the app so
        // nobody can leave it from the remote. Elsewhere this does nothing.
        val policy = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val activities = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val pinned = Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            activities.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
        if (policy.isLockTaskPermitted(packageName) && !pinned) {
            startLockTask()
        }
    }
}
