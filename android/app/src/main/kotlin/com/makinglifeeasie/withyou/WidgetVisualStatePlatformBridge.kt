package com.makinglifeeasie.withyou

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

private const val widgetVisualStateChannelName = "with_you/widget_visual_state/methods"
private const val widgetVisualPrefsName = "with_you_widget_visual_state"
private const val widgetVisualPremiumActiveKey = "premium_active"

object WidgetVisualStatePlatformBridge : MethodChannel.MethodCallHandler {
    private var applicationContext: Context? = null

    fun configure(context: Context, flutterEngine: FlutterEngine) {
        applicationContext = context.applicationContext
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            widgetVisualStateChannelName,
        ).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "syncPremiumAccess" -> {
                val isActive = call.argument<Boolean>("isActive")
                if (isActive == null) {
                    result.error("bad_args", "Missing isActive premium flag", null)
                    return
                }

                val context = applicationContext
                if (context == null) {
                    result.error("unavailable", "Widget visual state bridge not configured", null)
                    return
                }

                setPremiumActive(context, isActive)
                HomeLaunchWidgetProvider.updateAllWidgets(context)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    fun isPremiumActive(context: Context): Boolean {
        val prefs = context.getSharedPreferences(widgetVisualPrefsName, Context.MODE_PRIVATE)
        return prefs.getBoolean(widgetVisualPremiumActiveKey, false)
    }

    private fun setPremiumActive(context: Context, isActive: Boolean) {
        val prefs = context.getSharedPreferences(widgetVisualPrefsName, Context.MODE_PRIVATE)
        prefs.edit().putBoolean(widgetVisualPremiumActiveKey, isActive).apply()
    }
}
