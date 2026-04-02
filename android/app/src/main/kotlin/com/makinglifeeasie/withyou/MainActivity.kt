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
        NotificationPlatformBridge.handleLaunchIntent(this, intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        NotificationPlatformBridge.handleLaunchIntent(this, intent)
    }
}
