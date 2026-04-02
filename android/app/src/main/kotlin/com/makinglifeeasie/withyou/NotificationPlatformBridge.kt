package com.makinglifeeasie.withyou

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

private const val methodChannelName = "with_you/notifications/methods"
private const val eventChannelName = "with_you/notifications/events"
private const val notificationChannelId = "with_you_follow_up_calls"
private const val prefsName = "with_you_notifications"
private const val pendingEventsKey = "pending_events"
private const val launchAction = "com.makinglifeeasie.withyou.NOTIFICATION_TAPPED"
private const val extraSessionId = "sessionId"
private const val extraScenario = "scenario"
private const val extraStage = "stage"
private const val extraCallerName = "callerName"
private const val extraAction = "action"
private const val extraNotificationId = "notificationId"
private const val extraFireAtEpochMs = "fireAtEpochMs"

object NotificationPlatformBridge : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private var applicationContext: Context? = null
    private var eventSink: EventChannel.EventSink? = null

    fun configure(activity: Activity, flutterEngine: FlutterEngine) {
        applicationContext = activity.applicationContext

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannelName,
        ).setMethodCallHandler(this)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            eventChannelName,
        ).setStreamHandler(this)

        createNotificationChannel(activity.applicationContext)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val context = applicationContext
        if (context == null) {
            result.error("unavailable", "Notification bridge is not configured", null)
            return
        }

        when (call.method) {
            "initialize" -> {
                createNotificationChannel(context)
                flushPendingEvents(context)
                result.success(notificationsEnabled(context))
            }
            "scheduleFollowUp" -> {
                scheduleFollowUp(context, call.arguments as Map<*, *>)
                result.success(null)
            }
            "cancelAll" -> {
                val sessionId = call.argument<String>(extraSessionId)!!
                cancelAll(context, sessionId)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
        applicationContext?.let { flushPendingEvents(it) }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun handleLaunchIntent(context: Context, intent: Intent?) {
        if (intent?.action != launchAction) {
            return
        }

        val payload = mapOf(
            extraSessionId to intent.getStringExtra(extraSessionId),
            extraScenario to intent.getStringExtra(extraScenario),
            extraStage to intent.getIntExtra(extraStage, 0),
            extraAction to "tapped",
        )

        val sessionId = intent.getStringExtra(extraSessionId) ?: return
        val stage = intent.getIntExtra(extraStage, 0)
        cancelMissedAlarm(
            context = context,
            sessionId = sessionId,
            stage = stage,
        )
        NotificationManagerCompat.from(context).cancel(notificationId(sessionId, stage))
        emitEvent(context, payload)
        intent.action = null
    }

    fun emitEvent(context: Context, payload: Map<String, Any?>) {
        val sink = eventSink
        if (sink != null) {
            sink.success(payload)
            return
        }

        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val existing = prefs.getString(pendingEventsKey, "[]") ?: "[]"
        val queue = JSONArray(existing)
        queue.put(JSONObject(payload))
        prefs.edit().putString(pendingEventsKey, queue.toString()).apply()
    }

    private fun flushPendingEvents(context: Context) {
        val sink = eventSink ?: return
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val existing = prefs.getString(pendingEventsKey, "[]") ?: "[]"
        val queue = JSONArray(existing)
        for (index in 0 until queue.length()) {
            val item = queue.getJSONObject(index)
            sink.success(
                mapOf(
                    extraSessionId to item.getString(extraSessionId),
                    extraScenario to item.getString(extraScenario),
                    extraStage to item.getInt(extraStage),
                    extraAction to item.getString(extraAction),
                ),
            )
        }
        prefs.edit().remove(pendingEventsKey).apply()
    }

    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val manager = context.getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                notificationChannelId,
                "Follow-up Calls",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Follow-up support calls"
            },
        )
    }

    private fun notificationsEnabled(context: Context): Boolean {
        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) {
            return false
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
                PackageManager.PERMISSION_GRANTED
        }

        return true
    }

    private fun scheduleFollowUp(context: Context, arguments: Map<*, *>) {
        val sessionId = arguments[extraSessionId] as String
        val scenario = arguments[extraScenario] as String
        val stage = arguments[extraStage] as Int
        val delaySeconds = arguments["delaySeconds"] as Int
        val callerName = arguments[extraCallerName] as String
        val fireAtEpochMs = System.currentTimeMillis() + (delaySeconds * 1000L)

        val intent = Intent(context, FollowUpNotificationReceiver::class.java).apply {
            putExtra(extraSessionId, sessionId)
            putExtra(extraScenario, scenario)
            putExtra(extraStage, stage)
            putExtra(extraCallerName, callerName)
            putExtra(extraFireAtEpochMs, fireAtEpochMs)
        }
        alarmManager(context).setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            fireAtEpochMs,
            PendingIntent.getBroadcast(
                context,
                showRequestCode(sessionId, stage),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
            ),
        )
    }

    fun showNotification(context: Context, intent: Intent) {
        val sessionId = intent.getStringExtra(extraSessionId) ?: return
        val scenario = intent.getStringExtra(extraScenario) ?: return
        val stage = intent.getIntExtra(extraStage, 0)
        val callerName = intent.getStringExtra(extraCallerName) ?: "Support call"
        val fireAtEpochMs = intent.getLongExtra(extraFireAtEpochMs, System.currentTimeMillis())
        val notificationId = notificationId(sessionId, stage)

        val tapIntent = Intent(context, MainActivity::class.java).apply {
            action = launchAction
            putExtra(extraSessionId, sessionId)
            putExtra(extraScenario, scenario)
            putExtra(extraStage, stage)
            putExtra(extraNotificationId, notificationId)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        val tapPendingIntent = PendingIntent.getActivity(
            context,
            tapRequestCode(sessionId, stage),
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
        )

        val notification = NotificationCompat.Builder(context, notificationChannelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(callerName)
            .setContentText("Follow-up support call")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setContentIntent(tapPendingIntent)
            .build()

        NotificationManagerCompat.from(context).notify(notificationId, notification)

        val missedIntent = Intent(context, MissedStageReceiver::class.java).apply {
            putExtra(extraSessionId, sessionId)
            putExtra(extraScenario, scenario)
            putExtra(extraStage, stage)
            putExtra(extraNotificationId, notificationId)
            putExtra(extraFireAtEpochMs, fireAtEpochMs)
        }
        alarmManager(context).setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            System.currentTimeMillis() + 120_000L,
            PendingIntent.getBroadcast(
                context,
                missedRequestCode(sessionId, stage),
                missedIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
            ),
        )
    }

    fun handleMissedStage(context: Context, intent: Intent) {
        val sessionId = intent.getStringExtra(extraSessionId) ?: return
        val scenario = intent.getStringExtra(extraScenario) ?: return
        val stage = intent.getIntExtra(extraStage, 0)
        val notificationId = intent.getIntExtra(extraNotificationId, 0)

        NotificationManagerCompat.from(context).cancel(notificationId)
        emitEvent(
            context,
            mapOf(
                extraSessionId to sessionId,
                extraScenario to scenario,
                extraStage to stage,
                extraAction to "missed",
            ),
        )
    }

    private fun cancelAll(context: Context, sessionId: String) {
        for (stage in 1..3) {
            PendingIntent.getBroadcast(
                context,
                showRequestCode(sessionId, stage),
                Intent(context, FollowUpNotificationReceiver::class.java),
                PendingIntent.FLAG_NO_CREATE or immutableFlag(),
            )?.let {
                alarmManager(context).cancel(it)
                it.cancel()
            }
            cancelMissedAlarm(context, sessionId, stage)
            NotificationManagerCompat.from(context).cancel(notificationId(sessionId, stage))
        }
    }

    fun cancelMissedAlarm(context: Context, sessionId: String, stage: Int) {
        PendingIntent.getBroadcast(
            context,
            missedRequestCode(sessionId, stage),
            Intent(context, MissedStageReceiver::class.java),
            PendingIntent.FLAG_NO_CREATE or immutableFlag(),
        )?.let {
            alarmManager(context).cancel(it)
            it.cancel()
        }
    }

    private fun alarmManager(context: Context): AlarmManager {
        return context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    }

    private fun showRequestCode(sessionId: String, stage: Int): Int {
        return "show:$sessionId:$stage".hashCode()
    }

    private fun tapRequestCode(sessionId: String, stage: Int): Int {
        return "tap:$sessionId:$stage".hashCode()
    }

    private fun missedRequestCode(sessionId: String, stage: Int): Int {
        return "missed:$sessionId:$stage".hashCode()
    }

    private fun notificationId(sessionId: String, stage: Int): Int {
        return "notification:$sessionId:$stage".hashCode()
    }

    private fun immutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }
    }
}

class FollowUpNotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        NotificationPlatformBridge.showNotification(context, intent)
    }
}

class MissedStageReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        NotificationPlatformBridge.handleMissedStage(context, intent)
    }
}
