package com.makinglifeeasie.withyou

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.view.View
import android.widget.RemoteViews

class HomeLaunchWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            appWidgetManager.updateAppWidget(
                appWidgetId,
                buildRemoteViews(context),
            )
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        updateAllWidgets(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            updateAllWidgets(context)
        }
    }

    private fun buildRemoteViews(context: Context): RemoteViews {
        val isPremiumActive = WidgetVisualStatePlatformBridge.isPremiumActive(context)
        return RemoteViews(context.packageName, R.layout.home_launch_widget).apply {
            setOnClickPendingIntent(
                R.id.widget_logo_button,
                buildLaunchPendingIntent(context),
            )
            setInt(
                R.id.widget_logo,
                "setImageAlpha",
                if (isPremiumActive) 255 else 110,
            )
            setViewVisibility(
                R.id.widget_lock_scrim,
                if (isPremiumActive) View.GONE else View.VISIBLE,
            )
            setViewVisibility(
                R.id.widget_lock_badge,
                if (isPremiumActive) View.GONE else View.VISIBLE,
            )
            setInt(
                R.id.widget_logo_button,
                "setBackgroundResource",
                if (isPremiumActive) {
                    R.drawable.home_launch_widget_background
                } else {
                    R.drawable.home_launch_widget_background_locked
                },
            )
        }
    }

    private fun buildLaunchPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = "com.makinglifeeasie.withyou.HOME_WIDGET_TAPPED"
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        return PendingIntent.getActivity(
            context,
            1001,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
        )
    }

    private fun immutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }
    }

    companion object {
        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, HomeLaunchWidgetProvider::class.java)
            val widgetIds = manager.getAppWidgetIds(componentName)
            if (widgetIds.isNotEmpty()) {
                HomeLaunchWidgetProvider().onUpdate(context, manager, widgetIds)
            }
        }
    }
}
