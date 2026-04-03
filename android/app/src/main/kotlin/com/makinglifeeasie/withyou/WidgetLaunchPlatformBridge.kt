package com.makinglifeeasie.withyou

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject

private const val widgetEventChannelName = "with_you/widget_launch/events"
private const val widgetPrefsName = "with_you_widget_launch"
private const val widgetPendingEventsKey = "pending_events"
private const val widgetLaunchAction = "com.makinglifeeasie.withyou.HOME_WIDGET_TAPPED"
private const val widgetExtraScenario = "scenario"

object WidgetLaunchPlatformBridge : EventChannel.StreamHandler {
    private var applicationContext: Context? = null
    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null

    fun configure(activity: Activity, flutterEngine: FlutterEngine) {
        this.activity = activity
        applicationContext = activity.applicationContext

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            widgetEventChannelName,
        ).setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
        applicationContext?.let { flushPendingEvents(it) }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun handleLaunchIntent(context: Context, intent: Intent?) {
        if (intent?.action != widgetLaunchAction) {
            return
        }

        emitEvent(
            context,
            mapOf(widgetExtraScenario to intent.getStringExtra(widgetExtraScenario)),
        )
        intent.action = null
    }

    private fun emitEvent(context: Context, payload: Map<String, Any?>) {
        val sink = eventSink
        if (sink != null) {
            sink.success(payload)
            return
        }

        val prefs = context.getSharedPreferences(widgetPrefsName, Context.MODE_PRIVATE)
        val existing = prefs.getString(widgetPendingEventsKey, "[]") ?: "[]"
        val queue = JSONArray(existing)
        queue.put(JSONObject(payload))
        prefs.edit().putString(widgetPendingEventsKey, queue.toString()).apply()
    }

    private fun flushPendingEvents(context: Context) {
        val sink = eventSink ?: return
        val prefs = context.getSharedPreferences(widgetPrefsName, Context.MODE_PRIVATE)
        val existing = prefs.getString(widgetPendingEventsKey, "[]") ?: "[]"
        val queue = JSONArray(existing)
        for (index in 0 until queue.length()) {
            val item = queue.getJSONObject(index)
            sink.success(
                mapOf(
                    widgetExtraScenario to item.optString(widgetExtraScenario).ifEmpty { null },
                ),
            )
        }
        prefs.edit().remove(widgetPendingEventsKey).apply()
    }
}
