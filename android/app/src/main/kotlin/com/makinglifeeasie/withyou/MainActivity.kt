package com.makinglifeeasie.withyou

import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NotificationPlatformBridge.configure(
            activity = this,
            flutterEngine = flutterEngine,
        )
        WidgetLaunchPlatformBridge.configure(
            activity = this,
            flutterEngine = flutterEngine,
        )
        NotificationPlatformBridge.handleLaunchIntent(this, intent)
        WidgetLaunchPlatformBridge.handleLaunchIntent(this, intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        NotificationPlatformBridge.handleLaunchIntent(this, intent)
        WidgetLaunchPlatformBridge.handleLaunchIntent(this, intent)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (NotificationPlatformBridge.handlePermissionResult(requestCode, grantResults)) {
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }
}
